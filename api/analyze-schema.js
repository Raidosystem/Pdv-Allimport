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
    const SUPABASE_URL = process.env.SUPABASE_URL || "process.env.SUPABASE_URL";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;
    
    // 1. Verificar estrutura da tabela subscriptions
    const subscriptionsResponse = await fetch(`${SUPABASE_URL}/rest/v1/subscriptions?select=*&limit=1`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Accept': 'application/vnd.pgrst.object+json'
      }
    });

    let subscriptionsStructure = null;
    if (subscriptionsResponse.ok) {
      const data = await subscriptionsResponse.json();
      if (data) {
        subscriptionsStructure = Object.keys(data);
      }
    }

    // 2. Verificar se tabela payments já existe
    const paymentsResponse = await fetch(`${SUPABASE_URL}/rest/v1/payments?select=*&limit=1`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Accept': 'application/vnd.pgrst.object+json'
      }
    });

    let paymentsExists = false;
    let paymentsStructure = null;
    if (paymentsResponse.ok) {
      paymentsExists = true;
      const data = await paymentsResponse.json();
      if (data) {
        paymentsStructure = Object.keys(data);
      }
    }

    // 3. Verificar funções RPC existentes
    const functionsResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_email: 'test@test.com',
        payment_id: 'test',
        payment_method: 'test'
      })
    });

    let currentRpcExists = functionsResponse.status !== 404;

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      currentStructure: {
        subscriptions: {
          exists: subscriptionsResponse.ok,
          columns: subscriptionsStructure,
          status: subscriptionsResponse.status
        },
        payments: {
          exists: paymentsExists,
          columns: paymentsStructure,
          status: paymentsResponse.status
        },
        rpcFunctions: {
          activate_subscription_after_payment: currentRpcExists,
          status: functionsResponse.status
        }
      },
      documentProposal: {
        newTables: ['payments', 'payment_receipts'],
        newRpcFunctions: ['credit_subscription_days'],
        changes: [
          'empresa_id field instead of email',
          'separate payments table',
          'idempotency with payment_receipts',
          'realtime updates'
        ]
      },
      analysis: {
        safe: true, // será calculado baseado na análise
        conflicts: [],
        recommendations: []
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Schema analysis error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}