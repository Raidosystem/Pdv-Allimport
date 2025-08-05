// PIX Payment endpoint for Vercel
export default async function handler(req, res) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { amount, description, email } = req.body;

    if (!amount || !description) {
      res.status(400).json({ error: 'Amount and description are required' });
      return;
    }

    // Configuração do pagamento PIX
    const paymentData = {
      transaction_amount: Number(amount),
      description: description,
      payment_method_id: 'pix',
      payer: {
        email: email || 'cliente@pdvallimport.com',
        first_name: 'Cliente',
        last_name: 'PDV'
      }
    };

    // Fazer chamada para API do Mercado Pago
    const response = await fetch('https://api.mercadopago.com/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
        'X-Idempotency-Key': Date.now().toString()
      },
      body: JSON.stringify(paymentData)
    });

    if (!response.ok) {
      throw new Error(`Mercado Pago API error: ${response.status}`);
    }

    const paymentResponse = await response.json();

    // Salvar no Supabase usando fetch
    try {
      const supabaseResponse = await fetch(`${process.env.SUPABASE_URL}/rest/v1/payments`, {
        method: 'POST',
        headers: {
          'apikey': process.env.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${process.env.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        },
        body: JSON.stringify({
          payment_id: paymentResponse.id,
          amount: paymentResponse.transaction_amount,
          status: paymentResponse.status,
          payment_type: 'pix',
          qr_code: paymentResponse.point_of_interaction?.transaction_data?.qr_code,
          qr_code_base64: paymentResponse.point_of_interaction?.transaction_data?.qr_code_base64,
          ticket_url: paymentResponse.point_of_interaction?.transaction_data?.ticket_url,
          created_at: new Date().toISOString()
        })
      });
    } catch (supabaseError) {
      console.error('Supabase error:', supabaseError);
      // Continue mesmo se Supabase falhar
    }

    res.status(200).json({
      success: true,
      payment_id: paymentResponse.id,
      status: paymentResponse.status,
      qr_code: paymentResponse.point_of_interaction?.transaction_data?.qr_code,
      qr_code_base64: paymentResponse.point_of_interaction?.transaction_data?.qr_code_base64,
      ticket_url: paymentResponse.point_of_interaction?.transaction_data?.ticket_url
    });

  } catch (error) {
    console.error('PIX payment error:', error);
    res.status(500).json({ 
      error: 'Failed to create PIX payment',
      details: error.message 
    });
  }
}
