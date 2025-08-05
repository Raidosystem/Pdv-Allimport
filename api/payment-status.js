export default async function handler(req, res) {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { paymentId } = req.query;

    if (!paymentId) {
      return res.status(400).json({ error: 'Payment ID is required' });
    }

    // Credenciais do Mercado Pago
    const accessToken = process.env.MP_ACCESS_TOKEN;
    
    if (!accessToken) {
      console.error('❌ MP_ACCESS_TOKEN não configurado');
      return res.status(500).json({ error: 'Mercado Pago not configured' });
    }

    console.log(`🔍 Verificando status do pagamento: ${paymentId}`);

    // Fazer requisição para a API do Mercado Pago
    const response = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('❌ Erro na API do Mercado Pago:', response.status, errorText);
      return res.status(response.status).json({ 
        error: 'Mercado Pago API error',
        details: errorText 
      });
    }

    const paymentData = await response.json();
    console.log('✅ Status do pagamento:', paymentData.status);

    // Retornar status do pagamento
    res.status(200).json({
      payment_id: paymentData.id,
      status: paymentData.status,
      approved: paymentData.status === 'approved',
      status_detail: paymentData.status_detail
    });

  } catch (error) {
    console.error('❌ Erro ao verificar status do pagamento:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
}
