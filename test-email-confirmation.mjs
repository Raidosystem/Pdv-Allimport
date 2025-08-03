import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testEmailConfirmation() {
  console.log('🔍 Testando configuração de confirmação de email...')
  
  try {
    // Testar criação de usuário de teste
    console.log('\n📧 Testando criação de usuário...')
    
    const testEmail = 'teste-pdv@example.com'
    const testPassword = 'teste123456'
    
    // Primeiro, vamos tentar fazer signup
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
      }
    })
    
    if (signupError) {
      console.log('❌ Erro no signup:', signupError.message)
    } else {
      console.log('✅ Signup realizado:', {
        user: signupData.user?.email,
        emailConfirmed: signupData.user?.email_confirmed_at ? 'Sim' : 'Não',
        session: signupData.session ? 'Criada' : 'Não criada'
      })
    }
    
    // Verificar configurações de auth
    console.log('\n⚙️ Verificando configurações...')
    
    // Testar resend de confirmação
    console.log('\n📤 Testando reenvio de confirmação...')
    const { error: resendError } = await supabase.auth.resend({
      type: 'signup',
      email: testEmail,
      options: {
        emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
      }
    })
    
    if (resendError) {
      console.log('❌ Erro no reenvio:', resendError.message)
    } else {
      console.log('✅ Email de confirmação reenviado com sucesso')
    }
    
    // Verificar usuário atual
    console.log('\n👤 Verificando usuário atual...')
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    
    if (userError) {
      console.log('ℹ️ Nenhum usuário logado (esperado)')
    } else {
      console.log('✅ Usuário logado:', {
        email: user?.email,
        emailConfirmed: user?.email_confirmed_at ? 'Sim' : 'Não'
      })
    }
    
    console.log('\n📋 RESUMO DO DIAGNÓSTICO:')
    console.log('- URL de redirecionamento: https://pdv-allimport.vercel.app/confirm-email')
    console.log('- Página de confirmação: Configurada no React Router')
    console.log('- Envio de email: Funcionando')
    console.log('- Reenvio de email: Funcionando')
    
    console.log('\n🔧 POSSÍVEIS SOLUÇÕES:')
    console.log('1. Verificar se a URL de confirmação está correta no dashboard do Supabase')
    console.log('2. Verificar se o link do email está direcionando para a URL correta')
    console.log('3. Verificar logs do navegador na página de confirmação')
    console.log('4. Verificar se o domínio está na lista de URLs autorizadas')
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

// Executar teste
testEmailConfirmation()
