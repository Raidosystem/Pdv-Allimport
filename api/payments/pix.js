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

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log('🚀 PIX API - Iniciando processamento:', req.body);

    const { userEmail, userName, amount, description } = req.body;

    if (!userEmail || !amount) {
      return res.status(400).json({ 
        error: 'Email do usuário e valor são obrigatórios' 
      });
    }

    // Configurar Mercado Pago
    const client = new MercadoPagoConfig({
      accessToken: process.env.MP_ACCESS_TOKEN,
      options: {
        timeout: 5000
      }
    });

    const payment = new Payment(client);

    // Configurar Supabase
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_KEY
    );

    const paymentData = {
      transaction_amount: Number(amount),
      description: description || 'Assinatura PDV Allimport',
      payment_method_id: 'pix',
      payer: {
        email: userEmail,
        first_name: userName?.split(' ')[0] || 'Cliente',
        last_name: userName?.split(' ').slice(1).join(' ') || 'PDV'
      },
      external_reference: `pix_${userEmail}_${Date.now()}`,
      notification_url: `${process.env.API_BASE_URL}/api/webhook/mercadopago`
    };

    console.log('📤 Dados enviados ao Mercado Pago:', paymentData);

    const response = await payment.create({
      body: paymentData
    });
    const paymentResult = response;

    console.log('✅ Resposta do Mercado Pago:', paymentResult);

    // Salvar pagamento no Supabase
    try {
      await supabase.from('payments').insert({
        mp_payment_id: paymentResult.id.toString(),
        user_id: null, // Será atualizado quando soubermos o user_id
        mp_status: paymentResult.status,
        mp_status_detail: paymentResult.status_detail,
        amount: paymentResult.transaction_amount,
        currency: paymentResult.currency_id,
        payment_method: 'pix',
        payment_type: paymentResult.payment_type_id,
        payer_email: userEmail,
        payer_name: userName,
        webhook_data: paymentResult
      });
      console.log('💾 Pagamento salvo no Supabase');
    } catch (supabaseError) {
      console.error('❌ Erro ao salvar no Supabase:', supabaseError);
    }

    // Retornar dados do PIX
    const result = {
      payment_id: paymentResult.id.toString(),
      status: paymentResult.status,
      qr_code: paymentResult.point_of_interaction?.transaction_data?.qr_code || '',
      qr_code_base64: paymentResult.point_of_interaction?.transaction_data?.qr_code_base64 || '',
      ticket_url: paymentResult.point_of_interaction?.transaction_data?.ticket_url || ''
    };

    console.log('📱 Resultado final PIX:', result);

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erro ao criar PIX:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
