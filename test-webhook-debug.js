// Teste do webhook com logs detalhados
const paymentId = process.argv[2] || '126092291960'; // PIX que criamos recentemente

console.log('🧪 Testando webhook com payment ID:', paymentId);

async function testWebhook() {
  try {
    // Simular notificação do MP
    const payload = {
      type: 'payment',
      action: 'payment.updated',
      data: {
        id: paymentId
      }
    };

    console.log('📦 Enviando payload:', payload);

    const response = await fetch('https://pdv-allimport.vercel.app/api/mp/webhook', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    console.log('📡 Status da resposta:', response.status);
    const result = await response.json();
    console.log('📋 Resposta completa:', result);

    // Agora vamos buscar o pagamento diretamente da API MP para ver se tem metadata
    const MP_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    console.log('\n🔍 Buscando detalhes do pagamento na API MP...');
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': `Bearer ${MP_TOKEN}`
      }
    });

    if (mpResponse.ok) {
      const payment = await mpResponse.json();
      console.log('💳 Payment details:');
      console.log('  - ID:', payment.id);
      console.log('  - Status:', payment.status);
      console.log('  - Date:', payment.date_created);
      console.log('  - Metadata:', payment.metadata);
      console.log('  - External Reference:', payment.external_reference);
      console.log('  - Description:', payment.description);
      console.log('  - Payer Email:', payment.payer?.email);
    } else {
      console.log('❌ Erro ao buscar pagamento:', mpResponse.status);
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testWebhook();