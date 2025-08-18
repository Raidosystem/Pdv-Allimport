#!/usr/bin/env node

/**
 * DIAGNÓSTICO DE USUÁRIOS SUPABASE
 * Verifica problemas com autenticação após mudança de domínio
 */

import https from 'https';

console.log('🔍 DIAGNÓSTICO DE USUÁRIOS SUPABASE');
console.log('📍 Domínio atual: https://pdv.crmvsystem.com/');
console.log('⏰ Timestamp:', new Date().toLocaleString('pt-BR'));
console.log('═'.repeat(60));

// Teste 1: Verificar se o problema é no frontend
async function testarFrontend() {
  console.log('\n🎯 TESTE 1: Verificando código frontend...');
  
  return new Promise((resolve) => {
    https.get('https://pdv.crmvsystem.com/', (response) => {
      let data = '';
      response.on('data', chunk => data += chunk);
      response.on('end', () => {
        // Procurar por configurações do Supabase no código
        const patterns = [
          { name: 'Supabase URL', regex: /supabase\.co/gi },
          { name: 'Auth Config', regex: /auth.*config|createClient/gi },
          { name: 'Login Form', regex: /login|signIn|password/gi },
          { name: 'Error Handling', regex: /error|catch|try/gi },
          { name: 'Console Logs', regex: /console\.log|console\.error/gi }
        ];
        
        patterns.forEach(pattern => {
          const matches = data.match(pattern.regex) || [];
          const icon = matches.length > 0 ? '✅' : '❌';
          console.log(`${icon} ${pattern.name}: ${matches.length} ocorrências`);
        });
        
        resolve(data);
      });
    });
  });
}

// Teste 2: Problemas comuns após mudança de domínio
function analisarProblemasDominio() {
  console.log('\n🎯 TESTE 2: Problemas comuns com mudança de domínio...');
  
  const problemasComuns = [
    {
      problema: 'Site URL incorreta no Supabase',
      solucao: 'Configurar: https://pdv.crmvsystem.com/',
      critico: true
    },
    {
      problema: 'Redirect URLs não incluem novo domínio', 
      solucao: 'Adicionar todas as URLs do novo domínio',
      critico: true
    },
    {
      problema: 'CORS não configurado para novo domínio',
      solucao: 'Adicionar domínio nas configurações CORS',
      critico: true
    },
    {
      problema: 'Usuários criados com domínio antigo',
      solucao: 'Recriar usuários ou limpar sessões',
      critico: false
    },
    {
      problema: 'Cache do navegador com configurações antigas',
      solucao: 'Limpar cache e cookies do navegador',
      critico: false
    },
    {
      problema: 'Service Worker com cache antigo',
      solucao: 'Limpar cache do service worker',
      critico: false
    }
  ];
  
  problemasComuns.forEach((item, index) => {
    const icon = item.critico ? '🚨' : '⚠️';
    console.log(`${icon} ${index + 1}. ${item.problema}`);
    console.log(`   💡 Solução: ${item.solucao}`);
  });
}

// Teste 3: Gerar script de limpeza
function gerarScriptLimpeza() {
  console.log('\n🎯 TESTE 3: Script de limpeza gerado...');
  
  const scriptSQL = `
-- LIMPEZA COMPLETA PARA NOVO DOMÍNIO
-- Execute no SQL Editor do Supabase

-- 1. Limpar todas as sessões existentes
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 2. Resetar configurações de email dos usuários
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  confirmation_token = NULL,
  recovery_token = NULL,
  email_change_token_new = NULL,
  email_change_token_current = NULL
WHERE email IS NOT NULL;

-- 3. Verificar usuários existentes
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Email não confirmado'
    WHEN last_sign_in_at IS NULL THEN 'Nunca fez login'
    ELSE 'OK'
  END as status
FROM auth.users
ORDER BY created_at DESC;
  `;
  
  console.log('📄 Script SQL de limpeza criado!');
  return scriptSQL;
}

// Teste 4: Verificar configurações necessárias
function verificarConfiguracoes() {
  console.log('\n🎯 TESTE 4: Configurações necessárias...');
  
  const configs = {
    'Site URL': 'https://pdv.crmvsystem.com/',
    'Redirect URLs': [
      'https://pdv.crmvsystem.com/',
      'https://pdv.crmvsystem.com/auth/callback',
      'https://pdv.crmvsystem.com/login',
      'https://pdv.crmvsystem.com/dashboard'
    ],
    'CORS Origins': [
      'https://pdv.crmvsystem.com'
    ]
  };
  
  console.log('📋 Configurações que DEVEM estar no Supabase:');
  Object.entries(configs).forEach(([key, value]) => {
    console.log(`\n✅ ${key}:`);
    if (Array.isArray(value)) {
      value.forEach(item => console.log(`   - ${item}`));
    } else {
      console.log(`   - ${value}`);
    }
  });
}

// Executar diagnóstico completo
async function executarDiagnostico() {
  try {
    await testarFrontend();
    analisarProblemasDominio();
    const scriptSQL = gerarScriptLimpeza();
    verificarConfiguracoes();
    
    console.log('\n' + '═'.repeat(60));
    console.log('🎯 DIAGNÓSTICO CONCLUÍDO');
    console.log('═'.repeat(60));
    
    console.log('\n🚨 AÇÃO IMEDIATA RECOMENDADA:');
    console.log('1. 🧹 Limpe o cache do navegador (Ctrl+Shift+Delete)');
    console.log('2. 🔄 Execute o script SQL de limpeza no Supabase');
    console.log('3. ⚙️ Verifique TODAS as configurações listadas acima');
    console.log('4. 🆕 Crie um novo usuário para teste');
    console.log('5. 🧪 Teste login em aba privada/incógnito');
    
    // Salvar script SQL
    const fs = await import('fs');
    fs.writeFileSync('limpeza-usuarios-supabase.sql', scriptSQL);
    console.log('\n📁 Script SQL salvo em: limpeza-usuarios-supabase.sql');
    
  } catch (error) {
    console.error('❌ Erro no diagnóstico:', error.message);
  }
}

// Executar
executarDiagnostico();
