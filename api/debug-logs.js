export default async function handler(req, res) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({});
  }

  const { paymentId } = req.query;

  try {
    // Buscar informações no Supabase primeiro
    const supabaseResponse = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/subscriptions?select=*&payment_id=eq.${paymentId}`, {
      headers: {
        'apikey': process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      }
    });

    const supabaseData = await supabaseResponse.json();

    // Verificar logs de webhook
    const webhookResponse = await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/webhook_logs?select=*&payment_id=eq.${paymentId}&order=created_at.desc&limit=5`, {
      headers: {
        'apikey': process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      }
    });

    const webhookLogs = await webhookResponse.json();

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      paymentId,
      supabaseRecords: supabaseData,
      webhookLogs: webhookLogs,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Debug logs error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      paymentId
    });
  }
}