// Tipos para o sistema de assinatura

export interface Subscription {
  id: string
  user_id: string
  email: string
  status: 'pending' | 'trial' | 'active' | 'expired' | 'cancelled'
  
  // Período de teste
  trial_start_date?: string
  trial_end_date?: string
  
  // Assinatura paga
  subscription_start_date?: string
  subscription_end_date?: string
  
  // Pagamento
  payment_method?: 'pix' | 'credit_card' | 'debit_card'
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
  payment_id?: string
  payment_amount: number
  
  created_at: string
  updated_at: string
}

export interface Payment {
  id: string
  subscription_id: string
  user_id: string
  
  // Mercado Pago
  mp_payment_id: string
  mp_preference_id?: string
  mp_status: string
  mp_status_detail?: string
  
  // Dados do pagamento
  amount: number
  currency: string
  payment_method: string
  payment_type?: string
  
  // Dados do pagador
  payer_email?: string
  payer_name?: string
  payer_document?: string
  
  webhook_data?: any
  
  created_at: string
  updated_at: string
}

export interface SubscriptionStatus {
  has_subscription: boolean
  status: 'no_subscription' | 'trial' | 'active' | 'expired' | 'cancelled'
  access_allowed: boolean
  trial_end_date?: string
  subscription_end_date?: string
  days_remaining?: number
}

export interface MercadoPagoPreference {
  id: string
  init_point: string
  sandbox_init_point: string
  qr_code?: string
  qr_code_base64?: string
}

export interface MercadoPagoPayment {
  id: number
  status: 'pending' | 'approved' | 'authorized' | 'in_process' | 'in_mediation' | 'rejected' | 'cancelled' | 'refunded' | 'charged_back'
  status_detail: string
  payment_method_id: string
  payment_type_id: string
  transaction_amount: number
  currency_id: string
  payer: {
    email: string
    identification?: {
      type: string
      number: string
    }
  }
  external_reference?: string
}

export interface PaymentPlan {
  id: string
  name: string
  description: string
  price: number
  currency: string
  duration_days: number
  features: string[]
  popular?: boolean
  savings?: number
  monthlyEquivalent?: number
}

// Planos disponíveis
export const PAYMENT_PLANS: PaymentPlan[] = [
  {
    id: 'monthly',
    name: 'Plano Mensal',
    description: 'Acesso completo por 30 dias',
    price: 59.90,
    currency: 'BRL',
    duration_days: 31,
    monthlyEquivalent: 59.90,
    features: [
      'Sistema PDV completo',
      'Gestão de estoque',
      'Relatórios detalhados',
      'Controle de caixa',
      'Suporte técnico',
      'Atualizações automáticas'
    ]
  },
  {
    id: 'annual',
    name: 'Plano Anual',
    description: 'Acesso completo por 12 meses',
    price: 550.00,
    currency: 'BRL',
    duration_days: 365,
    monthlyEquivalent: 45.83,
    savings: 168.80,
    popular: true,
    features: [
      'Sistema PDV completo',
      'Gestão de estoque',
      'Relatórios detalhados',
      'Controle de caixa',
      'Suporte técnico prioritário',
      'Atualizações automáticas',
      '💰 Economia de R$ 168,80 (23%)',
      '🎁 Equivale a 2 meses grátis'
    ]
  }
]
