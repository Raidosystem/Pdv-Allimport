// Debug direto no browser para identificar o problema
console.log('🔍 DEBUG SUPABASE - Iniciando diagnóstico...')

// 1. Verificar se as variáveis estão corretas
console.log('1️⃣ Verificando configuração:')
console.log('VITE_SUPABASE_URL:', import.meta.env?.VITE_SUPABASE_URL)
console.log('VITE_SUPABASE_ANON_KEY:', import.meta.env?.VITE_SUPABASE_ANON_KEY ? 'Presente' : 'Ausente')

// 2. Verificar se Supabase está carregado
import { supabase } from './lib/supabase'
console.log('2️⃣ Cliente Supabase:', supabase ? 'Criado' : 'Erro')

// 3. Testar conexão básica
async function debugAuth() {
  try {
    console.log('3️⃣ Testando autenticação...')
    
    // Teste de login
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'admin@pdv.com',
      password: 'admin123'
    })
    
    if (error) {
      console.log('❌ Erro de login:', {
        message: error.message,
        status: error.status,
        name: error.name
      })
    } else {
      console.log('✅ Login bem-sucedido:', data.user?.email)
    }
    
  } catch (err) {
    console.log('💥 Erro geral:', err)
  }
}

// Executar teste depois de um delay
setTimeout(debugAuth, 1000)

export { debugAuth }
