import { useState, useEffect } from 'react'
import { useAuth } from '../modules/auth/AuthContext'
import { SubscriptionService } from '../services/subscriptionService'
import { supabase } from '../lib/supabase'
import type { SubscriptionStatus, Subscription } from '../types/subscription'

export function useSubscription() {
  const { user } = useAuth()
  const [subscriptionStatus, setSubscriptionStatus] = useState<SubscriptionStatus | null>(null)
  const [subscription, setSubscription] = useState<Subscription | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadSubscriptionData = async () => {
    if (!user?.email) {
      setLoading(false)
      return
    }

    try {
      setLoading(true)
      setError(null)

      // Buscar status da assinatura
      const status = await SubscriptionService.checkSubscriptionStatus(user.email)
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

  // Carregar dados quando o usuário mudar e configurar Realtime
  useEffect(() => {
    if (user?.email) {
      loadSubscriptionData()
      
      // Configurar escuta em tempo real para mudanças na tabela subscriptions
      console.log('🔄 Configurando Realtime para assinatura:', user.email);
      
      const subscription = supabase
        .channel('subscription_changes')
        .on(
          'postgres_changes',
          {
            event: '*', // Escutar INSERT, UPDATE, DELETE
            schema: 'public',
            table: 'subscriptions',
            filter: `user_email=eq.${user.email}`
          },
          (payload) => {
            console.log('🔔 Mudança detectada na assinatura via Realtime:', payload);
            
            // Recarregar dados quando houver mudanças
            loadSubscriptionData();
          }
        )
        .subscribe((status) => {
          console.log('📡 Status do Realtime:', status);
        });

      // Cleanup quando o componente for desmontado ou usuário mudar
      return () => {
        console.log('🧹 Removendo escuta Realtime');
        subscription.unsubscribe();
      };
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

  // Escutar mudanças em tempo real na assinatura
  const listenToSubscriptionChanges = () => {
    if (!user?.email) return null

    console.log('🔄 Iniciando escuta Realtime para assinatura:', user.email)

    const channel = supabase
      .channel('subscription-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'subscriptions',
          filter: `user_email=eq.${user.email}`
        },
        (payload) => {
          console.log('🔄 Mudança detectada na assinatura:', payload)
          // Recarregar dados quando houver mudanças
          setTimeout(() => {
            loadSubscriptionData()
          }, 1000) // Delay para garantir que os dados foram salvos
        }
      )
      .subscribe()

    return () => {
      console.log('🧹 Removendo escuta Realtime da assinatura')
      supabase.removeChannel(channel)
    }
  }

  // Hook para escutar mudanças em tempo real
  useEffect(() => {
    const unsubscribe = listenToSubscriptionChanges()
    return () => {
      if (unsubscribe) {
        unsubscribe()
      }
    }
  }, [user?.email])

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
