// Verificar configuração do webhook no MercadoPago
export default async function handler(req, res) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({});
  }

  try {
    const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || "process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN";
    
    // Buscar aplicações (webhooks configurados)
    const response = await fetch('https://api.mercadopago.com/applications', {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`MP API error: ${response.status}`);
    }

    const applications = await response.json();

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      applications: applications,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('MP Applications error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}