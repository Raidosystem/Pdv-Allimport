// Script para verificar a estrutura da tabela produtos
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

console.log('🔍 VERIFICANDO ESTRUTURA DA TABELA PRODUTOS\n')

async function verificarEstrutura() {
  try {
    // Fazer login
    console.log('1️⃣ Fazendo login...')
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email: 'assistenciaallimport10@gmail.com',
      password: 'Allplay123@'
    })

    if (loginError) {
      console.log('❌ Erro de login:', loginError.message)
      return
    }

    console.log('✅ Login realizado!')

    // Buscar um produto para ver as colunas disponíveis
    console.log('\n2️⃣ Buscando estrutura das colunas...')
    const { data: produtos, error } = await supabase
      .from('produtos')
      .select('*')
      .limit(1)

    if (error) {
      console.log('❌ Erro ao buscar produtos:', error.message)
      return
    }

    if (produtos && produtos.length > 0) {
      const produto = produtos[0]
      console.log('✅ Produto encontrado!')
      console.log('📋 Colunas disponíveis:')
      
      Object.keys(produto).forEach((coluna, index) => {
        const valor = produto[coluna]
        const tipo = typeof valor
        console.log(`   ${index + 1}. ${coluna} (${tipo}): ${valor}`)
      })

      // Verificar colunas de data específicas
      console.log('\n📅 Colunas que podem ser de data:')
      Object.keys(produto).forEach(coluna => {
        const valor = produto[coluna]
        if (typeof valor === 'string' && (
          coluna.includes('criado') || 
          coluna.includes('created') || 
          coluna.includes('updated') ||
          coluna.includes('atualizado') ||
          coluna.includes('data') ||
          coluna.includes('date') ||
          /\d{4}-\d{2}-\d{2}/.test(valor)
        )) {
          console.log(`   ✅ ${coluna}: ${valor}`)
        }
      })
    } else {
      console.log('❌ Nenhum produto encontrado')
    }

    console.log('\n3️⃣ Fazendo logout...')
    await supabase.auth.signOut()

  } catch (error) {
    console.error('💥 Erro geral:', error.message)
  }
}

verificarEstrutura()
