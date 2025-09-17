// API para verificar status detalhado da conta MP
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    // 1. Verificar dados do usuário
    const userResponse = await fetch('https://api.mercadopago.com/users/me', {
      headers: { 'Authorization': `Bearer ${MP_ACCESS_TOKEN}` }
    });
    
    if (!userResponse.ok) {
      throw new Error(`User API error: ${userResponse.status}`);
    }
    
    const userData = await userResponse.json();
    
    // 2. Verificar configurações de checkout
    const checkoutResponse = await fetch(`https://api.mercadopago.com/checkout/preferences/test`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        items: [
          {
            title: 'Teste de Configuração',
            unit_price: 1.00,
            quantity: 1
          }
        ]
      })
    });

    let checkoutStatus = 'unknown';
    let checkoutError = null;
    
    if (checkoutResponse.ok) {
      checkoutStatus = 'working';
    } else {
      const errorText = await checkoutResponse.text();
      checkoutStatus = 'error';
      checkoutError = {
        status: checkoutResponse.status,
        message: errorText
      };
    }

    res.status(200).json({
      success: true,
      account: {
        id: userData.id,
        email: userData.email,
        site_id: userData.site_id,
        country_id: userData.country_id,
        status: userData.status,
        verification_status: userData.identification?.type || 'not_verified'
      },
      checkout: {
        status: checkoutStatus,
        error: checkoutError
      },
      environment: {
        is_test: MP_ACCESS_TOKEN.includes('TEST'),
        token_type: MP_ACCESS_TOKEN.split('-')[0]
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro no diagnóstico:', error);
    
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}