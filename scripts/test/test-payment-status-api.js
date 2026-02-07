// Teste da API payment-status
async function testPaymentStatusAPI() {
  try {
    const paymentId = '126096480102';
    
    console.log('🧪 Testando API payment-status...');
    console.log('Payment ID:', paymentId);
    
    // Testar no Vercel
    console.log('\n📡 Testando no Vercel...');
    const vercelResponse = await fetch(`https://pdv-allimport.vercel.app/api/payment-status?paymentId=${paymentId}`);
    console.log('Status Vercel:', vercelResponse.status);
    
    if (vercelResponse.ok) {
      const vercelData = await vercelResponse.json();
      console.log('✅ Resposta Vercel:', vercelData);
    } else {
      const vercelError = await vercelResponse.text();
      console.log('❌ Erro Vercel:', vercelError);
    }
    
    // Testar diretamente no MP
    console.log('\n📡 Testando diretamente no MP...');
    const mpResponse = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: {
        'Authorization': 'Bearer process.env.MP_ACCESS_TOKEN || process.env.VITE_MP_ACCESS_TOKEN'
      }
    });
    
    console.log('Status MP:', mpResponse.status);
    if (mpResponse.ok) {
      const mpData = await mpResponse.json();
      console.log('✅ Resposta MP:', {
        id: mpData.id,
        status: mpData.status,
        status_detail: mpData.status_detail,
        approved: mpData.status === 'approved'
      });
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testPaymentStatusAPI();