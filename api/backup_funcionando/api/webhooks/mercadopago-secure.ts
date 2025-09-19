/**
 * Webhook MercadoPago SEGURO - Implementação conforme plano de segurança
 * - Validação server-side obrigatória
 * - Token de segurança na URL
 * - Nunca confiar apenas no payload
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
  const startTime = Date.now()

  try {
    // 1. VALIDAÇÃO DE MÉTODO
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' })
    }

    // 2. VALIDAÇÃO DE TOKEN DE SEGURANÇA (filtro por token de rota)
    if (process.env.WEBHOOK_TOKEN && req.query.token !== process.env.WEBHOOK_TOKEN) {
      console.warn('🚨 Tentativa de acesso não autorizada ao webhook')
      return res.status(401).json({ error: 'Unauthorized webhook access' })
    }

    console.log('🎣 Webhook MercadoPago SEGURO recebido:', {
      timestamp: new Date().toISOString(),
      ip: req.headers['x-forwarded-for'] || req.connection.remoteAddress,
      userAgent: req.headers['user-agent']
    })

    // 3. VALIDAÇÃO DO PAYLOAD
    const webhookData = req.body as MercadoPagoWebhookData
    
    if (webhookData?.type !== 'payment' || !webhookData?.data?.id) {
      console.warn('⚠️ Webhook inválido ou não relacionado a pagamento')
      return res.status(200).json({ message: 'Webhook ignored - not a payment event' })
    }

    const paymentId = webhookData.data.id
    console.log(`🔍 Processando pagamento: ${paymentId}`)

    // 4. VALIDAÇÃO SERVER-SIDE OBRIGATÓRIA (nunca confiar só no payload)
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${process.env.MP_ACCESS_TOKEN}`,
        'Accept': 'application/json'
      }
    })

    if (!mpResponse.ok) {
      console.error(`❌ Erro ao buscar pagamento ${paymentId}: ${mpResponse.status}`)
      return res.status(400).json({ 
        error: 'Payment not found or MP API error',
        payment_id: paymentId,
        mp_status: mpResponse.status
      })
    }

    const payment = await mpResponse.json() as MercadoPagoPayment
    console.log(`💳 Pagamento ${paymentId} validado:`, {
      status: payment.status,
      status_detail: payment.status_detail,
      payment_method: payment.payment_method_id,
      amount: payment.transaction_amount
    })

    // 5. IDENTIFICAR USUÁRIO
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

    // 6. VERIFICAR SE É PAGAMENTO APROVADO
    const isApproved = payment.status === 'approved' || 
                      (payment.status === 'accredited' && payment.status_detail === 'accredited')

    console.log(`🎯 Pagamento ${paymentId}: ${isApproved ? 'APROVADO' : 'PENDENTE'}`)

    // 7. SE APROVADO, CREDITAR USANDO SERVICE_ROLE (server-side)
    if (isApproved) {
      console.log(`🚀 Creditando dias para usuário: ${userEmail}`)
      
      // Inicializar Supabase com SERVICE_ROLE_KEY (apenas server-side)
      const supabaseUrl = process.env.VITE_SUPABASE_URL
      const supabaseServiceKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY

      if (!supabaseUrl || !supabaseServiceKey) {
        console.error('❌ Configuração Supabase ausente')
        return res.status(500).json({ error: 'Supabase configuration missing' })
      }

      const supabase = createClient(supabaseUrl, supabaseServiceKey)
      
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
        timestamp: new Date().toISOString(),
        security_level: 'VALIDATED_SERVER_SIDE'
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
      timestamp: new Date().toISOString(),
      security_level: 'VALIDATED_SERVER_SIDE'
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