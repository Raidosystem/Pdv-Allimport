import { createClient } from '@supabase/supabase-js'

interface CreateCardRequest {
  user_email: string
  payer_email?: string
  amount?: number
  plan_days?: number
  card_token: string // Token do Card Brick
}

interface MercadoPagoPayment {
  transaction_amount: number
  token: string
  installments: number
  payment_method_id: string
  payer: {
    email: string
  }
  external_reference: string
  metadata: {
    empresa_id: string
    user_email: string
    payment_type: string
    plan_days: string
  }
  notification_url: string
}

export default async function handler(req: any, res: any) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  }

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization').json({})
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { user_email, payer_email, card_token, amount = 59.90, plan_days = 31 } = req.body as CreateCardRequest

    // Se não informar payer_email, usar o user_email
    const payerEmail = payer_email || user_email

    if (!user_email || !card_token) {
      return res.status(400).json({ 
        error: 'user_email and card_token are required',
        received: { user_email, has_card_token: !!card_token }
      })
    }

    console.log('💳 Criando pagamento cartão:', {
      user_email,
      payer_email: payerEmail,
      amount,
      plan_days,
      card_token: card_token.substring(0, 10) + '...'
    })

    // Configurar pagamento direto do MercadoPago
    const payment: MercadoPagoPayment = {
      transaction_amount: amount,
      token: card_token, // Token do Card Brick
      installments: 1,
      payment_method_id: 'visa', // Será determinado pelo token
      payer: {
        email: payerEmail
      },
      external_reference: user_email, // CRUCIAL: identifica o usuário
      metadata: {
        empresa_id: user_email, // Compatibilidade com webhook antigo
        user_email: user_email,
        payment_type: 'subscription',
        plan_days: plan_days.toString()
      },
      notification_url: 'https://pdv.crmvsystem.com/api/webhooks/mercadopago' // WEBHOOK!
    }

    // Criar pagamento no MercadoPago
    const mpResponse = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.VITE_MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
        'X-Idempotency-Key': `card-${user_email}-${Date.now()}` // Evitar duplicação
      },
      body: JSON.stringify(payment)
    })

    if (!mpResponse.ok) {
      const errorText = await mpResponse.text()
      console.error('❌ Erro ao criar pagamento MP:', errorText)
      return res.status(400).json({ 
        error: 'Failed to create MercadoPago payment',
        mp_error: errorText
      })
    }

    const mpPayment = await mpResponse.json()
    console.log('✅ Pagamento criado:', {
      id: mpPayment.id,
      status: mpPayment.status,
      status_detail: mpPayment.status_detail
    })

    // Salvar registro no Supabase
    const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey)
      
      // Criar registro na tabela payments
      const { error: insertError } = await supabase
        .from('payments')
        .insert({
          mp_payment_id: mpPayment.id,
          user_email,
          mp_status: mpPayment.status,
          mp_status_detail: mpPayment.status_detail,
          payment_method: mpPayment.payment_method_id,
          amount,
          payer_email: payerEmail,
          webhook_data: {
            payment_created: true,
            external_reference: user_email,
            metadata: payment.metadata,
            card_payment: true
          }
        })

      if (insertError) {
        console.warn('⚠️ Erro ao salvar pagamento:', insertError)
        // Não bloquear o fluxo
      }

      // Se aprovado imediatamente, creditar dias
      if (mpPayment.status === 'approved') {
        console.log('🚀 Pagamento aprovado imediatamente, creditando dias...')
        
        const { data: creditResult, error: creditError } = await supabase
          .rpc('credit_subscription_days', {
            p_mp_payment_id: mpPayment.id,
            p_user_email: user_email,
            p_days_to_add: plan_days
          })

        if (creditError) {
          console.error('❌ Erro ao creditar dias:', creditError)
        } else {
          console.log('🎉 Dias creditados imediatamente:', creditResult)
        }
      }
    }

    // Retornar dados para o frontend
    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      success: true,
      payment_id: mpPayment.id,
      status: mpPayment.status,
      status_detail: mpPayment.status_detail,
      approved: mpPayment.status === 'approved',
      user_email,
      amount,
      plan_days,
      webhook_url: 'https://pdv.crmvsystem.com/api/webhooks/mercadopago',
      created_at: new Date().toISOString()
    })

  } catch (error) {
    console.error('❌ Erro ao criar pagamento cartão:', error)
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    })
  }
}