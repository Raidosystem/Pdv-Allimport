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
    const SUPABASE_SERVICE_KEY_ALT = process.env.SUPABASE_SERVICE_KEY;
    
    // Debug das variáveis
    const debug = {
      url: SUPABASE_URL,
      hasServiceKey: !!SUPABASE_SERVICE_KEY,
      hasServiceKeyAlt: !!SUPABASE_SERVICE_KEY_ALT,
      serviceKeyPrefix: SUPABASE_SERVICE_KEY ? SUPABASE_SERVICE_KEY.substring(0, 20) + '...' : 'NOT_FOUND',
      serviceKeyAltPrefix: SUPABASE_SERVICE_KEY_ALT ? SUPABASE_SERVICE_KEY_ALT.substring(0, 20) + '...' : 'NOT_FOUND',
      allEnvVars: Object.keys(process.env).filter(k => k.includes('SUPABASE')),
      timestamp: new Date().toISOString()
    };

    // Teste simples no Supabase com as duas chaves
    const testResponse1 = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?select=email&limit=1`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Accept': 'application/json'
      }
    });

    const testResult1 = {
      name: 'SUPABASE_SERVICE_ROLE_KEY',
      status: testResponse1.status,
      statusText: testResponse1.statusText,
      ok: testResponse1.ok
    };

    if (testResponse1.ok) {
      testResult1.data = await testResponse1.json();
    } else {
      testResult1.error = await testResponse1.text();
    }

    const testResponse2 = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?select=email&limit=1`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY_ALT,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY_ALT}`,
        'Accept': 'application/json'
      }
    });

    const testResult2 = {
      name: 'SUPABASE_SERVICE_KEY',
      status: testResponse2.status,
      statusText: testResponse2.statusText,
      ok: testResponse2.ok
    };

    if (testResponse2.ok) {
      testResult2.data = await testResponse2.json();
    } else {
      testResult2.error = await testResponse2.text();
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      debug,
      tests: [testResult1, testResult2]
    });

  } catch (error) {
    console.error('Debug error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}