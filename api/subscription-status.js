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
    const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;
    
    // Usar RPC para verificar status (usa SECURITY DEFINER, passa pela RLS)
    const rpcResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/check_subscription_status`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_email: 'novaradiosystem@outlook.com'
      })
    });

    let subscriptionStatus = null;
    if (rpcResponse.ok) {
      subscriptionStatus = await rpcResponse.json();
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      email: 'novaradiosystem@outlook.com',
      subscriptionStatus: subscriptionStatus,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Subscription status error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}