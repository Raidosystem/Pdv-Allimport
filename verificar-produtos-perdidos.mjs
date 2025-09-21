#!/usr/bin/env node

// Script para verificar produtos perdidos do usuário

import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

// Carregar variáveis de ambiente
config()

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variáveis de ambiente não encontradas!')
  console.log('Certifique-se de que VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY estão definidas')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function verificarProdutosPerdidos() {
  console.log('🔍 VERIFICANDO PRODUTOS PERDIDOS...\n')

  try {
    // 1. Verificar usuário existe
    console.log('👤 Verificando usuário...')
    const { data: users, error: userError } = await supabase
      .from('users')  // Pode estar em auth.users ou profiles
      .select('id, email')
      .eq('email', 'assistenciaallimport0@gmail.com')

    if (userError) {
      console.log('⚠️ Erro ao buscar usuário (normal se estiver em auth.users):', userError.message)
    } else {
      console.log('✅ Usuário encontrado:', users)
    }

    // 2. Verificar produtos na tabela 'produtos'
    console.log('\n📦 Verificando tabela produtos...')
    const { data: produtos, error: produtosError, count: produtosCount } = await supabase
      .from('produtos')
      .select('*', { count: 'exact' })
      .limit(5)

    if (produtosError) {
      console.error('❌ Erro ao acessar tabela produtos:', produtosError.message)
    } else {
      console.log(`✅ Tabela produtos: ${produtosCount} registros total`)
      console.log('📋 Primeiros produtos:', produtos?.map(p => ({ 
        nome: p.nome, 
        user_id: p.user_id?.slice(0, 8) + '...' 
      })))
    }

    // 3. Verificar produtos na tabela 'products' (antiga)
    console.log('\n📦 Verificando tabela products (antiga)...')
    const { data: products, error: productsError, count: productsCount } = await supabase
      .from('products')
      .select('*', { count: 'exact' })
      .limit(5)

    if (productsError) {
      console.error('❌ Erro ao acessar tabela products:', productsError.message)
    } else {
      console.log(`✅ Tabela products: ${productsCount} registros total`)
      console.log('📋 Primeiros products:', products?.map(p => ({ 
        name: p.name, 
        user_id: p.user_id?.slice(0, 8) + '...' 
      })))
    }

    // 4. Verificar contagem sem RLS (usando service role se disponível)
    console.log('\n🔓 Tentando verificar sem RLS...')
    try {
      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
      if (serviceRoleKey) {
        const adminSupabase = createClient(supabaseUrl, serviceRoleKey)
        const { count: adminCount } = await adminSupabase
          .from('produtos')
          .select('*', { count: 'exact', head: true })

        console.log(`✅ Total produtos (admin): ${adminCount}`)
      } else {
        console.log('⚠️ Service role key não disponível')
      }
    } catch (adminError) {
      console.log('⚠️ Erro ao verificar como admin:', adminError.message)
    }

  } catch (error) {
    console.error('❌ Erro geral:', error)
  }
}

verificarProdutosPerdidos()