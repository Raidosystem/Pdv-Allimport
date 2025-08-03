import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function clearUserData() {
  const emailToClean = 'assistenciaallimport10@gmail.com'
  
  console.log('🧹 Iniciando limpeza de dados do usuário...')
  console.log(`📧 Email: ${emailToClean}`)
  console.log('')

  try {
    // 1. Verificar se há dados relacionados ao email nas tabelas do sistema
    console.log('🔍 Verificando dados existentes...')
    
    // Verificar na tabela clientes se existe
    try {
      const { data: clientes, error: clientesError } = await supabase
        .from('clientes')
        .select('*')
        .eq('email', emailToClean)
      
      if (clientesError) {
        console.log('ℹ️ Tabela clientes: Sem acesso ou não existe')
      } else {
        console.log(`📊 Clientes encontrados: ${clientes?.length || 0}`)
        
        if (clientes && clientes.length > 0) {
          console.log('🗑️ Removendo registros da tabela clientes...')
          const { error: deleteError } = await supabase
            .from('clientes')
            .delete()
            .eq('email', emailToClean)
          
          if (deleteError) {
            console.log(`❌ Erro ao deletar clientes: ${deleteError.message}`)
          } else {
            console.log('✅ Registros de clientes removidos')
          }
        }
      }
    } catch (err) {
      console.log('ℹ️ Não foi possível verificar/limpar tabela clientes')
    }

    // 2. Tentar fazer signup novamente para verificar se o email está livre
    console.log('')
    console.log('🔬 Testando disponibilidade do email...')
    
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: emailToClean,
      password: 'teste123456',
      options: {
        emailRedirectTo: 'https://pdv-allimport.vercel.app/confirm-email'
      }
    })

    if (signupError) {
      console.log(`❌ Erro no teste de signup: ${signupError.message}`)
      
      if (signupError.message.includes('already registered')) {
        console.log('')
        console.log('⚠️ O email ainda está registrado no sistema de autenticação.')
        console.log('📋 INSTRUÇÕES PARA LIMPEZA MANUAL:')
        console.log('')
        console.log('1. Acesse o Dashboard do Supabase:')
        console.log('   https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/users')
        console.log('')
        console.log('2. Procure pelo usuário com email: assistenciaallimport10@gmail.com')
        console.log('3. Clique no usuário e selecione "Delete user"')
        console.log('4. Confirme a exclusão')
        console.log('')
        console.log('5. Opcionalmente, vá em SQL Editor e execute:')
        console.log(`   DELETE FROM auth.users WHERE email = '${emailToClean}';`)
        console.log('')
      }
    } else {
      console.log('✅ Email disponível! Novo usuário criado para teste.')
      console.log(`📧 Status: ${signupData.user?.email_confirmed_at ? 'Confirmado' : 'Aguardando confirmação'}`)
      console.log('')
      console.log('🎉 SUCESSO! O email está limpo e pode receber confirmações.')
    }

    // 3. Verificar sessão atual
    console.log('')
    console.log('👤 Verificando sessão atual...')
    const { data: { session } } = await supabase.auth.getSession()
    
    if (session && session.user.email === emailToClean) {
      console.log('🔓 Fazendo logout da sessão atual...')
      await supabase.auth.signOut()
      console.log('✅ Logout realizado')
    } else {
      console.log('ℹ️ Nenhuma sessão ativa para este email')
    }

  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }

  console.log('')
  console.log('🏁 LIMPEZA CONCLUÍDA!')
  console.log('')
  console.log('📋 PRÓXIMOS PASSOS:')
  console.log('1. Se ainda houver problemas, execute a limpeza manual no Dashboard')
  console.log('2. Teste criar nova conta com o email limpo')
  console.log('3. Verifique se os emails de confirmação chegam')
  console.log('')
}

// Executar limpeza
clearUserData()
