// Teste forçando processamento de pagamento pending
const paymentId = process.argv[2] || '126092291960';

console.log('🧪 Testando RPC diretamente com payment pending:', paymentId);

async function testRPCDirect() {
  try {
    const SUPABASE_URL = "https://kmcaaqetxtwkdcczdomw.supabase.co";
    // Precisa da service key para testar RPC
    console.log('⚠️  Para testar RPC diretamente, precisaríamos da SUPABASE_SERVICE_KEY');
    console.log('Vamos simular o que aconteceria...');

    // Simular dados do pagamento
    const mockPaymentData = {
      id: parseInt(paymentId),
      status: 'approved', // Simular como se fosse aprovado
      metadata: {
        company_id: 'test-company-123',
        user_email: 'teste@pdvallimport.com',
        payment_type: 'subscription'
      }
    };

    console.log('📝 Dados simulados:', mockPaymentData);
    console.log('🔍 O RPC tentaria:');
    console.log('  1. Buscar subscriptions com email "teste@pdvallimport.com"');
    console.log('  2. Se encontrar, estender +30 dias');
    console.log('  3. Marcar status como "active" e payment_status como "paid"');

    // Vamos ver se o email existe no banco
    console.log('\n🔍 Para verificar se o email existe no banco, vamos usar uma query segura...');

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testRPCDirect();