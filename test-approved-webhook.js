// Teste webhook com payment ID aprovado
const paymentId = '126096480102'; // Este está APROVADO!

console.log('🎉 Testando webhook com payment APROVADO:', paymentId);

async function testApprovedWebhook() {
  try {
    // Simular notificação do MP
    const payload = {
      type: 'payment',
      action: 'payment.updated',
      data: {
        id: paymentId
      }
    };

    console.log('📦 Enviando payload para webhook:', payload);

    const response = await fetch('https://pdv-allimport.vercel.app/api/mp/webhook', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    console.log('📡 Status da resposta do webhook:', response.status);
    const result = await response.json();
    console.log('📋 Resposta do webhook:', result);

    // Verificar detalhes do pagamento
    console.log('\n🔍 Verificando pagamento...');
    const MP_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
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
      console.log('  - Status Detail:', payment.status_detail);
      console.log('  - Company ID (metadata):', payment.metadata?.company_id);
      console.log('  - User Email (metadata):', payment.metadata?.user_email);
      
      if (payment.status === 'approved') {
        console.log('\n🎯 PAGAMENTO APROVADO!');
        console.log('✅ O webhook DEVE ter processado este pagamento');
        console.log('✅ Se company_id for email, RPC deve ter encontrado/criado assinatura');
      }
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testApprovedWebhook();