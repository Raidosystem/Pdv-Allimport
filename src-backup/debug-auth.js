// Debug direto no browser para identificar o problema
console.log('🔍 DEBUG SUPABASE - Iniciando diagnóstico...')

// 1. Verificar se as variáveis estão corretas
console.log('1️⃣ Verificando configuração:')
console.log('VITE_SUPABASE_URL:', import.meta.env?.VITE_SUPABASE_URL || 'UNDEFINED')
console.log('VITE_SUPABASE_ANON_KEY:', import.meta.env?.VITE_SUPABASE_ANON_KEY ? 'Presente' : 'AUSENTE')
console.log('ENV completo:', import.meta.env)

// 2. Verificar se Supabase está carregado
import { supabase } from './lib/supabase'
console.log('2️⃣ Cliente Supabase:', supabase ? 'Criado' : 'Erro')

// Log das configurações internas do Supabase
console.log('3️⃣ Config interna Supabase:', {
  supabaseUrl: supabase.supabaseUrl,
  supabaseKey: supabase.supabaseKey?.substring(0, 20) + '...',
  hasKey: !!supabase.supabaseKey
})

// 4. Testar conexão básica
async function debugAuth() {
  try {
    console.log('4️⃣ Testando autenticação...')
    
    // Teste de login com o email principal correto
    console.log('Tentando login com novaradiosystem@outlook.com...')
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'novaradiosystem@outlook.com',
      password: 'admin123'
    })
    
    if (error) {
      console.log('❌ Erro de login:', {
        message: error.message,
        status: error.status,
        name: error.name,
        stack: error.stack
      })
    } else {
      console.log('✅ Login bem-sucedido:', data.user?.email)
    }
    
  } catch (err) {
    console.log('💥 Erro geral:', err)
  }
}

// Executar teste depois de um delay
setTimeout(debugAuth, 2000)

export { debugAuth }
