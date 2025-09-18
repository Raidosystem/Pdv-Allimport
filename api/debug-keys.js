export default async function handler(req, res) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({});
  }

  try {
    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    // Debug das variáveis
    const debug = {
      url: SUPABASE_URL,
      hasServiceKey: !!SUPABASE_SERVICE_KEY,
      serviceKeyPrefix: SUPABASE_SERVICE_KEY ? SUPABASE_SERVICE_KEY.substring(0, 20) + '...' : 'NOT_FOUND',
      allEnvVars: Object.keys(process.env).filter(k => k.includes('SUPABASE')),
      timestamp: new Date().toISOString()
    };

    // Teste simples no Supabase
    const testResponse = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?select=email&limit=1`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Accept': 'application/json'
      }
    });

    const testResult = {
      status: testResponse.status,
      statusText: testResponse.statusText,
      ok: testResponse.ok
    };

    if (testResponse.ok) {
      testResult.data = await testResponse.json();
    } else {
      testResult.error = await testResponse.text();
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      debug,
      testResult
    });

  } catch (error) {
    console.error('Debug error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}