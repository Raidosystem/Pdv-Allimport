// Script para testar configuração do domínio personalizado
// Cole este código no console do navegador em pdv.crmvsystem.com

console.log('🔍 Verificando configuração do domínio personalizado...')

// 1. Verificar domínio atual
console.log('📍 Domínio atual:', window.location.origin)

// 2. Verificar variáveis de ambiente
console.log('🔧 URL Supabase:', import.meta?.env?.VITE_SUPABASE_URL || 'Não definida')
console.log('🔑 Supabase Key (length):', import.meta?.env?.VITE_SUPABASE_ANON_KEY?.length || 'Não definida')
console.log('🌐 App URL:', import.meta?.env?.VITE_APP_URL || 'Não definida')

// 3. Testar conexão com Supabase
import { supabase } from './src/lib/supabase.js'

async function testSupabaseConnection() {
  try {
    console.log('🔌 Testando conexão com Supabase...')
    const { data, error } = await supabase.from('clientes').select('count').limit(1)
    
    if (error) {
      console.error('❌ Erro de conexão:', error.message)
      if (error.message.includes('CORS')) {
        console.log('💡 Solução: Adicionar domínio aos CORS Origins no Supabase')
      }
    } else {
      console.log('✅ Conexão com Supabase funcionando!')
    }
  } catch (err) {
    console.error('❌ Erro geral:', err)
  }
}

// 4. Testar autenticação
async function testAuth() {
  try {
    console.log('🔐 Testando autenticação...')
    const { data, error } = await supabase.auth.getSession()
    
    if (error) {
      console.error('❌ Erro de autenticação:', error.message)
    } else {
      console.log('✅ Sistema de autenticação funcionando!')
      console.log('👤 Usuário logado:', !!data.session?.user)
    }
  } catch (err) {
    console.error('❌ Erro na autenticação:', err)
  }
}

// 5. Executar testes
console.log('🚀 Executando testes...')
testSupabaseConnection()
testAuth()

console.log('✅ Verificação completa! Veja os resultados acima.')
console.log('📋 Se há erros, siga o GUIA_DOMINIO_PERSONALIZADO.md')
