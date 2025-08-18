#!/usr/bin/env node

/**
 * TESTE DE CONFIGURAÇÃO DO SUPABASE
 * Verifica se as variáveis de ambiente estão corretas
 */

import { createClient } from '@supabase/supabase-js';

// Configurações conhecidas do Supabase
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

console.log('🔍 TESTE DE CONFIGURAÇÃO DO SUPABASE');
console.log('═'.repeat(50));

// Criar cliente Supabase
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    redirectTo: 'https://pdv.crmvsystem.com/auth/callback'
  }
});

async function testarLogin() {
  console.log('🧪 Testando login de usuário...');
  
  try {
    // Testar login com usuário conhecido
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'novaradiosystem@outlook.com',
      password: '@qw12aszx##'
    });
    
    if (error) {
      console.error('❌ Erro de login:', error.message);
      console.error('📋 Detalhes do erro:', {
        status: error.status,
        details: error.details,
        hint: error.hint
      });
      
      // Diagnosticar tipo de erro
      if (error.message.includes('Invalid login credentials')) {
        console.log('💡 Possíveis causas:');
        console.log('   1. Senha incorreta');
        console.log('   2. Email não confirmado');
        console.log('   3. Usuário não existe');
        console.log('   4. RLS bloqueando acesso');
      }
      
      if (error.message.includes('Email not confirmed')) {
        console.log('💡 Solução: Confirmar email do usuário');
      }
      
      return false;
    } else {
      console.log('✅ Login realizado com sucesso!');
      console.log('👤 Usuário:', data.user.email);
      console.log('🔑 Token:', data.session?.access_token?.substring(0, 20) + '...');
      
      // Testar acesso aos dados
      console.log('\n🗄️ Testando acesso aos dados...');
      
      const { data: clientes, error: clientesError } = await supabase
        .from('clientes')
        .select('count', { count: 'exact', head: true });
      
      if (clientesError) {
        console.error('❌ Erro ao acessar clientes:', clientesError.message);
      } else {
        console.log('✅ Acesso aos dados funcionando');
      }
      
      // Logout
      await supabase.auth.signOut();
      return true;
    }
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
    return false;
  }
}

async function verificarConfiguracoes() {
  console.log('⚙️ Verificando configurações...');
  
  console.log(`📍 Supabase URL: ${SUPABASE_URL}`);
  console.log(`🔑 Anon Key: ${SUPABASE_ANON_KEY.substring(0, 20)}...`);
  console.log(`🌐 Redirect URL: https://pdv.crmvsystem.com/auth/callback`);
  
  // Testar conectividade básica
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });
    
    console.log(`✅ Conectividade: ${response.status} ${response.statusText}`);
    
  } catch (error) {
    console.error('❌ Erro de conectividade:', error.message);
  }
}

async function listarUsuarios() {
  console.log('\n👥 Listando usuários disponíveis...');
  
  try {
    // Usar service role para listar usuários
    const SERVICE_ROLE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4';
    
    const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      headers: {
        'apikey': SERVICE_ROLE,
        'Authorization': `Bearer ${SERVICE_ROLE}`
      }
    });
    
    if (response.ok) {
      const data = await response.json();
      console.log(`📊 Total de usuários: ${data.users?.length || 0}`);
      
      if (data.users?.length > 0) {
        data.users.slice(0, 5).forEach(user => {
          console.log(`   📧 ${user.email} - ${user.email_confirmed_at ? '✅ Confirmado' : '❌ Não confirmado'}`);
        });
      }
    } else {
      console.log('⚠️ Não foi possível listar usuários');
    }
    
  } catch (error) {
    console.log('⚠️ Erro ao listar usuários:', error.message);
  }
}

// Executar testes
async function executar() {
  await verificarConfiguracoes();
  await listarUsuarios();
  const loginOK = await testarLogin();
  
  console.log('\n═'.repeat(50));
  console.log('🎯 DIAGNÓSTICO COMPLETO:');
  
  if (loginOK) {
    console.log('✅ Supabase: Funcionando');
    console.log('✅ Login: OK');
    console.log('✅ Problema resolvido!');
  } else {
    console.log('❌ Login: Falhou');
    console.log('🔧 Próximos passos:');
    console.log('   1. Verificar RLS nas tabelas');
    console.log('   2. Confirmar emails dos usuários');
    console.log('   3. Verificar configurações no Dashboard');
  }
}

executar();
