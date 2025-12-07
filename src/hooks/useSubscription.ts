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

  const loadSubscriptionData = async () => {
    if (!user?.email) {
      console.log('🔍 [useSubscription] Sem email de usuário, abortando...')
      setLoading(false)
      return
    }

    try {
      console.log('🔍 [useSubscription] Iniciando loadSubscriptionData para:', user.email)
      console.log('🔍 [useSubscription] user.id:', user.id)
      console.log('🔍 [useSubscription] user.user_metadata:', user.user_metadata)
      setLoading(true)
      setError(null)

      // 🔑 CRITICAL: Se for funcionário, buscar email da EMPRESA, não do funcionário
      let emailParaVerificar = user.email
      
      // PRIMEIRO: Verificar se tem empresa_id no user_metadata (funcionário após signInLocal)
      const empresaIdFromMetadata = (user.user_metadata as any)?.empresa_id
      const tipoAdminFromMetadata = (user.user_metadata as any)?.tipo_admin
      
      console.log('🔍 [useSubscription] empresa_id do metadata:', empresaIdFromMetadata)
      console.log('🔍 [useSubscription] tipo_admin do metadata:', tipoAdminFromMetadata)
      
      if (empresaIdFromMetadata && tipoAdminFromMetadata === 'funcionario') {
        // É funcionário - buscar assinatura pela empresa_id diretamente
        console.log('👤 [useSubscription] Usuário é funcionário, buscando assinatura por empresa_id...')
        
        // Buscar email da empresa diretamente na tabela subscriptions usando user_id
        const { data: subscription } = await supabase
          .from('subscriptions')
          .select('email')
          .eq('user_id', empresaIdFromMetadata)
          .maybeSingle()

        if (subscription?.email) {
          emailParaVerificar = subscription.email
          console.log('✅ [useSubscription] Email da empresa encontrado na subscription:', emailParaVerificar)
        } else {
          console.warn('⚠️ [useSubscription] Empresa não tem assinatura cadastrada')
        }
      } else {
        // Fallback: buscar na tabela funcionarios por user_id
        const { data: funcionarioData } = await supabase
          .from('funcionarios')
          .select('empresa_id, tipo_admin')
          .eq('user_id', user.id)
          .maybeSingle()

        if (funcionarioData && funcionarioData.tipo_admin === 'funcionario') {
          // É funcionário - buscar email da subscription pela empresa_id
          console.log('👤 [useSubscription] Usuário é funcionário (DB), buscando assinatura por empresa_id...')
          
          const { data: subscription } = await supabase
            .from('subscriptions')
            .select('email')
            .eq('user_id', funcionarioData.empresa_id)
            .maybeSingle()

          if (subscription?.email) {
            emailParaVerificar = subscription.email
            console.log('✅ [useSubscription] Email da empresa encontrado na subscription:', emailParaVerificar)
          }
        } else {
          console.log('🏢 [useSubscription] Usuário é admin/empresa, usando email próprio')
        }
      }

      // Buscar status da assinatura usando o email correto
      console.log('🔍 [useSubscription] Chamando checkSubscriptionStatus com:', emailParaVerificar)
      const status = await SubscriptionService.checkSubscriptionStatus(emailParaVerificar)
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
