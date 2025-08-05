// Payment Preference endpoint for Vercel
import { MercadoPagoConfig, Preference } from 'mercadopago';

// Configurar Mercado Pago
const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN,
  options: { timeout: 5000 }
});

const preference = new Preference(client);

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
    const { userEmail, userName, amount, planName } = req.body;

    if (!userEmail || !amount) {
      return res.status(400).json({ 
        error: 'Email do usuário e valor são obrigatórios' 
      });
    }

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
        success: 'https://pdv-allimport.vercel.app/assinatura?status=success',
        failure: 'https://pdv-allimport.vercel.app/assinatura?status=failure',
        pending: 'https://pdv-allimport.vercel.app/assinatura?status=pending'
      },
      auto_return: 'approved',
      external_reference: `card_${userEmail}_${Date.now()}`,
      notification_url: 'https://pdv-allimport.vercel.app/api/webhook'
    };

    const response = await preference.create({
      body: preferenceData
    });

    return res.json({
      id: response.id,
      init_point: response.init_point,
      sandbox_init_point: response.sandbox_init_point
    });

  } catch (error) {
    console.error('❌ Erro ao criar preferência:', error);
    return res.status(500).json({ 
      error: 'Erro interno do servidor',
      details: error.message 
    });
  }
}
