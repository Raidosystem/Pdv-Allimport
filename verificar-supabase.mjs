// 🔍 SCRIPT NODE.JS PARA VERIFICAR SUPABASE DIRETO

import { createClient } from '@supabase/supabase-js'

// CONFIGURAÇÃO - SUBSTITUA PELAS SUAS CREDENCIAIS
const supabaseUrl = 'https://seu-project-ref.supabase.co'
const supabaseKey = 'sua_anon_key_aqui' // ou service_role_key para bypass do RLS

const supabase = createClient(supabaseUrl, supabaseKey)

async function verificarTabelas() {
  console.log('🔍 VERIFICANDO TABELAS DO SUPABASE...\n')

  try {
    // 1. CONTAR REGISTROS
    console.log('📊 CONTAGEM DE REGISTROS:')
    
    const { data: products, count: productsCount } = await supabase
      .from('products')
      .select('*', { count: 'exact', head: true })
    console.log(`Products: ${productsCount}`)

    const { data: clients, count: clientsCount } = await supabase
      .from('clients')
      .select('*', { count: 'exact', head: true })
    console.log(`Clients: ${clientsCount}`)

    const { data: categories, count: categoriesCount } = await supabase
      .from('categories')
      .select('*', { count: 'exact', head: true })
    console.log(`Categories: ${categoriesCount}\n`)

    // 2. LISTAR PRODUTOS RECENTES
    console.log('📦 PRODUTOS RECENTES:')
    const { data: recentProducts } = await supabase
      .from('products')
      .select('name, created_at')
      .order('created_at', { ascending: false })
      .limit(10)

    recentProducts?.forEach(product => {
      console.log(`- ${product.name} (${product.created_at})`)
    })

    // 3. BUSCAR PRODUTOS ALLIMPORT
    console.log('\n🔍 PRODUTOS ALLIMPORT:')
    const { data: allimportProducts } = await supabase
      .from('products')
      .select('name')
      .like('name', '%ALLIMPORT%')

    if (allimportProducts?.length > 0) {
      allimportProducts.forEach(product => {
        console.log(`✅ ${product.name}`)
      })
    } else {
      console.log('❌ Nenhum produto ALLIMPORT encontrado')
    }

    // 4. VERIFICAR USUÁRIO ATUAL
    console.log('\n👤 USUÁRIO ATUAL:')
    const { data: { user } } = await supabase.auth.getUser()
    console.log('User:', user?.email || 'Não logado')

  } catch (error) {
    console.error('❌ Erro:', error.message)
  }
}

// EXECUTAR VERIFICAÇÃO
verificarTabelas()

// 📝 COMO USAR:
// 1. npm install @supabase/supabase-js
// 2. Substitua as credenciais acima
// 3. node verificar-supabase.mjs
