-- ============================================
-- 🔍 DIAGNÓSTICO - Novo Usuário Não Consegue Entrar
-- ============================================

-- PASSO 1: Ver todos os usuários cadastrados
SELECT 
  '📋 TODOS OS USUÁRIOS CADASTRADOS:' as info;

SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  raw_user_meta_data->>'full_name' as nome,
  CASE 
    WHEN email_confirmed_at IS NULL THEN '⚠️ EMAIL NÃO CONFIRMADO'
    ELSE '✅ EMAIL CONFIRMADO'
  END as status_email
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- PASSO 2: Ver user_approvals (sistema de aprovação)
-- ============================================

SELECT 
  '📋 USER_APPROVALS (Sistema de Aprovação):' as info;

SELECT 
  user_id,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at,
  CASE 
    WHEN status = 'approved' THEN '✅ APROVADO'
    WHEN status = 'pending' THEN '⏳ PENDENTE'
    WHEN status = 'rejected' THEN '❌ REJEITADO'
    ELSE '❓ DESCONHECIDO'
  END as situacao
FROM user_approvals
ORDER BY created_at DESC;

-- ============================================
-- PASSO 3: Ver subscriptions (assinaturas)
-- ============================================

SELECT 
  '📋 SUBSCRIPTIONS (Assinaturas):' as info;

SELECT 
  user_id,
  email,
  status,
  trial_start_date,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  created_at,
  CASE 
    WHEN status = 'trial' AND trial_end_date > NOW() THEN '🎁 TESTE ATIVO'
    WHEN status = 'active' AND subscription_end_date > NOW() THEN '⭐ PREMIUM ATIVO'
    WHEN trial_end_date < NOW() AND subscription_end_date IS NULL THEN '⏰ TESTE EXPIRADO'
    WHEN subscription_end_date < NOW() THEN '⏰ PREMIUM EXPIRADO'
    ELSE '❓ STATUS INDEFINIDO'
  END as situacao
FROM subscriptions
ORDER BY created_at DESC;

-- ============================================
-- PASSO 4: Ver empresas (se usar sistema de empresas)
-- ============================================

SELECT 
  '📋 EMPRESAS CADASTRADAS:' as info;

SELECT 
  id,
  user_id,
  nome_empresa,
  ativo,
  created_at,
  CASE 
    WHEN ativo = true THEN '✅ ATIVO'
    ELSE '❌ INATIVO'
  END as status
FROM empresas
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- PASSO 5: Identificar o problema
-- ============================================

SELECT 
  '🔍 ANÁLISE - Usuários sem aprovação ou assinatura:' as info;

-- Usuários que existem no auth.users mas NÃO em user_approvals
SELECT 
  'SEM USER_APPROVAL' as problema,
  u.email,
  u.created_at
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE ua.user_id IS NULL
ORDER BY u.created_at DESC;

-- Usuários que existem no auth.users mas NÃO em subscriptions
SELECT 
  'SEM SUBSCRIPTION' as problema,
  u.email,
  u.created_at
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE s.user_id IS NULL
ORDER BY u.created_at DESC;

-- Usuários que existem mas estão PENDENTES de aprovação
SELECT 
  'APROVAÇÃO PENDENTE' as problema,
  ua.email,
  ua.status,
  ua.created_at
FROM user_approvals ua
WHERE ua.status = 'pending'
ORDER BY ua.created_at DESC;
