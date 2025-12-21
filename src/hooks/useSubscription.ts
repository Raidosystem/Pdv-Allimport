import { useState, useEffect, useRef } from 'react'
import { useAuth } from '../modules/auth/AuthContext'
import { SubscriptionService } from '../services/subscriptionService'
import type { SubscriptionStatus, Subscription } from '../types/subscription'
import { supabase } from '../lib/supabase'

// Estado compartilhado entre todas as instâncias do hook para evitar listeners e loads duplicados
type SharedSubscriptionState = {
  subscriptionStatus: SubscriptionStatus | null
  subscription: Subscription | null
  loading: boolean
  error: string | null
}

const sharedState: SharedSubscriptionState = {
  subscriptionStatus: null,
  subscription: null,
  loading: true,
  error: null
}

const subscribers = new Set<(state: SharedSubscriptionState) => void>()

let sharedLastEmail: string | null = null
let sharedVisibilityChange = false
let sharedVisibilityLock = false // Lock para prevenir reloads após visibilitychange
let sharedLoadingInProgress = false
let listenersRegistered = false
let authUnsubscribe: (() => void) | null = null
let visibilityHandler: (() => void) | null = null
let hookInstances = 0

const notifySubscribers = () => {
  const snapshot = { ...sharedState }
  subscribers.forEach((fn) => fn(snapshot))
}

