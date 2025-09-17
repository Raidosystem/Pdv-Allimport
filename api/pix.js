// PIX Payment endpoint for Vercel
// Credenciais de produção do Mercado Pago
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

    console.log('🚀 Processando PIX:', { amount, description, email, company_id, user_id });

    if (!amount || !description) {
      res.status(400).json({ error: 'Amount and description are required' });
      return;
    }

    // Configuração do pagamento PIX
    const paymentData = {
      transaction_amount: Number(amount),
      description: description,
      payment_method_id: 'pix',
      payer: {
        email: email || 'cliente@pdvallimport.com',
        first_name: email ? email.split('@')[0] : 'Cliente',
        last_name: 'PDV'
      },
      external_reference: `pix_${Date.now()}`,
      notification_url: `${req.headers.origin || 'https://pdv-allimport.vercel.app'}/api/mp/webhook`,
      metadata: {
        company_id: email || company_id || user_id || `user_${email?.split('@')[0]}`, // Usar email como company_id
        user_email: email,
        payment_type: 'subscription'
      }
    };

    console.log('📤 Enviando para Mercado Pago:', paymentData);

    // Fazer chamada para API do Mercado Pago
    const response = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
        'X-Idempotency-Key': Date.now().toString()
      },
      body: JSON.stringify(paymentData)
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('❌ Erro do Mercado Pago:', response.status, errorData);
      throw new Error(`Mercado Pago API error: ${response.status}`);
    }

    const paymentResponse = await response.json();
    console.log('✅ Resposta do Mercado Pago:', paymentResponse);

    // Retornar resposta com QR code do Mercado Pago
    res.status(200).json({
      success: true,
      payment_id: paymentResponse.id,
      status: paymentResponse.status,
      qr_code: paymentResponse.point_of_interaction?.transaction_data?.qr_code,
      qr_code_base64: paymentResponse.point_of_interaction?.transaction_data?.qr_code_base64,
      ticket_url: paymentResponse.point_of_interaction?.transaction_data?.ticket_url
    });

  } catch (error) {
    console.error('PIX payment error:', error);
    res.status(500).json({ 
      error: 'Failed to create PIX payment',
      details: error.message 
    });
  }
}
