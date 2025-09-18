import { createClient } from '@supabase/supabase-js'

export default async function handler(req: any, res: any) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  }

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({})
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Dados fixos do pagamento pendente
    const paymentId = 126596009978
    const userEmail = 'novaradiosystem@outlook.com'
    
    console.log(`🔧 Processando manualmente pagamento ${paymentId} para ${userEmail}`)

    // Inicializar Supabase
    const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !supabaseServiceKey) {
      return res.status(500).json({ error: 'Configuração Supabase ausente' })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 1. Verificar se já foi processado
    const { data: existingReceipt } = await supabase
      .from('payment_receipts')
      .select('*')
      .eq('mp_payment_id', paymentId)
      .single()

    if (existingReceipt) {
      return res.status(200).json({
        success: true,
        already_processed: true,
        message: 'Pagamento já foi processado anteriormente',
        receipt: existingReceipt
      })
    }

    // 2. Creditar dias usando a função SQL
    const { data: creditResult, error: creditError } = await supabase
      .rpc('credit_subscription_days', {
        p_mp_payment_id: paymentId,
        p_user_email: userEmail,
        p_days_to_add: 31
      })

    if (creditError) {
      console.error('❌ Erro ao creditar dias:', creditError)
      return res.status(500).json({
        error: 'Erro ao processar pagamento',
        details: creditError.message
      })
    }

    console.log('✅ Pagamento processado com sucesso:', creditResult)

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      success: true,
      payment_id: paymentId,
      user_email: userEmail,
      credit_result: creditResult,
      message: 'Pagamento processado manualmente com sucesso!',
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('❌ Erro ao processar manualmente:', error)
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error instanceof Error ? error.message : 'Erro desconhecido',
      timestamp: new Date().toISOString()
    })
  }
}