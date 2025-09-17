// Preference Payment endpoint for Vercel (Cartão de Crédito)
// Credenciais corretas do Mercado Pago
const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';

export default async function handler(req, res) {
  // CORS headers - permitir múltiplos domínios
  const allowedOrigins = [
    'https://pdv.crmvsystem.com',
    'https://pdv-allimport.vercel.app',
    'http://localhost:5173',
    'http://localhost:5174',
    'http://localhost:5175',
    'http://localhost:5176',
    'http://localhost:5177',
    'http://localhost:5178',
    'http://localhost:5179'
  ];
  
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { amount, description, email, company_id, user_id } = req.body;

    console.log('🚀 Criando preferência de pagamento:', { amount, description, email, company_id, user_id });

    if (!amount || !description) {
      res.status(400).json({ error: 'Amount and description are required' });
      return;
    }

    // Configuração minimalista da preferência (conforme docs oficiais MP)
    const preferenceData = {
      items: [
        {
          title: description || 'Assinatura PDV Allimport',
          unit_price: Number(amount),
          quantity: 1
        }
      ],
      back_urls: {
        success: 'https://pdv.crmvsystem.com/payment/success',
        failure: 'https://pdv.crmvsystem.com/payment/failure',
        pending: 'https://pdv.crmvsystem.com/payment/pending'
      },
      auto_return: 'approved',
      external_reference: `pref_${Date.now()}`,
      notification_url: 'https://pdv.crmvsystem.com/api/mp/webhook'
    };

    // Adicionar payer apenas se email foi fornecido
    if (email && email.includes('@')) {
      preferenceData.payer = {
        email: email
      };
    }

    // Adicionar metadata apenas se necessário
    if (company_id || user_id || email) {
      preferenceData.metadata = {
        company_id: email || company_id || user_id || `user_${Date.now()}`,
        integration: 'pdv_allimport'
      };
    }

    console.log('📤 Enviando preferência para Mercado Pago:', JSON.stringify(preferenceData, null, 2));

    // Fazer chamada para API do Mercado Pago
    const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(preferenceData),
    });

    const responseText = await response.text();
    console.log('🔍 Resposta MP (status):', response.status);
    console.log('🔍 Resposta MP (body):', responseText);

    if (!response.ok) {
      console.error('❌ Erro detalhado do Mercado Pago:', {
        status: response.status,
        statusText: response.statusText,
        body: responseText,
        headers: Object.fromEntries(response.headers.entries())
      });
      throw new Error(`Mercado Pago API error: ${response.status} - ${responseText}`);
    }

    const preferenceResponse = JSON.parse(responseText);
    console.log('✅ Preferência criada com sucesso:', {
      id: preferenceResponse.id,
      init_point: preferenceResponse.init_point,
      date_created: preferenceResponse.date_created
    });

    // Retornar resposta com URLs de checkout
    res.status(200).json({
      success: true,
      preference_id: preferenceResponse.id,
      init_point: preferenceResponse.init_point,
      sandbox_init_point: preferenceResponse.sandbox_init_point
    });

  } catch (error) {
    console.error('❌ Erro ao criar preferência:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to create payment preference',
      details: error.message 
    });
  }
}
