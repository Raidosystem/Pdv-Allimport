import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIzOTE4NjQsImV4cCI6MjAzNzk2Nzg2NH0.jhv50IBTW2fLkiaPr6E0I9RxRgXrPHKdktQO8TYxjy4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function createAdminUser() {
  console.log('🔑 Criando usuário administrador...')
  
  try {
    // Tentar criar o usuário admin
    const { data, error } = await supabase.auth.signUp({
      email: 'novaradiosystem@outlook.com',
      password: '@qw12aszx##',
      options: {
        data: {
          full_name: 'Administrador Principal',
          role: 'admin'
        }
      }
    })

    if (error) {
      if (error.message.includes('User already registered')) {
        console.log('✅ Usuário administrador já existe!')
        
        // Testar login
        console.log('🔐 Testando login...')
        const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
          email: 'novaradiosystem@outlook.com',
          password: '@qw12aszx##'
        })
        
        if (loginError) {
          console.error('❌ Erro no login:', loginError.message)
          return false
        } else {
          console.log('✅ Login funcionando perfeitamente!')
          console.log('👤 Usuário:', loginData.user?.email)
          await supabase.auth.signOut()
          return true
        }
      } else {
        console.error('❌ Erro ao criar usuário:', error.message)
        return false
      }
    } else {
      console.log('✅ Usuário administrador criado com sucesso!')
      console.log('📧 Email:', data.user?.email)
      console.log('🆔 ID:', data.user?.id)
      return true
    }
  } catch (err) {
    console.error('❌ Erro inesperado:', err)
    return false
  }
}

async function main() {
  console.log('🚀 Configurando usuário administrador para produção...')
  
  const success = await createAdminUser()
  
  if (success) {
    console.log('\n✅ CONFIGURAÇÃO COMPLETA!')
    console.log('\n📋 Para acessar o painel administrativo:')
    console.log('1. Acesse: https://pdv-allimport.vercel.app/login')
    console.log('2. Email: novaradiosystem@outlook.com')
    console.log('3. Senha: @qw12aszx##')
    console.log('4. Após login, acesse: https://pdv-allimport.vercel.app/admin')
  } else {
    console.log('\n❌ Erro na configuração. Tente novamente.')
  }
}

main()
