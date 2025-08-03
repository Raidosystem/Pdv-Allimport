import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function forceEmailCleanAndResend() {
  const problemEmail = 'assistenciaallimport10@gmail.com'
  
  console.log('🔧 DIAGNÓSTICO AVANÇADO DE EMAIL')
  console.log('================================')
  console.log(`📧 Email: ${problemEmail}`)
  console.log('')

  try {
    // 1. Fazer logout completo
    console.log('🔓 Fazendo logout completo...')
    await supabase.auth.signOut()
    
    // 2. Tentar múltiplas tentativas de reenvio
    console.log('📤 Tentativa 1: Reenvio direto...')
    let { error: resend1 } = await supabase.auth.resend({
      type: 'signup',
      email: problemEmail,
      options: {
        emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
      }
    })
    
    if (resend1) {
      console.log(`❌ Tentativa 1 falhou: ${resend1.message}`)
      
      // 3. Se falhou, pode ser que o usuário não existe mais
      console.log('👤 Tentativa 2: Criar usuário novamente...')
      const { data: newUser, error: signupError } = await supabase.auth.signUp({
        email: problemEmail,
        password: 'NovaSenh@2025!',
        options: {
          emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email',
          data: {
            name: 'Assistência Allimport',
            created_at: new Date().toISOString()
          }
        }
      })
      
      if (signupError) {
        console.log(`❌ Tentativa 2 falhou: ${signupError.message}`)
        
        if (signupError.message.includes('already registered')) {
          console.log('🔄 Tentativa 3: Forçar reenvio para usuário existente...')
          
          const { error: forceResend } = await supabase.auth.resend({
            type: 'signup',
            email: problemEmail,
            options: {
              emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
            }
          })
          
          if (forceResend) {
            console.log(`❌ Tentativa 3 falhou: ${forceResend.message}`)
          } else {
            console.log('✅ Tentativa 3: Email reenviado com sucesso!')
          }
        }
      } else {
        console.log('✅ Tentativa 2: Novo usuário criado!')
        console.log(`🆔 ID: ${newUser.user?.id}`)
        console.log(`📧 Email: ${newUser.user?.email}`)
      }
    } else {
      console.log('✅ Tentativa 1: Email reenviado com sucesso!')
    }
    
    // 4. Verificar diferentes configurações de URL
    console.log('')
    console.log('🔍 TESTANDO DIFERENTES URLs DE REDIRECIONAMENTO:')
    
    const redirectUrls = [
      'https://pdv-allimport.vercel.app/confirm-email',
      'https://pdv-allimport.vercel.app/',
      'https://pdv-allimport.vercel.app/dashboard'
    ]
    
    for (let i = 0; i < redirectUrls.length; i++) {
      const url = redirectUrls[i]
      console.log(`🔗 Testando URL ${i + 1}: ${url}`)
      
      const { error: testError } = await supabase.auth.resend({
        type: 'signup',
        email: problemEmail,
        options: {
          emailRedirectTo: url
        }
      })
      
      if (testError) {
        console.log(`   ❌ Falhou: ${testError.message}`)
      } else {
        console.log(`   ✅ Sucesso!`)
      }
      
      // Pequena pausa entre tentativas
      await new Promise(resolve => setTimeout(resolve, 1000))
    }
    
    // 5. Verificar se há problemas com o provedor de email
    console.log('')
    console.log('📊 DIAGNÓSTICO FINAL:')
    console.log('• Múltiplas tentativas de envio realizadas')
    console.log('• Diferentes URLs de redirecionamento testadas')
    console.log('• Email pode estar em quarentena ou bloqueado')
    console.log('')
    console.log('🎯 SOLUÇÕES ALTERNATIVAS:')
    console.log('1. Verifique pasta de spam/lixo eletrônico')
    console.log('2. Aguarde até 10 minutos para entrega')
    console.log('3. Teste com email alternativo (@outlook.com, @yahoo.com)')
    console.log('4. Verifique se Gmail não está bloqueando')
    console.log('5. Configure SMTP customizado no Supabase')

  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

// Executar diagnóstico
forceEmailCleanAndResend()
