// ===================================================
// 🔍 DIAGNÓSTICO DE USUÁRIOS EXISTENTES - SUPABASE
// ===================================================
// Execute com: node diagnostico-usuarios.js

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

async function diagnosticarUsuarios() {
  console.log('🔍 DIAGNÓSTICO DE USUÁRIOS SUPABASE');
  console.log('═'.repeat(50));

  try {
    // 1. Testar conexão
    console.log('📡 Testando conexão...');
    const testResponse = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });

    if (!testResponse.ok) {
      throw new Error(`Conexão falhou: ${testResponse.status} ${testResponse.statusText}`);
    }
    console.log('✅ Conexão OK!');

    // 2. Listar usuários cadastrados (apenas contagem por segurança)
    console.log('\n👥 Verificando usuários cadastrados...');
    
    const usersResponse = await fetch(`${supabaseUrl}/rest/v1/auth.users?select=count`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Content-Type': 'application/json'
      }
    });

    if (usersResponse.ok) {
      const users = await usersResponse.json();
      console.log(`📊 Total de usuários: ${users.length || 'Não foi possível contar'}`);
    } else {
      console.log('⚠️ Não foi possível acessar tabela de usuários via REST API');
      console.log('🔧 Isso é normal - usuários ficam na tabela auth.users');
    }

    // 3. Verificar configurações de autenticação
    console.log('\n🔧 Verificações importantes:');
    console.log('URL Supabase:', supabaseUrl);
    console.log('Chave válida:', supabaseKey.length > 100 ? '✅' : '❌');
    
    // 4. Scripts SQL para executar no Supabase SQL Editor
    console.log('\n📋 SCRIPTS PARA RESOLVER PROBLEMAS DE LOGIN:');
    console.log('═'.repeat(50));
    
    console.log('\n🔍 1. VERIFICAR USUÁRIOS (Execute no SQL Editor):');
    console.log(`
-- Contar usuários cadastrados
SELECT COUNT(*) as total_usuarios FROM auth.users;

-- Ver últimos usuários (sem dados sensíveis)
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  CASE WHEN email_confirmed_at IS NOT NULL THEN 'Confirmado' ELSE 'Pendente' END as status_email
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;
    `);

    console.log('\n🔧 2. CONFIRMAR TODOS OS EMAILS (Execute no SQL Editor):');
    console.log(`
-- Confirmar emails de todos os usuários
UPDATE auth.users 
SET email_confirmed_at = NOW(), 
    updated_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Verificar resultado
SELECT 
  COUNT(*) as usuarios_confirmados
FROM auth.users 
WHERE email_confirmed_at IS NOT NULL;
    `);

    console.log('\n🚿 3. LIMPAR SESSÕES ANTIGAS (Execute no SQL Editor):');
    console.log(`
-- Limpar sessões e refresh tokens antigos
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- Verificar limpeza
SELECT 
  (SELECT COUNT(*) FROM auth.sessions) as sessoes_ativas,
  (SELECT COUNT(*) FROM auth.refresh_tokens) as refresh_tokens_ativos;
    `);

    console.log('\n⚙️ 4. RESETAR SENHA DE USUÁRIO ESPECÍFICO (Execute no SQL Editor):');
    console.log(`
-- Para resetar senha de um usuário específico, substitua 'EMAIL_AQUI'
-- Este comando força o usuário a redefinir a senha no próximo login
UPDATE auth.users 
SET 
  encrypted_password = null,
  recovery_sent_at = NOW(),
  updated_at = NOW()
WHERE email = 'EMAIL_AQUI';
    `);

    console.log('\n🎯 PRÓXIMOS PASSOS:');
    console.log('1. Execute os scripts SQL no Supabase SQL Editor');
    console.log('2. Teste o login na aplicação');
    console.log('3. Se ainda não funcionar, verifique as configurações de URL no Supabase');
    console.log('4. Limpe o cache do navegador');

  } catch (error) {
    console.error('❌ Erro:', error.message);
    console.log('\n🔧 SOLUÇÕES:');
    console.log('1. Verifique se a nova chave Supabase está correta');
    console.log('2. Confirme se o projeto Supabase está ativo');
    console.log('3. Execute os scripts SQL manualmente no Supabase SQL Editor');
  }
}

diagnosticarUsuarios();
