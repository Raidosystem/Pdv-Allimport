import { createClient } from '@supabase/supabase-js'
import crypto from 'crypto'

interface MercadoPagoWebhookData {
  action: string
  api_version: string
  data: {
    id: string
  }
  date_created: string
  id: number
  live_mode: boolean
  type: string
  user_id: string
}

interface MercadoPagoPayment {
  id: number
  status: 'pending' | 'approved' | 'authorized' | 'in_process' | 'in_mediation' | 'rejected' | 'cancelled' | 'refunded' | 'charged_back' | 'accredited'
  status_detail: string
  payment_method_id: string
  payment_type_id: string
  transaction_amount: number
  currency_id: string
  date_created: string
  date_approved: string | null
  date_last_updated: string
  payer: {
    email?: string
    first_name?: string
    last_name?: string
    identification?: {
      type: string
      number: string
    }
  }
  metadata: {
    empresa_id?: string
    user_email?: string
    payment_type?: string
    plan_days?: string
    plan_id?: string
  }
  external_reference?: string
}

interface PaymentRecord {
  id?: number
  mp_payment_id: string
  status: string
  amount?: number
  user_email?: string
  processed_at?: string
}

export default async function handler(req: any, res: any) {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, x-signature, x-request-id, x-webhook-secret',
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type, x-signature, x-request-id').json({})
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const startTime = Date.now()
  
  try {
    // 1. VALIDAÇÃO DE SEGURANÇA (Opcional com webhook secret)
    const webhookSecret = process.env.MP_WEBHOOK_SECRET
    if (webhookSecret) {
      const receivedSecret = req.headers['x-webhook-secret']
      if (!receivedSecret || receivedSecret !== webhookSecret) {
        console.warn('⚠️ Webhook secret inválido')
        return res.status(401).json({ error: 'Unauthorized webhook' })
      }
    }

    console.log('🎣 Webhook recebido:', {
      headers: req.headers,
      body: req.body,
      timestamp: new Date().toISOString()
    })

    // 2. VALIDAR ESTRUTURA DO WEBHOOK
    const webhookData = req.body as MercadoPagoWebhookData
    
    if (!webhookData?.data?.id) {
      console.warn('⚠️ Webhook sem ID de pagamento')
      return res.status(400).json({ error: 'Webhook data.id is required' })
    }

    const paymentId = webhookData.data.id
    console.log(`🔍 Processando pagamento: ${paymentId}`)

    // 3. INICIALIZAR SUPABASE COM SERVICE_ROLE_KEY
    const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ Configuração Supabase ausente')
      return res.status(500).json({ error: 'Supabase configuration missing' })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 4. IDEMPOTÊNCIA - Verificar se já processamos este pagamento
    const { data: existingPayment } = await supabase
      .from('payments_processed')
      .select('*')
      .eq('mp_payment_id', paymentId)
      .eq('status', 'approved')
      .maybeSingle()

    if (existingPayment) {
      console.log(`✅ Pagamento ${paymentId} já processado anteriormente`)
      return res.status(200).json({
        success: true,
        message: 'Payment already processed',
        payment_id: paymentId,
        processed_at: existingPayment.processed_at
      })
    }

    // Buscar detalhes do pagamento no MercadoPago
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${process.env.MP_ACCESS_TOKEN}`,
        'Accept': 'application/json'
      }
    })

    if (!mpResponse.ok) {
      console.error(`❌ Erro ao buscar pagamento ${paymentId}: ${mpResponse.status}`)
      return res.status(400).json({ 
        error: 'Payment not found',
        payment_id: paymentId,
        mp_status: mpResponse.status
      })
    }

    const payment = await mpResponse.json() as MercadoPagoPayment
    console.log(`💳 Pagamento ${paymentId}:`, {
      status: payment.status,
      status_detail: payment.status_detail,
      payment_method: payment.payment_method_id,
      amount: payment.transaction_amount,
      empresa_id: payment.metadata?.empresa_id || payment.external_reference,
      payer_email: payment.payer?.email
    })

    // Identificar usuário (external_reference, metadata.empresa_id ou metadata.user_email)
    const userEmail = payment.external_reference || 
                     payment.metadata?.empresa_id || 
                     payment.metadata?.user_email ||
                     payment.payer?.email
    
    if (!userEmail) {
      console.warn(`⚠️ Pagamento ${paymentId} sem identificação de usuário`)
      return res.status(400).json({ 
        error: 'User email not found in payment',
        payment_id: paymentId
      })
    }

    // Verificar se é pagamento aprovado
    const isApproved = payment.status === 'approved' || 
                      (payment.status === 'accredited' && payment.status_detail === 'accredited')

    console.log(`🎯 Pagamento ${paymentId}: ${isApproved ? 'APROVADO' : 'PENDENTE'}`)

    // SE APROVADO, CREDITAR DIAS NA ASSINATURA
    if (isApproved) {
      console.log(`🚀 Creditando dias para usuário: ${userEmail}`)
      
      const { data: creditResult, error: creditError } = await supabase
        .rpc('credit_days_simple', {
          p_user_email: userEmail,
          p_days: 31
        })

      if (creditError) {
        console.error('❌ Erro ao creditar dias:', creditError)
        return res.status(500).json({
          error: 'Failed to credit subscription days',
          payment_id: paymentId,
          user_email: userEmail,
          supabase_error: creditError.message
        })
      }

      console.log('🎉 Resultado do crédito:', creditResult)
      
      // REGISTRAR PAGAMENTO COMO PROCESSADO (idempotência)
      const { error: insertError } = await supabase
        .from('payments_processed')
        .insert({
          mp_payment_id: paymentId,
          user_email: userEmail,
          status: payment.status,
          amount: payment.transaction_amount,
          payment_method: payment.payment_method_id,
          processed_at: new Date().toISOString(),
          webhook_data: payment
        })

      if (insertError && insertError.code !== '23505') { // 23505 = unique constraint violation
        console.error('❌ Erro registrando pagamento processado:', insertError)
        // Não falhar aqui, pois o crédito já foi aplicado
      }

      // DISPARAR REALTIME PARA ATUALIZAÇÃO EM TEMPO REAL
      try {
        await supabase
          .from('subscriptions')
          .update({ updated_at: new Date().toISOString() })
          .eq('email', userEmail)

        console.log(`📡 Realtime disparado para ${userEmail}`)
      } catch (realtimeError) {
        console.error('❌ Erro enviando Realtime:', realtimeError)
        // Não falhar, é apenas notificação
      }
      
      const processingTime = Date.now() - startTime
      
      return res.status(200).json({
        success: true,
        payment_id: paymentId,
        user_email: userEmail,
        status: payment.status,
        credit_result: creditResult,
        processing_time_ms: processingTime,
        timestamp: new Date().toISOString()
      })
    }

    // Pagamento não aprovado ainda
    const processingTime = Date.now() - startTime
    
    return res.status(200).json({
      success: true,
      payment_id: paymentId,
      user_email: userEmail,
      status: payment.status,
      status_detail: payment.status_detail,
      message: 'Payment recorded, waiting for approval',
      processing_time_ms: processingTime,
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('❌ Webhook error:', error)
    
    const processingTime = Date.now() - startTime
    
    return res.status(500).json({
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error',
      processing_time_ms: processingTime,
      timestamp: new Date().toISOString()
    })
  }
}