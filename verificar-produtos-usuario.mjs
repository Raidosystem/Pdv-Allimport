// Script para verificar produtos específicos do usuário assistenciaallimport10@gmail.com
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

console.log('🔍 VERIFICANDO PRODUTOS PARA assistenciaallimport10@gmail.com\n')

async function verificarProdutos() {
  try {
    // 1. Fazer login como assistenciaallimport10@gmail.com
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
    console.log('🆔 User ID:', loginData.user.id)
    const userId = loginData.user.id

    // 2. Contar total de produtos na tabela
    console.log('\n2️⃣ Verificando total de produtos na tabela...')
    const { count: totalCount, error: countError } = await supabase
      .from('produtos')
      .select('*', { count: 'exact', head: true })

    if (countError) {
      console.log('❌ Erro ao contar produtos:', countError.message)
    } else {
      console.log('📦 Total de produtos na tabela:', totalCount)
    }

    // 3. Contar produtos para este usuário específico
    console.log('\n3️⃣ Verificando produtos para o usuário logado...')
    const { data: userProducts, error: userError, count: userCount } = await supabase
      .from('produtos')
      .select('*', { count: 'exact' })
      .eq('user_id', userId)

    if (userError) {
      console.log('❌ Erro ao buscar produtos do usuário:', userError.message)
    } else {
      console.log('✅ Produtos encontrados para o usuário:', userCount)
      if (userProducts && userProducts.length > 0) {
        console.log('📦 Primeiros produtos:')
        userProducts.slice(0, 5).forEach((produto, index) => {
          console.log(`   ${index + 1}. ${produto.nome} (ID: ${produto.id})`)
        })
      }
    }

    // 4. Verificar produtos com o UUID esperado
    console.log('\n4️⃣ Verificando produtos com UUID f7fdf4cf-7101-45ab-86db-5248a7ac58c1...')
    const expectedUUID = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    const { data: expectedProducts, error: expectedError, count: expectedCount } = await supabase
      .from('produtos')
      .select('*', { count: 'exact' })
      .eq('user_id', expectedUUID)

    if (expectedError) {
      console.log('❌ Erro ao buscar produtos com UUID esperado:', expectedError.message)
    } else {
      console.log('✅ Produtos com UUID esperado:', expectedCount)
      if (expectedProducts && expectedProducts.length > 0) {
        console.log('📦 Primeiros produtos com UUID esperado:')
        expectedProducts.slice(0, 5).forEach((produto, index) => {
          console.log(`   ${index + 1}. ${produto.nome} (ID: ${produto.id})`)
        })
      }
    }

    // 5. Comparar UUIDs
    console.log('\n5️⃣ Comparação de UUIDs:')
    console.log('UUID do usuário logado:', userId)
    console.log('UUID esperado:', expectedUUID)
    console.log('São iguais?', userId === expectedUUID ? '✅ SIM' : '❌ NÃO')

    // 6. Verificar todos os user_ids únicos na tabela produtos
    console.log('\n6️⃣ Verificando todos os user_ids na tabela produtos...')
    const { data: allUserIds, error: allUserIdsError } = await supabase
      .from('produtos')
      .select('user_id')
      .not('user_id', 'is', null)

    if (allUserIdsError) {
      console.log('❌ Erro ao buscar user_ids:', allUserIdsError.message)
    } else {
      const uniqueUserIds = [...new Set(allUserIds.map(p => p.user_id))]
      console.log('👥 User IDs únicos encontrados na tabela produtos:')
      uniqueUserIds.forEach((id, index) => {
        console.log(`   ${index + 1}. ${id}`)
      })
    }

    // 7. Fazer logout
    console.log('\n7️⃣ Fazendo logout...')
    await supabase.auth.signOut()

    console.log('\n🎯 CONCLUSÃO:')
    if (userId === expectedUUID && userCount > 0) {
      console.log('✅ Produtos existem para o usuário. Problema pode ser no frontend.')
    } else if (userId !== expectedUUID && expectedCount > 0) {
      console.log('⚠️ UUID do usuário é diferente do esperado. Produtos estão em outro UUID.')
    } else if (userCount === 0 && expectedCount === 0) {
      console.log('❌ Não há produtos cadastrados para nenhum UUID.')
    } else {
      console.log('🔍 Situação complexa. Verificar logs acima.')
    }

  } catch (error) {
    console.error('💥 Erro geral:', error.message)
  }
}

verificarProdutos()
