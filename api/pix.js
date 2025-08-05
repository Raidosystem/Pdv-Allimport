// PIX Payment endpoint for Vercel
import { MercadoPagoConfig, Payment } from 'mercadopago';
import { createClient } from '@supabase/supabase-js';

// Configurar Mercado Pago
const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN,
  options: { timeout: 5000 }
});

const payment = new Payment(client);

// Configurar Supabase
const supabase = createClient(
  process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY
);

export default async function handler(req, res) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { userEmail, userName, amount, description } = req.body;

    if (!userEmail || !amount) {
      return res.status(400).json({ 
        error: 'Email do usuário e valor são obrigatórios' 
      });
    }

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
      notification_url: `https://pdv-allimport.vercel.app/api/webhook`
    };

    const response = await payment.create({
      body: paymentData
    });

    // Salvar pagamento no Supabase
    await supabase.from('payments').insert({
      mp_payment_id: response.id.toString(),
      user_id: null,
      mp_status: response.status,
      amount: response.transaction_amount,
      payer_email: userEmail,
      payer_name: userName,
      webhook_data: response
    });

    return res.json({
      payment_id: response.id.toString(),
      status: response.status,
      qr_code: response.point_of_interaction?.transaction_data?.qr_code || '',
      qr_code_base64: response.point_of_interaction?.transaction_data?.qr_code_base64 || '',
      ticket_url: response.point_of_interaction?.transaction_data?.ticket_url || ''
    });

  } catch (error) {
    console.error('❌ Erro ao criar PIX:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
