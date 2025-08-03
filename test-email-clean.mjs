import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testEmailConfirmation() {
  const testEmail = 'assistenciaallimport10@gmail.com'
  
  console.log('🧪 TESTE DE CONFIRMAÇÃO DE EMAIL')
  console.log('================================')
  console.log(`📧 Email: ${testEmail}`)
  console.log('')

  try {
    // 1. Primeiro fazer logout de qualquer sessão existente
    await supabase.auth.signOut()
    
    // 2. Tentar criar novo usuário
    console.log('👤 Criando novo usuário...')
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: testEmail,
      password: 'MinhaNovaSenh@123',
      options: {
        emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email',
        data: {
          name: 'Assistência Allimport'
        }
      }
    })

    if (signupError) {
      console.log(`❌ Erro no signup: ${signupError.message}`)
      
      if (signupError.message.includes('already registered')) {
        console.log('')
        console.log('🔄 Tentando reenviar confirmação...')
        
        const { error: resendError } = await supabase.auth.resend({
          type: 'signup',
          email: testEmail,
          options: {
            emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
          }
        })
        
        if (resendError) {
          console.log(`❌ Erro no reenvio: ${resendError.message}`)
        } else {
          console.log('✅ Email de confirmação reenviado!')
          console.log('📬 Verifique sua caixa de entrada')
        }
      }
    } else {
      console.log('✅ Usuário criado com sucesso!')
      console.log(`📧 Email: ${signupData.user?.email}`)
      console.log(`🆔 ID: ${signupData.user?.id}`)
      console.log(`📅 Criado em: ${signupData.user?.created_at}`)
      console.log(`✉️ Email confirmado: ${signupData.user?.email_confirmed_at ? 'Sim' : 'Não'}`)
      console.log('')
      console.log('📬 Verifique sua caixa de entrada para o email de confirmação!')
    }

    // 3. Verificar configurações
    console.log('')
    console.log('⚙️ CONFIGURAÇÕES ATUAIS:')
    console.log('🔗 URL de confirmação: https://pdv-allimport.vercel.app/confirm-email')
    console.log('🌐 Domínio: pdv-allimport.vercel.app')
    console.log('')
    console.log('📋 PRÓXIMOS PASSOS:')
    console.log('1. Verifique sua caixa de entrada (inclusive spam)')
    console.log('2. Procure por email do Supabase')
    console.log('3. Clique no link de confirmação')
    console.log('4. Deve redirecionar para o dashboard automaticamente')
    console.log('')
    console.log('🔧 Se não receber o email:')
    console.log('1. Verifique as configurações no Dashboard do Supabase')
    console.log('2. Confirme que o SMTP está funcionando')
    console.log('3. Execute o reenvio de confirmação')

  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

// Executar teste
testEmailConfirmation()
