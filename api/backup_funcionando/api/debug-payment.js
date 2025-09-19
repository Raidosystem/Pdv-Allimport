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
    // Buscar detalhes do pagamento no MercadoPago
    const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN || "process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN";
    
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` }
    });

    if (!mpResponse.ok) {
      throw new Error(`MP API error: ${mpResponse.status}`);
    }

    const payment = await mpResponse.json();

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      paymentId,
      status: payment.status,
      payer: {
        email: payment.payer?.email,
        name: payment.payer?.first_name + ' ' + payment.payer?.last_name
      },
      metadata: payment.metadata,
      amount: payment.transaction_amount,
      payment_method: payment.payment_method_id,
      payment_type: payment.payment_type_id,
      date_approved: payment.date_approved,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Debug payment error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      paymentId
    });
  }
}