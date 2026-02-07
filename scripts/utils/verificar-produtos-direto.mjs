// Script para verificar produtos perdidos via Node.js
// Execute com: node verificar-produtos-direto.mjs

import { createClient } from '@supabase/supabase-js'

// URLs e chaves do Supabase (substitua pelos valores reais)
// Execute no console do navegador para obter: console.log(import.meta.env)
const SUPABASE_URL = 'https://your-project.supabase.co' // ALTERE AQUI
const SUPABASE_ANON_KEY = 'your-anon-key' // ALTERE AQUI

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

console.log('🔍 VERIFICAÇÃO DIRETA DE PRODUTOS PERDIDOS')
console.log('=========================================')

async function verificarProdutos() {
  try {
    // 1. Verificar tabela produtos
    console.log('\n📦 Verificando tabela PRODUTOS...')
    const { data: produtos, error: errorProdutos, count: countProdutos } = await supabase
      .from('produtos')
      .select('*', { count: 'exact' })
      .limit(10)

    if (errorProdutos) {
      console.error('❌ Erro na tabela produtos:', errorProdutos.message)
    } else {
      console.log(`✅ Total na tabela produtos: ${countProdutos} registros`)
      if (produtos && produtos.length > 0) {
        console.log('📋 Amostras da tabela produtos:')
        produtos.slice(0, 3).forEach(p => {
          console.log(`  - ${p.nome} | User: ${p.user_id?.slice(0, 8)}... | Ativo: ${p.ativo}`)
        })
      }
    }

    // 2. Verificar tabela products (antiga)
    console.log('\n📦 Verificando tabela PRODUCTS (antiga)...')
    const { data: products, error: errorProducts, count: countProducts } = await supabase
      .from('products')
      .select('*', { count: 'exact' })
      .limit(10)

    if (errorProducts) {
      console.error('❌ Erro na tabela products:', errorProducts.message)
    } else {
      console.log(`✅ Total na tabela products: ${countProducts} registros`)
      if (products && products.length > 0) {
        console.log('📋 Amostras da tabela products:')
        products.slice(0, 3).forEach(p => {
          console.log(`  - ${p.name} | User: ${p.user_id?.slice(0, 8)}... | Ativo: ${p.active}`)
        })
      }
    }

    // 3. Verificar se há diferenças
    if (countProducts > countProdutos) {
      console.log('\n⚠️ DIAGNÓSTICO: Produtos estão na tabela PRODUCTS (antiga)')
      console.log(`   - Tabela products: ${countProducts} registros`)
      console.log(`   - Tabela produtos: ${countProdutos} registros`)
      console.log('💡 SOLUÇÃO: Migrar dados de products → produtos')
    } else if (countProdutos > 0) {
      console.log('\n✅ DIAGNÓSTICO: Produtos estão na tabela PRODUTOS (nova)')
      console.log('💡 POSSÍVEL CAUSA: Problema de RLS ou mapeamento no frontend')
    } else {
      console.log('\n❌ DIAGNÓSTICO: NENHUM PRODUTO ENCONTRADO em ambas as tabelas')
      console.log('💡 POSSÍVEL CAUSA: Perda de dados durante migração')
    }

  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

// Instrução para o usuário
console.log('📋 INSTRUÇÕES:')
console.log('1. Abra http://localhost:5174 no navegador')
console.log('2. Abra DevTools (F12) → Console')
console.log('3. Execute: console.log(import.meta.env)')
console.log('4. Copie VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY')
console.log('5. Edite este arquivo e substitua as constantes')
console.log('6. Execute: node verificar-produtos-direto.mjs')
console.log('')

if (SUPABASE_URL === 'https://your-project.supabase.co') {
  console.log('⚠️ AGUARDANDO: Configure as constantes SUPABASE_URL e SUPABASE_ANON_KEY')
} else {
  verificarProdutos()
}