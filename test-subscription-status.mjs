import { supabase } from './src/lib/supabase.js'

async function testSubscriptionStatus() {
  console.log('🧪 TESTANDO STATUS DA ASSINATURA')
  console.log('==================================')
  
  try {
    // Testar com diferentes emails
    const testEmails = [
      'novaradiosystem@outlook.com', // Admin
      'cristiano@exemplo.com', // Se você usou este email
      'seu-email@aqui.com' // Substitua pelo seu email
    ]
    
    for (const email of testEmails) {
      console.log(`\n📧 Testando: ${email}`)
      
      const { data, error } = await supabase.rpc('check_subscription_status', {
        user_email: email
      })
      
      if (error) {
        console.error(`❌ Erro: ${error.message}`)
      } else {
        console.log(`✅ Status:`, JSON.stringify(data, null, 2))
        
        if (data.status === 'active' && !data.days_remaining) {
          console.log('🐛 PROBLEMA CONFIRMADO: days_remaining não está sendo retornado para assinaturas ativas!')
        } else if (data.days_remaining) {
          console.log(`✅ Days remaining funcionando: ${data.days_remaining} dias`)
        }
      }
    }
    
    console.log('\n🔧 PARA CORRIGIR:')
    console.log('1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql')
    console.log('2. Execute o SQL do arquivo fix-days-remaining.sql')
    console.log('3. Recarregue a página do sistema')
    
  } catch (error) {
    console.error('❌ Erro geral:', error)
  }
}

testSubscriptionStatus()
