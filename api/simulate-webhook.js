// Simular webhook manualmente para pagamento específico
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Aceitar paymentId via query string ou body
    const paymentId = req.query.paymentId || req.body?.paymentId;
    
    if (!paymentId) {
      return res.status(400).json({ error: 'paymentId é obrigatório' });
    }

    console.log(`🔄 Simulando webhook para pagamento ${paymentId}...`);

    // Chamar nossa própria API de webhook
    const webhookResponse = await fetch('https://pdv.crmvsystem.com/api/mp/webhook', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        action: 'payment.updated',
        api_version: 'v1',
        data: {
          id: paymentId
        },
        date_created: new Date().toISOString(),
        id: Date.now(),
        live_mode: true,
        type: 'payment',
        user_id: '167089193'
      })
    });

    const webhookResult = await webhookResponse.text();
    console.log('🔍 Resultado do webhook:', webhookResponse.status, webhookResult);

    if (!webhookResponse.ok) {
      throw new Error(`Webhook failed: ${webhookResponse.status} - ${webhookResult}`);
    }

    res.status(200).json({
      success: true,
      message: `Webhook simulado para pagamento ${paymentId}`,
      webhookStatus: webhookResponse.status,
      webhookResponse: webhookResult,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Erro ao simular webhook:', error);
    
    res.status(500).json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
}