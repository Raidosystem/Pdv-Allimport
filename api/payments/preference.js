import { MercadoPagoConfig, Preference } from 'mercadopago';

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
    console.log('🚀 Preference API - Iniciando processamento:', req.body);

    const { userEmail, userName, amount, planName } = req.body;

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

    const preference = new Preference(client);

    const preferenceData = {
      items: [{
        id: 'pdv-subscription',
        title: planName || 'Assinatura PDV Allimport',
        description: 'Sistema PDV completo com todas as funcionalidades',
        quantity: 1,
        currency_id: 'BRL',
        unit_price: Number(amount)
      }],
      payer: {
        email: userEmail,
        name: userName || 'Cliente PDV'
      },
      payment_methods: {
        excluded_payment_types: [],
        excluded_payment_methods: [],
        installments: 12
      },
      back_urls: {
        success: `${process.env.FRONTEND_URL}/payment/success`,
        failure: `${process.env.FRONTEND_URL}/payment/failure`,
        pending: `${process.env.FRONTEND_URL}/payment/pending`
      },
      auto_return: 'approved',
      external_reference: `subscription_${userEmail}_${Date.now()}`,
      notification_url: `${process.env.API_BASE_URL}/api/webhook/mercadopago`,
      expires: true,
      expiration_date_from: new Date().toISOString(),
      expiration_date_to: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    };

    console.log('📤 Dados enviados ao Mercado Pago:', preferenceData);

    const response = await preference.create({
      body: preferenceData
    });
    const preferenceResult = response;

    console.log('✅ Resposta do Mercado Pago:', preferenceResult);

    const result = {
      id: preferenceResult.id,
      init_point: preferenceResult.init_point,
      sandbox_init_point: preferenceResult.sandbox_init_point
    };

    console.log('💳 Resultado final Preference:', result);

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erro ao criar preferência:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
