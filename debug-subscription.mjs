// Teste direto da API de status da assinatura
async function testStatusAPI() {
  console.log('🧪 TESTANDO API DE STATUS DIRETAMENTE')
  console.log('====================================')
  
  const testUrl = 'https://pdv-allimport.vercel.app'
  
  try {
    // Fazer uma requisição para a API de health primeiro
    console.log('📡 Testando conectividade...')
    const healthResponse = await fetch(`${testUrl}/api/health`)
    const healthData = await healthResponse.json()
    console.log('✅ API Health:', healthData.status)
    
    // O teste da assinatura precisa ser feito dentro da aplicação
    // por isso vamos criar um método para depuração
    console.log('')
    console.log('🔧 PARA DEBUGAR O PROBLEMA:')
    console.log('')
    console.log('1. Acesse o sistema: https://pdv-allimport.vercel.app')
    console.log('2. Faça login com sua conta')
    console.log('3. Abra o DevTools (F12)')
    console.log('4. Vá para a aba Console')
    console.log('5. Execute o comando:')
    console.log('')
    console.log('   // Verificar dados da assinatura')
    console.log('   console.log("Status:", window.subscriptionData);')
    console.log('')
    console.log('6. Verifique se days_remaining está presente')
    console.log('')
    console.log('🎯 CORREÇÃO NECESSÁRIA:')
    console.log('Execute o SQL no Supabase Dashboard conforme instruções anteriores.')
    
  } catch (error) {
    console.error('❌ Erro:', error.message)
  }
}

testStatusAPI()
