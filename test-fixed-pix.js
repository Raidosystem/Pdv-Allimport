// Teste PIX com metadata corrigido (email completo)
const MP_ACCESS_TOKEN = 'APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193';

async function testFixedPix() {
  try {
    console.log('🧪 Testando PIX com metadata corrigido...');
    
    const response = await fetch('https://pdv-allimport.vercel.app/api/pix', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        amount: 59.90,
        description: 'Assinatura PDV Allimport - Teste Corrigido',
        email: 'teste@pdvallimport.com',
        company_id: 'teste@pdvallimport.com', // Agora usando email completo
        user_id: 'teste-user'
      })
    });

    if (response.ok) {
      const result = await response.json();
      console.log('✅ PIX criado com sucesso:', result);
      
      if (result.payment_id) {
        console.log(`🎯 Payment ID: ${result.payment_id}`);
        
        // Verificar metadata do pagamento
        console.log('\n🔍 Verificando metadata do pagamento...');
        const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${result.payment_id}`, {
          headers: {
            'Authorization': `Bearer ${MP_ACCESS_TOKEN}`
          }
        });

        if (mpResponse.ok) {
          const payment = await mpResponse.json();
          console.log('📋 Metadata do pagamento:');
          console.log('  - Company ID:', payment.metadata?.company_id);
          console.log('  - User Email:', payment.metadata?.user_email);
          console.log('  - Payment Type:', payment.metadata?.payment_type);
          console.log('  - Status:', payment.status);
          
          if (payment.metadata?.company_id?.includes('@')) {
            console.log('✅ Metadata corrigido! Agora usa email completo');
          } else {
            console.log('❌ Metadata ainda incorreto');
          }
        }
      }
    } else {
      console.error('❌ Erro ao criar PIX:', await response.text());
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testFixedPix();