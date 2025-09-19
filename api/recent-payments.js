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
    const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    // Buscar últimos pagamentos (últimas 24h)
    const searchResponse = await fetch('https://api.mercadopago.com/v1/payments/search?sort=date_created&criteria=desc&range=date_created&begin_date=NOW-1DAY&end_date=NOW', {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    if (!searchResponse.ok) {
      throw new Error(`MP Search API error: ${searchResponse.status}`);
    }

    const searchData = await searchResponse.json();

    // Filtrar só pagamentos com metadata contendo novaradiosystem
    const recentPayments = searchData.results?.filter(payment => 
      payment.metadata?.user_email?.includes('novaradiosystem') ||
      payment.payer?.email?.includes('novaradiosystem')
    ) || [];

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      total: searchData.paging?.total || 0,
      recentPayments: recentPayments.map(p => ({
        id: p.id,
        status: p.status,
        status_detail: p.status_detail,
        payment_method: p.payment_method_id,
        amount: p.transaction_amount,
        date_created: p.date_created,
        date_approved: p.date_approved,
        metadata: p.metadata,
        payer_email: p.payer?.email
      })),
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Recent payments error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}