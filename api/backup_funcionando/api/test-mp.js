// API para testar credenciais do Mercado Pago
export default async function handler(req, res) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';
    
    console.log('🧪 Testando credenciais MP:', {
      hasToken: !!MP_ACCESS_TOKEN,
      tokenPrefix: MP_ACCESS_TOKEN.substring(0, 20) + '...'
    });

    // Teste simples: buscar informações da conta
    const response = await fetch('https://api.mercadopago.com/users/me', {
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    const responseText = await response.text();
    console.log('🔍 Resposta MP API:', response.status, responseText);

    if (!response.ok) {
      throw new Error(`MP API Error: ${response.status} - ${responseText}`);
    }

    const userData = JSON.parse(responseText);
    
    res.status(200).json({
      success: true,
      message: 'Credenciais do Mercado Pago válidas!',
      account: {
        id: userData.id,
        email: userData.email,
        first_name: userData.first_name,
        last_name: userData.last_name,
        site_id: userData.site_id,
        country_id: userData.country_id
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro no teste MP:', error);
    
    res.status(500).json({
      success: false,
      error: 'Erro ao testar credenciais do Mercado Pago',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
}