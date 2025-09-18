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
    const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || "APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193";
    
    const preferenceId = req.query.preference_id || "167089193-c6044fa1-cb36-4d33-85fc-79054e5ce7ac";
    
    // 1. Buscar detalhes da preferência
    const prefResponse = await fetch(`https://api.mercadopago.com/checkout/preferences/${preferenceId}`, {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    let preference = null;
    if (prefResponse.ok) {
      preference = await prefResponse.json();
    }

    // 2. Buscar pagamentos relacionados a essa preferência
    const searchResponse = await fetch(`https://api.mercadopago.com/v1/payments/search?preference_id=${preferenceId}`, {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    let payments = [];
    if (searchResponse.ok) {
      const searchData = await searchResponse.json();
      payments = searchData.results || [];
    }

    // 3. Buscar merchant_orders relacionadas
    const merchantOrderResponse = await fetch(`https://api.mercadopago.com/merchant_orders/search?preference_id=${preferenceId}`, {
      headers: { 
        'Authorization': `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    let merchantOrders = [];
    if (merchantOrderResponse.ok) {
      const merchantData = await merchantOrderResponse.json();
      merchantOrders = merchantData.results || [];
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      preference_id: preferenceId,
      preference: preference ? {
        id: preference.id,
        external_reference: preference.external_reference,
        notification_url: preference.notification_url,
        metadata: preference.metadata,
        items: preference.items
      } : null,
      payments: payments.map(p => ({
        id: p.id,
        status: p.status,
        status_detail: p.status_detail,
        payment_method: p.payment_method_id,
        amount: p.transaction_amount,
        date_created: p.date_created,
        date_approved: p.date_approved,
        metadata: p.metadata,
        payer_email: p.payer?.email,
        external_reference: p.external_reference
      })),
      merchant_orders: merchantOrders.map(mo => ({
        id: mo.id,
        status: mo.status,
        external_reference: mo.external_reference,
        notification_url: mo.notification_url,
        payments: mo.payments
      })),
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Preference debug error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message
    });
  }
}