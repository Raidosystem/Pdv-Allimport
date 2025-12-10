import { useState, useEffect } from 'react'
import { useAuth } from '../modules/auth/AuthContext'
import { SubscriptionService } from '../services/subscriptionService'
import type { SubscriptionStatus, Subscription } from '../types/subscription'
import { supabase } from '../lib/supabase'

export function useSubscription() {
  const { user } = useAuth()
  const [subscriptionStatus, setSubscriptionStatus] = useState<SubscriptionStatus | null>(null)
  const [subscription, setSubscription] = useState<Subscription | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  // 🚨 SUPER ADMIN sempre tem acesso TOTAL
  const SUPER_ADMIN_EMAIL = 'novaradiosystem@outlook.com'
  const isSuperAdmin = user?.email?.toLowerCase() === SUPER_ADMIN_EMAIL.toLowerCase()

  const loadSubscriptionData = async () => {
    if (!user?.email) {
      console.log('🔍 [useSubscription] Sem email de usuário, abortando...')
      setLoading(false)
      return
    }
    
    // 🚨 Super admin bypassa verificação de assinatura
    if (isSuperAdmin) {
      console.log('✅ [useSubscription] SUPER ADMIN detectado - acesso TOTAL sem verificação')
      setSubscriptionStatus({
        has_subscription: true,
        status: 'active',
        access_allowed: true,
        days_remaining: 999999,
        trial_end_date: undefined
      })
      setLoading(false)
      return
    }

    try {
      console.log('🔍 [useSubscription] Iniciando loadSubscriptionData para:', user.email)
      console.log('🔍 [useSubscription] user.id:', user.id)
      console.log('🔍 [useSubscription] user.user_metadata:', user.user_metadata)
      setLoading(true)
      setError(null)

      // 🔑 CRITICAL FIX: A função RPC check_subscription_status já faz toda a lógica
      // de verificação, incluindo buscar assinatura da empresa se for funcionário.
      // Basta passar o email do usuário logado, a função RPC cuida do resto!
      
      console.log('🔍 [useSubscription] Chamando checkSubscriptionStatus com email do usuário:', user.email)
      const status = await SubscriptionService.checkSubscriptionStatus(user.email)
      console.log('🔍 [useSubscription] Status retornado:', status)
      setSubscriptionStatus(status)

      // Buscar dados completos da assinatura se existir
      if (status.has_subscription && user.id) {
        const subscriptionData = await SubscriptionService.getUserSubscription(user.id)
        setSubscription(subscriptionData)
      }
    } catch (err) {
      console.error('Erro ao carregar dados da assinatura:', err)
      setError(err instanceof Error ? err.message : 'Erro desconhecido')
    } finally {
      setLoading(false)
    }
  }

  // Carregar dados quando o usuário mudar
  useEffect(() => {
    if (user?.email) {
      loadSubscriptionData()
    } else {
      // Reset state quando não há usuário
      setSubscriptionStatus(null)
      setSubscription(null)
      setLoading(false)
      setError(null)
    }
  }, [user?.email]) // Remover user?.id para evitar loops

  // Verificar se o usuário tem acesso
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

  // 🔍 DEBUG: Logar todos os valores calculados
  const estadoCalculado = {
    subscriptionStatus,
    hasAccess,
    isInTrial,
    isExpired,
    isActive,
    daysRemaining,
    needsPayment,
    userEmail: user?.email
  }
  console.log('🔍 [useSubscription] Estado calculado:', estadoCalculado)
  console.log('📊 [useSubscription] Estado JSON:', JSON.stringify(estadoCalculado, null, 2))

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
