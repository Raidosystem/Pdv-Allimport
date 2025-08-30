-- ===================================================
-- 🚨 SOLUÇÃO URGENTE - "Invalid API key"
-- ===================================================
-- Execute este script no Supabase SQL Editor para resolver
-- problemas de API key e login do admin
-- Data: 30/08/2025
-- ===================================================

-- 1. VERIFICAR E CONFIRMAR EMAIL DO ADMIN
-- ===================================================
-- Primeiro, vamos confirmar o email do admin
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  updated_at = NOW(),
  email_change_confirm_status = 0
WHERE email = 'novaradiosystem@outlook.com';

-- 2. LIMPAR TODAS AS SESSÕES (FORÇA NOVA AUTENTICAÇÃO)
-- ===================================================
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;
DELETE FROM auth.mfa_challenges;
DELETE FROM auth.mfa_factors;

-- 3. VERIFICAR STATUS DO USUÁRIO ADMIN
-- ===================================================
SELECT 
  '🔍 STATUS DO ADMIN' as info,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ Email Confirmado'
    ELSE '❌ Email Pendente'
  END as status_email,
  CASE 
    WHEN banned_until IS NULL THEN '✅ Usuário Ativo'
    ELSE '🚫 Usuário Banido'
  END as status_usuario
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com';

-- 4. FORÇAR RESET DA SENHA (OPCIONAL - SE NECESSÁRIO)
-- ===================================================
-- Descomente as linhas abaixo se quiser forçar reset de senha:
-- UPDATE auth.users 
-- SET encrypted_password = null, recovery_sent_at = NOW()
-- WHERE email = 'novaradiosystem@outlook.com';

-- 5. VERIFICAR CONFIGURAÇÕES GERAIS
-- ===================================================
SELECT 
  '📊 RELATÓRIO GERAL' as info,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios,
  (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NOT NULL) as emails_confirmados,
  (SELECT COUNT(*) FROM auth.sessions) as sessoes_ativas,
  (SELECT COUNT(*) FROM auth.refresh_tokens) as tokens_ativos;

-- ===================================================
-- 🔧 INSTRUÇÕES ADICIONAIS:
-- ===================================================
-- 1. Execute este script completo
-- 2. Limpe o cache do navegador (Ctrl+Shift+Delete)
-- 3. Reinicie o servidor de desenvolvimento se estiver rodando
-- 4. Teste login em aba incógnito
-- 5. Se ainda não funcionar, use "Esqueci minha senha"
-- ===================================================
