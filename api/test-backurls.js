// Teste com back_urls genéricas
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const { amount, description } = req.body;
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';

    // Teste com back_urls do próprio Mercado Pago
    const testPreference = {
      items: [
        {
          title: description || 'Teste PDV',
          unit_price: Number(amount),
          quantity: 1
        }
      ],
      back_urls: {
        success: 'https://www.mercadopago.com.br/checkout/v1/payment/success',
        failure: 'https://www.mercadopago.com.br/checkout/v1/payment/failure', 
        pending: 'https://www.mercadopago.com.br/checkout/v1/payment/pending'
      },
      auto_return: 'approved'
    };

    const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(testPreference),
    });

    const responseText = await response.text();
    
    if (!response.ok) {
      throw new Error(`MP Error: ${response.status} - ${responseText}`);
    }

    const preferenceResponse = JSON.parse(responseText);
    
    res.status(200).json({
      success: true,
      message: 'Teste com back_urls do MP',
      preference_id: preferenceResponse.id,
      init_point: preferenceResponse.init_point
    });

  } catch (error) {
    res.status(500).json({ 
      success: false,
      error: error.message 
    });
  }
}