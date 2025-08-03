import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testAlternativeEmails() {
  console.log('🧪 TESTE COM EMAILS ALTERNATIVOS')
  console.log('=================================')
  console.log('')

  // Lista de emails de teste para verificar se o problema é específico do Gmail
  const testEmails = [
    'teste.pdv@outlook.com',
    'pdv.teste@yahoo.com', 
    'allimport.test@hotmail.com'
  ]

  for (const email of testEmails) {
    console.log(`📧 Testando: ${email}`)
    
    try {
      const { data, error } = await supabase.auth.signUp({
        email: email,
        password: 'TestePDV2025!',
        options: {
          emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email',
          data: {
            name: 'Teste PDV',
            provider: email.split('@')[1]
          }
        }
      })

      if (error) {
        if (error.message.includes('already registered')) {
          console.log(`   ✅ Email já registrado - tentando reenvio...`)
          
          const { error: resendError } = await supabase.auth.resend({
            type: 'signup',
            email: email,
            options: {
              emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
            }
          })
          
          if (resendError) {
            console.log(`   ❌ Falha no reenvio: ${resendError.message}`)
          } else {
            console.log(`   ✅ Reenvio realizado com sucesso!`)
          }
        } else {
          console.log(`   ❌ Erro: ${error.message}`)
        }
      } else {
        console.log(`   ✅ Usuário criado - ID: ${data.user?.id?.substring(0, 8)}...`)
        console.log(`   📬 Email de confirmação enviado!`)
      }
      
    } catch (err) {
      console.log(`   ❌ Erro inesperado: ${err.message}`)
    }
    
    console.log('')
    // Pausa entre testes
    await new Promise(resolve => setTimeout(resolve, 1500))
  }

  console.log('🎯 TESTE ESPECÍFICO GMAIL:')
  console.log('O problema pode ser específico do Gmail. Possíveis causas:')
  console.log('• Gmail está classificando emails do Supabase como spam')
  console.log('• Filtros de segurança do Gmail muito restritivos')
  console.log('• Problema de reputação do domínio do Supabase')
  console.log('• Rate limiting por muitas tentativas')
  console.log('')
  
  console.log('💡 SOLUÇÕES RECOMENDADAS:')
  console.log('1. Aguarde 15-30 minutos e verifique novamente')
  console.log('2. Adicione noreply@supabase.io à lista de contatos')
  console.log('3. Verifique as configurações de filtro do Gmail')
  console.log('4. Use email alternativo temporariamente')
  console.log('5. Configure SMTP personalizado no Supabase')
}

// Executar teste
testAlternativeEmails()
