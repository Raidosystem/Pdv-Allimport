-- 🔄 LIMPEZA DE SESSÕES - MANTER USUÁRIOS
-- Execute no SQL Editor do Supabase
-- Este script NÃO deleta usuários, apenas limpa sessões ativas

-- 1. Verificar usuários existentes ANTES da limpeza
SELECT 
  '=== USUÁRIOS EXISTENTES ANTES DA LIMPEZA ===' as info,
  COUNT(*) as total_usuarios
FROM auth.users;

SELECT 
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN '❌ Email não confirmado'
    WHEN last_sign_in_at IS NULL THEN '⚠️ Nunca fez login'
    ELSE '✅ OK'
  END as status
FROM auth.users
ORDER BY created_at DESC;

-- 2. Limpar apenas sessões ativas (manter usuários)
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 3. Confirmar emails não confirmados
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  confirmation_token = NULL
WHERE email_confirmed_at IS NULL;

-- 4. Verificar resultado APÓS limpeza
SELECT 
  '=== RESULTADO APÓS LIMPEZA ===' as info,
  COUNT(*) as total_usuarios_mantidos
FROM auth.users;

SELECT 
  email,
  email_confirmed_at,
  'Sessões limpas - pronto para novo login' as status
FROM auth.users
ORDER BY created_at DESC;

-- 5. Verificar se existem sessões ativas (deve ser 0)
SELECT 
  '=== VERIFICAÇÃO DE SESSÕES ===' as info,
  COUNT(*) as sessoes_ativas
FROM auth.sessions;

SELECT 
  '=== CONFIGURAÇÃO RECOMENDADA ===' as info,
  'Site URL: https://pdv.crmvsystem.com (SEM barra no final)' as config;
