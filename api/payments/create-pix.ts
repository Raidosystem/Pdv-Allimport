import { createClient } from '@supabase/supabase-js'

interface CreatePixRequest {
  empresa_id: string
  payer_email: string
  amount?: number
  plan_days?: number
}

interface MercadoPagoPreference {
  items: Array<{
    title: string
    quantity: number
    unit_price: number
    currency_id: string
  }>
  external_reference: string
  metadata: {
    empresa_id: string
    user_email: string
    payment_type: string
    plan_days: string
  }
  notification_url: string
  payment_methods: {
    excluded_payment_types: Array<{ id: string }>
    installments: number
  }
  payer: {
    email: string
  }
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
    const { empresa_id, payer_email, amount = 59.90, plan_days = 31 } = req.body as CreatePixRequest

    if (!empresa_id || !payer_email) {
      return res.status(400).json({ 
        error: 'empresa_id and payer_email are required',
        received: { empresa_id, payer_email }
      })
    }

    console.log('🆕 Criando pagamento PIX:', {
      empresa_id,
      payer_email,
      amount,
      plan_days
    })

    // Configurar preferência do MercadoPago
    const preference: MercadoPagoPreference = {
      items: [
        {
          title: `PDV Allimport - Assinatura ${plan_days} dias`,
          quantity: 1,
          unit_price: amount,
          currency_id: 'BRL'
        }
      ],
      external_reference: empresa_id, // CRUCIAL: identifica a empresa
      metadata: {
        empresa_id,
        user_email: payer_email,
        payment_type: 'subscription',
        plan_days: plan_days.toString()
      },
      notification_url: 'https://pdv.crmvsystem.com/api/webhooks/mercadopago', // WEBHOOK!
      payment_methods: {
        excluded_payment_types: [
          { id: 'credit_card' },
          { id: 'debit_card' },
          { id: 'ticket' }
        ], // Apenas PIX
        installments: 1
      },
      payer: {
        email: payer_email
      }
    }

    // Criar preferência no MercadoPago
    const mpResponse = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.VITE_MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(preference)
    })

    if (!mpResponse.ok) {
      const errorText = await mpResponse.text()
      console.error('❌ Erro ao criar preferência MP:', errorText)
      return res.status(400).json({ 
        error: 'Failed to create MercadoPago preference',
        mp_error: errorText
      })
    }

    const mpPreference = await mpResponse.json()
    console.log('✅ Preferência criada:', mpPreference.id)

    // Salvar registro no Supabase para rastreamento
    const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey)
      
      // Criar registro pendente na tabela payments
      const { error: insertError } = await supabase
        .from('payments')
        .insert({
          mp_payment_id: 0, // Será atualizado pelo webhook
          empresa_id,
          mp_status: 'pending',
          payment_method: 'pix',
          amount,
          payer_email,
          mp_preference_id: mpPreference.id,
          webhook_data: {
            preference_created: true,
            external_reference: empresa_id,
            metadata: preference.metadata
          }
        })

      if (insertError) {
        console.warn('⚠️ Erro ao salvar pagamento pendente:', insertError)
        // Não bloquear o fluxo
      }
    }

    // Retornar dados para o frontend
    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      success: true,
      preference_id: mpPreference.id,
      init_point: mpPreference.init_point, // Link para checkout
      qr_code: mpPreference.sandbox_init_point || mpPreference.init_point, // Para desenvolvimento
      empresa_id,
      amount,
      plan_days,
      webhook_url: 'https://pdv.crmvsystem.com/api/webhooks/mercadopago',
      created_at: new Date().toISOString()
    })

  } catch (error) {
    console.error('❌ Erro ao criar PIX:', error)
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString()
    })
  }
}