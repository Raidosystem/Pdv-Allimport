import { MercadoPagoConfig, Payment } from 'mercadopago';
import { createClient } from '@supabase/supabase-js';

// Configurar CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function handler(req, res) {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).json({});
  }

  // Only allow GET
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { paymentId } = req.query;

    if (!paymentId) {
      return res.status(400).json({ error: 'Payment ID é obrigatório' });
    }

    console.log('🔍 Verificando status do pagamento:', paymentId);

    // Configurar Mercado Pago
    const client = new MercadoPagoConfig({
      accessToken: process.env.MP_ACCESS_TOKEN,
      options: {
        timeout: 5000
      }
    });

    const payment = new Payment(client);

    const response = await payment.get({
      id: paymentId
    });
    const paymentResult = response;

    console.log('✅ Status do pagamento:', paymentResult.status);

    // Configurar Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_KEY
    );

    // Atualizar status no Supabase
    try {
      await supabase
        .from('payments')
        .update({
          mp_status: paymentResult.status,
          mp_status_detail: paymentResult.status_detail,
          webhook_data: paymentResult,
          updated_at: new Date().toISOString()
        })
        .eq('mp_payment_id', paymentId);
      console.log('💾 Status atualizado no Supabase');
    } catch (supabaseError) {
      console.error('❌ Erro ao atualizar Supabase:', supabaseError);
    }

    const result = {
      payment_id: paymentResult.id,
      status: paymentResult.status,
      status_detail: paymentResult.status_detail,
      approved: paymentResult.status === 'approved'
    };

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erro ao verificar pagamento:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
