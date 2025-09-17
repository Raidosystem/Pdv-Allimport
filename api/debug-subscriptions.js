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
    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    // Buscar assinatura por email primeiro
    const emailResponse = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?email=eq.novaradiosystem@outlook.com&select=*`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
      }
    });

    const emailData = await emailResponse.json();

    // Buscar todas as assinaturas para verificar estrutura
    const allResponse = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?select=*&limit=5`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
      }
    });

    const allData = await allResponse.json();

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      email: 'novaradiosystem@outlook.com',
      subscriptionByEmail: emailData,
      allSubscriptions: allData,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Debug subscriptions error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}