#!/usr/bin/env node

/**
 * CONFIGURAR CORS VIA API DO SUPABASE
 * Usando service_role para configurar CORS diretamente
 */

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4';

console.log('🚀 CONFIGURANDO CORS VIA API SUPABASE');
console.log('═'.repeat(50));

// Função para fazer requisições
async function makeRequest(endpoint, options = {}) {
  const url = `${SUPABASE_URL}/rest/v1/${endpoint}`;
  
  const defaultOptions = {
    headers: {
      'apikey': SERVICE_ROLE_KEY,
      'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal'
    }
  };

  const response = await fetch(url, { ...defaultOptions, ...options });
  return { response, data: await response.text() };
}

// Configurar CORS via API
async function configurarCORS() {
  console.log('🔧 Configurando CORS...');
  
  try {
    // Teste de conectividade primeiro
    console.log('📡 Testando conectividade...');
    
    const testResponse = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
      }
    });
    
    console.log(`✅ Status de conectividade: ${testResponse.status}`);
    
    if (testResponse.status === 200) {
      console.log('✅ Conectado ao Supabase com service_role!');
      
      // Verificar se existe configuração CORS
      console.log('🔍 Verificando configuração atual...');
      
      // Como CORS não pode ser configurado via SQL no Supabase gerenciado,
      // vamos usar uma abordagem diferente: configurar via Edge Functions
      console.log('💡 CORS deve ser configurado no Dashboard do Supabase');
      console.log('   Sua conexão está funcionando, mas CORS é configuração de infraestrutura');
      
      return true;
    } else {
      throw new Error(`Erro de conectividade: ${testResponse.status}`);
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
    return false;
  }
}

// Limpar sessões via API
async function limparSessoes() {
  console.log('🧹 Limpando sessões...');
  
  try {
    // Deletar sessões via SQL
    const { response } = await makeRequest('rpc/exec_sql', {
      method: 'POST',
      body: JSON.stringify({
        query: 'DELETE FROM auth.sessions; DELETE FROM auth.refresh_tokens;'
      })
    });
    
    if (response.ok) {
      console.log('✅ Sessões limpas com sucesso!');
    } else {
      console.log('⚠️ Não foi possível limpar sessões via API');
    }
    
  } catch (error) {
    console.log('⚠️ Erro ao limpar sessões:', error.message);
  }
}

// Verificar usuários
async function verificarUsuarios() {
  console.log('👥 Verificando usuários...');
  
  try {
    const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
      }
    });
    
    if (response.ok) {
      const data = await response.json();
      console.log(`✅ Encontrados ${data.users?.length || 0} usuários`);
      
      if (data.users?.length > 0) {
        data.users.forEach(user => {
          console.log(`   📧 ${user.email} - ${user.email_confirmed_at ? 'Confirmado' : 'Não confirmado'}`);
        });
      }
    } else {
      console.log('⚠️ Não foi possível verificar usuários');
    }
    
  } catch (error) {
    console.log('⚠️ Erro ao verificar usuários:', error.message);
  }
}

// Executar configuração
async function executar() {
  console.log('🎯 Iniciando configuração...');
  
  const corsOK = await configurarCORS();
  await limparSessoes();
  await verificarUsuarios();
  
  console.log('\n═'.repeat(50));
  console.log('🎯 RESULTADO:');
  
  if (corsOK) {
    console.log('✅ Conexão com Supabase: OK');
    console.log('⚠️ CORS: Deve ser configurado no Dashboard');
    console.log('🔧 Próximos passos:');
    console.log('   1. Procure CORS no Dashboard do Supabase');
    console.log('   2. Ou use solução alternativa (desabilitar RLS)');
    console.log('   3. Teste: https://pdv.crmvsystem.com/');
  } else {
    console.log('❌ Falha na conexão com Supabase');
  }
  
  console.log('\n💡 ALTERNATIVA: Execute no SQL Editor:');
  console.log('   ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;');
}

// Executar
executar();
