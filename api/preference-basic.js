// API de preferência extremamente básica (apenas campos obrigatórios)
export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { amount, description, email } = req.body;
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';

    console.log('🔨 Criando preferência básica:', { amount, description, email });

    // Preferência MÍNIMA conforme documentação MP
    const basicPreference = {
      items: [
        {
          title: description || 'Produto',
          unit_price: Number(amount),
          quantity: 1
        }
      ]
    };

    console.log('📤 Preferência básica:', JSON.stringify(basicPreference, null, 2));

    const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(basicPreference),
    });

    const responseText = await response.text();
    console.log('🔍 MP Response:', response.status, responseText);

    if (!response.ok) {
      throw new Error(`MP Error: ${response.status} - ${responseText}`);
    }

    const preferenceResponse = JSON.parse(responseText);
    
    res.status(200).json({
      success: true,
      preference_id: preferenceResponse.id,
      init_point: preferenceResponse.init_point,
      sandbox_init_point: preferenceResponse.sandbox_init_point,
      created: preferenceResponse.date_created
    });

  } catch (error) {
    console.error('❌ Erro preferência básica:', error);
    res.status(500).json({ 
      success: false,
      error: error.message 
    });
  }
}