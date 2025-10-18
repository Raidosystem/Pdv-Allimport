import { supabase } from '../lib/supabase'
import type { Subscription, SubscriptionStatus, Payment } from '../types/subscription'

export class SubscriptionService {
  
  // Verificar status da assinatura do usuário
  static async checkSubscriptionStatus(userEmail: string): Promise<SubscriptionStatus> {
    try {
      const { data, error } = await supabase.rpc('check_subscription_status', {
        user_email: userEmail
      })

      if (error) {
        console.error('Erro ao verificar status da assinatura:', error)
        return {
          has_subscription: false,
          status: 'no_subscription',
          access_allowed: false
        }
      }

      return data as SubscriptionStatus
    } catch (error) {
      console.error('Erro ao verificar status da assinatura:', error)
      return {
        has_subscription: false,
        status: 'no_subscription',
        access_allowed: false
      }
    }
  }

  // Ativar período de teste (chamado pelo admin)
  static async activateTrial(userEmail: string) {
    try {
      const { data, error } = await supabase.rpc('activate_trial', {
        user_email: userEmail
      })

      if (error) {
        throw new Error(`Erro ao ativar período de teste: ${error.message}`)
      }

      return data
    } catch (error) {
      console.error('Erro ao ativar período de teste:', error)
      throw error
    }
  }

  // Buscar assinatura do usuário
  static async getUserSubscription(userId: string): Promise<Subscription | null> {
    try {
      const { data, error } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)

      if (error) {
        throw error
      }

      // Retornar o primeiro item do array (se existir)
      return data && data.length > 0 ? data[0] as Subscription : null
    } catch (error) {
      console.error('Erro ao buscar assinatura:', error)
      return null
    }
  }

  // Buscar todas as assinaturas (admin)
  static async getAllSubscriptions(): Promise<Subscription[]> {
    try {
      const { data, error } = await supabase
        .from('subscriptions')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) {
        throw error
      }

      return data as Subscription[]
    } catch (error) {
      console.error('Erro ao buscar assinaturas:', error)
      return []
    }
  }

  // Ativar assinatura após pagamento
  static async activateSubscriptionAfterPayment(
    userEmail: string,
    paymentId: string,
    paymentMethod: string
  ) {
    try {
      console.log('🔄 Chamando função SQL activate_subscription_after_payment:', {
        userEmail,
        paymentId,
        paymentMethod
      });

      const { data, error } = await supabase.rpc('activate_subscription_after_payment', {
        user_email: userEmail,
        payment_id: paymentId,
        payment_method: paymentMethod
      })

      if (error) {
        console.error('❌ Erro na função SQL:', error);
        throw new Error(`Erro ao ativar assinatura: ${error.message}`)
      }

      console.log('✅ Resultado da função SQL:', data);
      
      // Verificar se a função retornou sucesso
      if (data && data.success === false) {
        console.error('❌ Função SQL retornou erro:', data.error);
        throw new Error(`Erro na renovação: ${data.error || 'Erro desconhecido'}`);
      }

      return data
    } catch (error) {
      console.error('Erro ao ativar assinatura:', error)
      throw error
    }
  }

  // Registrar pagamento
  static async recordPayment(paymentData: {
    subscription_id: string
    user_id: string
    mp_payment_id: string
    mp_preference_id?: string
    mp_status: string
    mp_status_detail?: string
    amount: number
    payment_method: string
    payment_type?: string
    payer_email?: string
    payer_name?: string
    payer_document?: string
    webhook_data?: any
  }): Promise<Payment> {
    try {
      const { data, error } = await supabase
        .from('payments')
        .insert([paymentData])
        .select()
        .single()

      if (error) {
        throw error
      }

      return data as Payment
    } catch (error) {
      console.error('Erro ao registrar pagamento:', error)
      throw error
    }
  }

  // Buscar pagamentos do usuário
  static async getUserPayments(userId: string): Promise<Payment[]> {
    try {
      const { data, error } = await supabase
        .from('payments')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })

      if (error) {
        throw error
      }

      return data as Payment[]
    } catch (error) {
      console.error('Erro ao buscar pagamentos:', error)
      return []
    }
  }

  // Verificar se usuário tem acesso ao sistema
  static async hasAccess(userEmail: string): Promise<boolean> {
    const status = await this.checkSubscriptionStatus(userEmail)
    return status.access_allowed
  }

  // Obter dias restantes do período de teste
  static async getTrialDaysRemaining(userEmail: string): Promise<number | null> {
    const status = await this.checkSubscriptionStatus(userEmail)
    return status.days_remaining || null
  }

  // Cancelar assinatura
  static async cancelSubscription(userId: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('subscriptions')
        .update({ 
          status: 'cancelled',
          updated_at: new Date().toISOString()
        })
        .eq('user_id', userId)

      if (error) {
        throw error
      }
    } catch (error) {
      console.error('Erro ao cancelar assinatura:', error)
      throw error
    }
  }

  // Reativar assinatura
  static async reactivateSubscription(userId: string): Promise<void> {
    try {
      const subscription = await this.getUserSubscription(userId)
      if (!subscription) {
        throw new Error('Assinatura não encontrada')
      }

      const now = new Date()
      const newEndDate = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000)) // 30 dias

      const { error } = await supabase
        .from('subscriptions')
        .update({ 
          status: 'active',
          subscription_start_date: now.toISOString(),
          subscription_end_date: newEndDate.toISOString(),
          updated_at: now.toISOString()
        })
        .eq('user_id', userId)

      if (error) {
        throw error
      }
    } catch (error) {
      console.error('Erro ao reativar assinatura:', error)
      throw error
    }
  }

  // 🆕 Fazer upgrade de teste para assinatura paga (SOMA OS DIAS DO TESTE)
  static async upgradeToPaidSubscription(
    userEmail: string,
    planName: string,  // 'monthly', 'quarterly', 'semiannual', 'yearly'
    paymentAmount: number
  ): Promise<{ success: boolean; message?: string; total_days?: number; error?: string }> {
    try {
      console.log('🎯 Fazendo upgrade para assinatura paga:', { userEmail, planName, paymentAmount })

      const { data, error } = await supabase.rpc('upgrade_to_paid_subscription', {
        user_email: userEmail,
        plan_name: planName,
        payment_amount: paymentAmount
      })

      if (error) {
        console.error('❌ Erro ao fazer upgrade:', error)
        throw error
      }

      console.log('✅ Upgrade realizado:', data)
      
      return {
        success: data.success,
        message: data.message,
        total_days: data.total_days,
        error: data.error
      }
    } catch (error: any) {
      console.error('❌ Erro no upgrade:', error)
      return {
        success: false,
        error: error.message || 'Erro ao fazer upgrade'
      }
    }
  }
}