export function useSubscription() {
  const { user } = useAuth()
  const [state, setState] = useState<SharedSubscriptionState>({ ...sharedState })
  
  // 🎯 Controles para evitar recarregamento desnecessário (compartilhados entre instâncias)
  const isInitialMount = useRef(true)
  
  // 🚨 SUPER ADMIN sempre tem acesso TOTAL
  const SUPER_ADMIN_EMAIL = 'novaradiosystem@outlook.com'
  const isSuperAdmin = user?.email?.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase()

  const updateSharedState = (partial: Partial<SharedSubscriptionState>) => {
    Object.assign(sharedState, partial)
    notifySubscribers()
    setState({ ...sharedState })
  }

  const loadSubscriptionData = async (forcedUser?: { id?: string; email?: string; user_metadata?: any } | null) => {
    const currentUser = forcedUser ?? user

    // 🎯 Prevenir chamadas concorrentes globais
    if (sharedLoadingInProgress) {
      console.log('⏳ [useSubscription] Já existe carregamento global em andamento, aguardando...')
      return
    }

    if (!currentUser?.email) {
      console.log('🔍 [useSubscription] Sem email de usuário, abortando...')
      updateSharedState({ loading: false })
      sharedLoadingInProgress = false
      return
    }
    
    // 🚨 Super admin bypassa verificação de assinatura
    if (currentUser.email?.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase()) {
      console.log('✅ [useSubscription] SUPER ADMIN detectado - acesso TOTAL sem verificação')
      sharedLastEmail = currentUser.email
      updateSharedState({
        subscriptionStatus: {
          has_subscription: true,
          status: 'active',
          access_allowed: true,
          days_remaining: 999999,
          trial_end_date: undefined
        },
        subscription: null,
        loading: false,
        error: null
      })
      sharedLoadingInProgress = false
      return
    }

    try {
      sharedLoadingInProgress = true
      sharedLastEmail = currentUser.email
      console.log('🔍 [useSubscription] Iniciando loadSubscriptionData para:', currentUser.email)
      console.log('🔍 [useSubscription] user.id:', currentUser.id)
      console.log('🔍 [useSubscription] user.user_metadata:', currentUser.user_metadata)
      updateSharedState({ loading: true, error: null })

      // 🔑 CRITICAL FIX: A função RPC check_subscription_status já faz toda a lógica
      // de verificação, incluindo buscar assinatura da empresa se for funcionário.
      // Basta passar o email do usuário logado, a função RPC cuida do resto!
      
      console.log('🔍 [useSubscription] Chamando checkSubscriptionStatus com email do usuário:', currentUser.email)
      const status = await SubscriptionService.checkSubscriptionStatus(currentUser.email)
      console.log('🔍 [useSubscription] Status retornado:', status)
      sharedState.subscriptionStatus = status

      // Buscar dados completos da assinatura se existir
      let subscriptionData: Subscription | null = null
      if (status.has_subscription && currentUser.id) {
        subscriptionData = await SubscriptionService.getUserSubscription(currentUser.id)
      }

      sharedState.subscription = subscriptionData
      updateSharedState({ subscriptionStatus: status, subscription: subscriptionData, error: null })
    } catch (err) {
      console.error('Erro ao carregar dados da assinatura:', err)
      updateSharedState({ error: err instanceof Error ? err.message : 'Erro desconhecido' })
    } finally {
      sharedLoadingInProgress = false
      updateSharedState({ loading: false })
    }
  }

  // Carregar dados quando o usuário mudar
  useEffect(() => {
    // 🎯 Carregar apenas no primeiro mount OU quando o email mudar de verdade
    if (user?.email) {
      // Se já temos dados em cache para este email, apenas sincronizar estado local
      if (sharedLastEmail === user.email && sharedState.subscriptionStatus) {
        console.log('⏭️  [useSubscription] Mesmo usuário com cache - pulando recarga')
        setState({ ...sharedState })
        return
      }

      // Primeiro mount ou email diferente dispara carregamento único compartilhado
      if (isInitialMount.current || sharedLastEmail !== user.email) {
        console.log('🎯 [useSubscription] Carregando dados compartilhados para email:', user.email)
        isInitialMount.current = false
        loadSubscriptionData(user)
      }
    } else {
      // Reset state quando não há usuário
      sharedLastEmail = null
      updateSharedState({ subscriptionStatus: null, subscription: null, loading: false, error: null })
    }
  }, [user?.email]) // Remover user?.id para evitar loops

  // 🎯 LISTENER para SIGNED_IN events (igual ao usePermissions)
  useEffect(() => {
    hookInstances += 1

    // Registrar listeners apenas uma vez por aba
    if (!listenersRegistered) {
      listenersRegistered = true
      console.log('🔧 [useSubscription] Registrando listener onAuthStateChange (singleton)')
      
      const { data: authListener } = supabase.auth.onAuthStateChange(async (event, session) => {
        if (event === 'SIGNED_IN') {
          const currentEmail = session?.user?.email || null
          console.log('🔐 [useSubscription] SIGNED_IN detectado')
          console.log('  � visibilityLock:', sharedVisibilityLock)
          console.log('  👁️ visibilityChange (global):', sharedVisibilityChange)
          console.log('  📧 currentEmail:', currentEmail)
          console.log('  📧 lastEmail (global):', sharedLastEmail)
          console.log('  ✅ emails iguais?', sharedLastEmail === currentEmail)
          
          // 🚨 VERIFICAR LOCK PRIMEIRO: Se lock ativo E mesmo email, IGNORAR
          if (sharedVisibilityLock && sharedLastEmail === currentEmail) {
            console.log('⛔ [useSubscription] BLOQUEADO POR LOCK: troca de aba + mesmo email')
            sharedVisibilityChange = false // Resetar flag
            sharedVisibilityLock = false // Desativar lock AQUI
            return
          }
          
          // 🔓 Desativar lock se não foi bloqueado acima
          if (sharedVisibilityLock) {
            sharedVisibilityLock = false
            console.log('🔓 [useSubscription] LOCK DESATIVADO (após verificação)')
          }
          
          // Limpar flag de visibilidade
          if (sharedVisibilityChange) {
            console.log('🧹 [useSubscription] Limpando flag de visibilidade')
            sharedVisibilityChange = false
          }
          
          // Verificar se o email mudou (novo login vs navegação)
          if (sharedLastEmail === currentEmail) {
            console.log('⛔ [useSubscription] IGNORANDO: mesmo email (apenas navegação)')
            return // Ignorar se for o mesmo usuário
          }
          
          // Email diferente = novo login real
          console.log('🔄 [useSubscription] PROCESSANDO: Email mudou - novo login detectado')
          sharedLastEmail = currentEmail
          await loadSubscriptionData(session?.user ?? null)
        } else if (event === 'SIGNED_OUT') {
          console.log('🚪 [useSubscription] SIGNED_OUT detectado - limpando dados')
          updateSharedState({ subscriptionStatus: null, subscription: null, loading: false, error: null })
        }
      })

      authUnsubscribe = authListener?.subscription?.unsubscribe ?? null
    }

    // Cada instância assina o estado compartilhado
    subscribers.add(setState)

    return () => {
      subscribers.delete(setState)
      hookInstances -= 1

      // Somente o último desmonta listeners globais para evitar vazamento
      if (hookInstances === 0) {
        console.log('🧹 [useSubscription] Cleanup global - removendo listener MINIMAL')
        if (authUnsubscribe) {
          authUnsubscribe()
          authUnsubscribe = null
        }
        listenersRegistered = false
      }
    }
  }, [])

  // Verificar se o usuário tem acesso
  const { subscriptionStatus, subscription, loading, error } = state

  const hasAccess = subscriptionStatus?.access_allowed || false

  // Verificar se está em período de teste
  const isInTrial = subscriptionStatus?.status === 'trial'

  // Verificar se a assinatura expirou
  const isExpired = subscriptionStatus?.status === 'expired'

  // Verificar se tem assinatura ativa
  const isActive = subscriptionStatus?.status === 'active'

  // Obter dias restantes
  const daysRemaining = subscriptionStatus?.days_remaining || 0

  // Verificar se precisa de pagamento
  const needsPayment = !hasAccess && subscriptionStatus?.has_subscription

  // Ativar período de teste (para admin)
  const activateTrial = async (userEmail: string) => {
    try {
      await SubscriptionService.activateTrial(userEmail)
      await loadSubscriptionData() // Recarregar dados
      return { success: true }
    } catch (error) {
      console.error('Erro ao ativar período de teste:', error)
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro desconhecido' 
      }
    }
  }

  // Ativar assinatura após pagamento
  const activateAfterPayment = async (paymentId: string, paymentMethod: string) => {
    if (!user?.email) {
      throw new Error('Usuário não encontrado')
    }

    try {
      await SubscriptionService.activateSubscriptionAfterPayment(
        user.email,
        paymentId,
        paymentMethod
      )
      await loadSubscriptionData() // Recarregar dados
      return { success: true }
    } catch (error) {
      console.error('Erro ao ativar assinatura:', error)
      throw error
    }
  }

  // Cancelar assinatura
  const cancelSubscription = async () => {
    if (!user?.id) {
      throw new Error('Usuário não encontrado')
    }

    try {
      await SubscriptionService.cancelSubscription(user.id)
      await loadSubscriptionData() // Recarregar dados
      return { success: true }
    } catch (error) {
      console.error('Erro ao cancelar assinatura:', error)
      throw error
    }
  }

  // Recarregar dados
  const refresh = () => {
    loadSubscriptionData()
  }

  return {
    // Estados
    subscriptionStatus,
    subscription,
    loading,
    error,

    // Status computados
    hasAccess,
    isInTrial,
    isExpired,
    isActive,
    daysRemaining,
    needsPayment,

    // Ações
    activateTrial,
    activateAfterPayment,
    cancelSubscription,
    refresh
  }
}
