export default async function handler(req, res) {
  const headers = {
    'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (req.method === 'OPTIONS') {
    return res.status(200).setHeader('Access-Control-Allow-Headers', 'Content-Type').json({});
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { payment_id, user_email } = req.body;

    if (!payment_id || !user_email) {
      return res.status(400).json({ 
        error: 'payment_id and user_email are required',
        received: { payment_id, user_email }
      });
    }

    // 1. Buscar detalhes do pagamento no MercadoPago
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${payment_id}`, {
      headers: {
        'Authorization': `Bearer ${process.env.VITE_MP_ACCESS_TOKEN}`,
        'Accept': 'application/json'
      }
    });

    if (!mpResponse.ok) {
      return res.status(400).json({ 
        error: 'Payment not found in MercadoPago',
        payment_id,
        status: mpResponse.status
      });
    }

    const paymentData = await mpResponse.json();

    // 2. Verificar se o pagamento foi aprovado
    const isApproved = paymentData.status === 'approved' || 
                      (paymentData.status === 'accredited' && paymentData.status_detail === 'accredited');

    if (!isApproved) {
      return res.status(400).json({ 
        error: 'Payment is not approved/accredited',
        payment_id,
        status: paymentData.status,
        status_detail: paymentData.status_detail
      });
    }

    // 3. Preparar dados para ativar assinatura
    const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "https://kmcaaqetxtwkdcczdomw.supabase.co";
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY;

    // 4. Chamar a função RPC existente para ativar a assinatura
    const supabaseResponse = await fetch(`${SUPABASE_URL}/rest/v1/rpc/activate_subscription_after_payment`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_email: user_email,
        payment_id: payment_id.toString(),
        payment_method: paymentData.payment_method_id || 'pix'
      })
    });

    let activationResult = null;
    let activationError = null;

    if (supabaseResponse.ok) {
      try {
        activationResult = await supabaseResponse.json();
      } catch (err) {
        activationResult = { success: true, message: 'Subscription activated' };
      }
    } else {
      const errorText = await supabaseResponse.text();
      activationError = errorText;
    }

    res.status(200).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({
      success: true,
      payment: {
        id: paymentData.id,
        status: paymentData.status,
        status_detail: paymentData.status_detail,
        amount: paymentData.transaction_amount,
        payment_method: paymentData.payment_method_id,
        date_approved: paymentData.date_approved,
        payer_email: paymentData.payer?.email
      },
      activation: {
        success: supabaseResponse.ok,
        result: activationResult,
        error: activationError,
        user_email: user_email
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Manual process payment error:', error);
    res.status(500).setHeader('Access-Control-Allow-Origin', headers['Access-Control-Allow-Origin']).json({ 
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}