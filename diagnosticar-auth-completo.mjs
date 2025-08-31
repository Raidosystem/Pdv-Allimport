// Script para diagnosticar problemas de autenticação
import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

dotenv.config()

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente Supabase não encontradas')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

console.log('🔍 DIAGNÓSTICO COMPLETO DE AUTENTICAÇÃO\n')

async function diagnosticarAuth() {
  try {
    console.log('1️⃣ Testando conexão com Supabase...')
    
    // Testar conexão básica
    const { data: healthCheck, error: healthError } = await supabase
      .from('produtos')
      .select('count(*)', { count: 'exact', head: true })
    
    if (healthError) {
      console.log('❌ Erro na conexão:', healthError.message)
      if (healthError.message.includes('permission denied')) {
        console.log('✅ RLS está funcionando (bloqueando acesso anônimo)')
      }
    } else {
      console.log('⚠️ Conexão OK - mas RLS pode não estar ativo')
    }

    console.log('\n2️⃣ Testando login com assistenciaallimport10@gmail.com...')
    
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email: 'assistenciaallimport10@gmail.com',
      password: 'Allplay123@'
    })

    if (loginError) {
      console.log('❌ Erro de login:', loginError.message)
      return
    }

    console.log('✅ Login realizado com sucesso!')
    console.log('👤 Usuário:', loginData.user.email)
    console.log('🆔 UUID:', loginData.user.id)
    console.log('🔑 Session válida até:', new Date(loginData.session.expires_at * 1000).toLocaleString('pt-BR'))

    const expectedUUID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    if (loginData.user.id === expectedUUID) {
      console.log('✅ UUID confere com o esperado!')
    } else {
      console.log('⚠️ UUID DIFERENTE do esperado!')
      console.log('   Esperado:', expectedUUID)
      console.log('   Recebido:', loginData.user.id)
    }

    console.log('\n3️⃣ Testando acesso aos produtos...')
    
    const { data: produtos, error: produtosError } = await supabase
      .from('produtos')
      .select('*')
      .limit(5)

    if (produtosError) {
      console.log('❌ Erro ao buscar produtos:', produtosError.message)
    } else {
      console.log(`✅ Encontrados ${produtos.length} produtos`)
      if (produtos.length > 0) {
        console.log('📦 Exemplo de produto:', produtos[0].nome)
      }
    }

    console.log('\n4️⃣ Testando acesso aos clientes...')
    
    const { data: clientes, error: clientesError } = await supabase
      .from('clientes')
      .select('*')
      .limit(5)

    if (clientesError) {
      console.log('❌ Erro ao buscar clientes:', clientesError.message)
    } else {
      console.log(`✅ Encontrados ${clientes.length} clientes`)
      if (clientes.length > 0) {
        console.log('👤 Exemplo de cliente:', clientes[0].nome)
      }
    }

    console.log('\n5️⃣ Fazendo logout...')
    await supabase.auth.signOut()
    console.log('✅ Logout realizado')

    console.log('\n🎯 CONCLUSÃO:')
    console.log('- Se login funcionou e UUID confere: problema é no frontend')
    console.log('- Se UUID é diferente: conta errada está sendo usada')
    console.log('- Se produtos/clientes foram encontrados: RLS + autenticação OK')

  } catch (error) {
    console.error('💥 Erro geral:', error.message)
  }
}

diagnosticarAuth()
