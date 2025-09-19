export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const MP_ACCESS_TOKEN = process.env.VITE_MP_ACCESS_TOKEN || 'process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN';
    
    // Teste direto com a API do MercadoPago
    console.log('Testing MP API with token:', MP_ACCESS_TOKEN?.substring(0, 10) + '...');
    
    const mpResponse = await fetch('https://api.mercadopago.com/users/me', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    const responseText = await mpResponse.text();
    console.log('MP Response status:', mpResponse.status);
    console.log('MP Response:', responseText.substring(0, 200));
    
    if (mpResponse.ok) {
      const userData = JSON.parse(responseText);
      res.status(200).json({
        success: true,
        message: 'MercadoPago API working!',
        mp_user_id: userData.id,
        mp_status: userData.status,
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(500).json({
        success: false,
        error: `MercadoPago API returned ${mpResponse.status}`,
        response: responseText,
        timestamp: new Date().toISOString()
      });
    }
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}