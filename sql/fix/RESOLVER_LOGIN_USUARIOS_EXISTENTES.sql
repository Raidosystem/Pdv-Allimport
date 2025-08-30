-- ===================================================
-- 🔧 SOLUÇÃO PARA PROBLEMAS DE LOGIN - USUÁRIOS EXISTENTES
-- ===================================================
-- Execute este script no Supabase SQL Editor para resolver
-- problemas de login após mudança de credenciais
-- Data: 30/08/2025
-- ===================================================

-- 1. VERIFICAR STATUS ATUAL DOS USUÁRIOS
-- ===================================================
SELECT 
  '📊 RELATÓRIO DE USUÁRIOS' as info,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN email_confirmed_at IS NOT NULL THEN 1 END) as emails_confirmados,
  COUNT(CASE WHEN email_confirmed_at IS NULL THEN 1 END) as emails_pendentes,
  COUNT(CASE WHEN last_sign_in_at IS NOT NULL THEN 1 END) as ja_fizeram_login
FROM auth.users;

-- 2. CONFIRMAR TODOS OS EMAILS PENDENTES
-- ===================================================
-- Isso resolve a maioria dos problemas de login
UPDATE auth.users 
SET 
  email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
  updated_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 3. LIMPAR SESSÕES E TOKENS ANTIGOS
-- ===================================================
-- Remove sessões antigas que podem estar causando conflito
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 4. VERIFICAR CONFIGURAÇÕES DE AUTENTICAÇÃO
-- ===================================================
-- Mostrar configurações importantes
SELECT 
  '🔧 CONFIGURAÇÕES ATIVAS' as info,
  (SELECT COUNT(*) FROM auth.sessions) as sessoes_ativas,
  (SELECT COUNT(*) FROM auth.refresh_tokens) as tokens_ativos,
  (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NOT NULL) as usuarios_confirmados;

-- 5. LISTAR ÚLTIMOS USUÁRIOS (PARA VERIFICAÇÃO)
-- ===================================================
SELECT 
  '👥 ÚLTIMOS USUÁRIOS CADASTRADOS' as info,
  email,
  created_at,
  CASE WHEN email_confirmed_at IS NOT NULL THEN '✅ Confirmado' ELSE '⏳ Pendente' END as status,
  CASE WHEN last_sign_in_at IS NOT NULL THEN '🔑 Já logou' ELSE '🆕 Nunca logou' END as login_status
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 10;

-- ===================================================
-- 🎯 PRÓXIMOS PASSOS APÓS EXECUTAR ESTE SCRIPT:
-- ===================================================
-- 1. ✅ Todos os emails foram confirmados automaticamente
-- 2. ✅ Sessões antigas foram removidas
-- 3. 🔄 Peça aos usuários para tentar login novamente
-- 4. 🗑️ Limpe o cache do navegador (Ctrl+Shift+Delete)
-- 5. 🆕 Se ainda não funcionar, use recuperação de senha
--
-- RECUPERAÇÃO DE SENHA (se necessário):
-- Para forçar reset de senha de usuário específico:
-- UPDATE auth.users SET encrypted_password = null WHERE email = 'email@exemplo.com';
-- ===================================================
