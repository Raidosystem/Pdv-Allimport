-- ================================================
-- VERIFICAR TODAS AS ASSINATURAS NO SISTEMA
-- Para identificar cadastros que não aparecem no admin
-- ================================================

-- 1️⃣ CONTAR TOTAL DE USUÁRIOS CADASTRADOS
SELECT 
  '1. TOTAL DE USUÁRIOS EM auth.users' as etapa,
  COUNT(*) as total,
  COUNT(CASE WHEN created_at::date = CURRENT_DATE THEN 1 END) as cadastrados_hoje
FROM auth.users;

-- 2️⃣ CONTAR TOTAL DE ASSINATURAS
SELECT 
  '2. TOTAL DE ASSINATURAS' as etapa,
  COUNT(*) as total,
  COUNT(CASE WHEN created_at::date = CURRENT_DATE THEN 1 END) as criadas_hoje
FROM public.subscriptions;

-- 3️⃣ LISTAR USUÁRIOS SEM ASSINATURA
SELECT 
  '3. USUÁRIOS SEM ASSINATURA' as etapa,
  u.email,
  u.created_at,
  u.email_confirmed_at
FROM auth.users u
LEFT JOIN public.subscriptions s ON s.user_id = u.id
WHERE s.id IS NULL
ORDER BY u.created_at DESC;

-- 4️⃣ LISTAR TODAS AS ASSINATURAS (SEM LIMITE)
SELECT 
  '4. TODAS AS ASSINATURAS' as etapa,
  s.email,
  s.status,
  s.plan_type,
  s.created_at::date as data_criacao,
  CASE 
    WHEN s.created_at::date = CURRENT_DATE THEN '✅ HOJE'
    ELSE '📅 ' || (CURRENT_DATE - s.created_at::date) || ' dias atrás'
  END as quando
FROM public.subscriptions s
ORDER BY s.created_at DESC;

-- 5️⃣ VERIFICAR USER_APPROVALS (CADASTROS PENDENTES)
SELECT 
  '5. CADASTROS EM user_approvals' as etapa,
  ua.email,
  ua.status,
  ua.created_at::date as data_cadastro,
  CASE 
    WHEN s.id IS NOT NULL THEN '✅ Com assinatura'
    ELSE '❌ SEM ASSINATURA'
  END as tem_assinatura
FROM public.user_approvals ua
LEFT JOIN public.subscriptions s ON s.user_id = ua.user_id
ORDER BY ua.created_at DESC;

-- 6️⃣ CRIAR ASSINATURAS PARA USUÁRIOS SEM SUBSCRIPTION
-- Isso garante que todo usuário cadastrado tenha uma assinatura
INSERT INTO public.subscriptions (
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  created_at,
  updated_at
)
SELECT 
  u.id,
  u.email,
  'trial',
  'free',
  NOW(),
  NOW() + INTERVAL '15 days',
  NOW(),
  NOW()
FROM auth.users u
LEFT JOIN public.subscriptions s ON s.user_id = u.id
WHERE s.id IS NULL
  AND u.email IS NOT NULL
ON CONFLICT (user_id) DO NOTHING;

-- 7️⃣ VERIFICAÇÃO FINAL - LISTAR TUDO NOVAMENTE
SELECT 
  '7. VERIFICAÇÃO FINAL - TODAS AS ASSINATURAS' as etapa,
  COUNT(*) as total_assinaturas
FROM public.subscriptions;

SELECT 
  '7. DETALHES' as etapa,
  s.email,
  s.status,
  s.plan_type,
  TO_CHAR(s.created_at, 'DD/MM/YYYY HH24:MI') as data_hora_criacao,
  CASE 
    WHEN s.created_at::date = CURRENT_DATE THEN '🆕 HOJE'
    WHEN s.created_at::date = CURRENT_DATE - 1 THEN '📅 ONTEM'
    ELSE '📆 ' || (CURRENT_DATE - s.created_at::date) || ' dias atrás'
  END as quando
FROM public.subscriptions s
ORDER BY s.created_at DESC;

-- ================================================
-- ✅ O QUE ESTE SCRIPT FAZ:
-- 1. Conta usuários e assinaturas (incluindo criados hoje)
-- 2. Identifica usuários SEM assinatura
-- 3. CRIA assinaturas trial para usuários sem subscription
-- 4. Lista TODAS as assinaturas do sistema
-- ================================================
