// Teste webhook com payment ID que tem metadata correto
const paymentId = '125543848657'; // Novo payment com metadata correto

console.log('🧪 Testando webhook com payment ID corrigido:', paymentId);

async function testWebhookFixed() {
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

    // Buscar detalhes do pagamento
    const MP_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';
    
    console.log('\n🔍 Buscando detalhes do pagamento...');
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
      console.log('  - Company ID (metadata):', payment.metadata?.company_id);
      console.log('  - User Email (metadata):', payment.metadata?.user_email);
      console.log('  - Payment Type (metadata):', payment.metadata?.payment_type);
      
      if (payment.status === 'pending') {
        console.log('\n⚠️  Status ainda é "pending"');
        console.log('💡 O webhook só processa pagamentos "approved"');
        console.log('🎯 Para testar, precisaríamos simular pagamento "approved"');
        
        console.log('\n📝 O que acontecerá quando o pagamento for aprovado:');
        console.log('1. Webhook receberá notificação com status "approved"');
        console.log('2. Buscará metadata: company_id = "teste@pdvallimport.com"');
        console.log('3. RPC buscará na tabela subscriptions pelo email');
        console.log('4. Se encontrar, estenderá +30 dias');
        console.log('5. Status mudará para "active" e payment_status para "paid"');
      }
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testWebhookFixed();