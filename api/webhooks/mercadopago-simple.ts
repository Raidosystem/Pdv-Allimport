/**
 * Webhook MercadoPago - Versão Simplificada para Teste
 * Funciona sem tabela payments_processed
 */

import type { VercelRequest, VercelResponse } from '@vercel/node'
import { createClient } from '@supabase/supabase-js'

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
  id: string
  status: string
  status_detail: string
  payment_method_id: string
  transaction_amount: number
  external_reference?: string
  payer?: {
    email?: string
  }
  metadata?: {
    empresa_id?: string
    user_email?: string
  }
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const startTime = Date.now()

  try {
    console.log('🎣 Webhook MercadoPago SIMPLIFICADO recebido:', {
      timestamp: new Date().toISOString(),
      body: req.body
    })

    // 1. VALIDAR ESTRUTURA DO WEBHOOK
    const webhookData = req.body as MercadoPagoWebhookData
    
    if (!webhookData?.data?.id) {
      console.warn('⚠️ Webhook sem ID de pagamento')
      return res.status(400).json({ error: 'Webhook data.id is required' })
    }

    const paymentId = webhookData.data.id
    console.log(`🔍 Processando pagamento: ${paymentId}`)

    // 2. INICIALIZAR SUPABASE
    const supabaseUrl = process.env.VITE_SUPABASE_URL
    const supabaseServiceKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ Configuração Supabase ausente')
      return res.status(500).json({ error: 'Supabase configuration missing' })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. BUSCAR DETALHES DO PAGAMENTO NO MERCADOPAGO
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
      payer_email: payment.payer?.email
    })

    // 4. IDENTIFICAR USUÁRIO
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

    // 5. VERIFICAR SE É PAGAMENTO APROVADO
    const isApproved = payment.status === 'approved' || 
                      (payment.status === 'accredited' && payment.status_detail === 'accredited')

    console.log(`🎯 Pagamento ${paymentId}: ${isApproved ? 'APROVADO' : 'PENDENTE'}`)

    // 6. SE APROVADO, CREDITAR DIAS NA ASSINATURA
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