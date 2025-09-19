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
    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "process.env.VITE_SUPABASE_URL";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    console.log('🔧 Testando função RPC activate_subscription_after_payment');
    
    // Chamar função de ativação de assinatura
    const rpcResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_SERVICE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_email: 'novaradiosystem@outlook.com',
        payment_id: '126571358908',
        payment_method: 'pix'
      })
    });

    const responseText = await rpcResponse.text();
    
    console.log("📡 RPC response status:", rpcResponse.status);
    console.log("📡 RPC response text:", responseText);
    
    let result;
    try {
      result = JSON.parse(responseText);
    } catch (parseError) {
      result = { error: 'Failed to parse response', responseText };
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      rpcStatus: rpcResponse.status,
      rpcStatusText: rpcResponse.statusText,
      rpcOk: rpcResponse.ok,
      result: result,
      rawResponse: responseText,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Test RPC error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}