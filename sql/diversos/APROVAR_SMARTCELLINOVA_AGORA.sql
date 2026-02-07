-- ============================================================================
-- APROVAR smartcellinova@gmail.com AGORA
-- ============================================================================

-- 1️⃣ Ver status atual
SELECT 
  '🔍 STATUS ATUAL:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- 2️⃣ APROVAR usando a função SECURITY DEFINER
SELECT approve_user_after_email_verification('smartcellinova@gmail.com');

-- 3️⃣ Verificar se foi aprovado
SELECT 
  '✅ APÓS APROVAÇÃO:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' 
    THEN '🎉 APROVADO! Deve aparecer no admin agora'
    ELSE '❌ Ainda não aprovado'
  END as resultado
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- 4️⃣ Ver assinatura (trial deve estar ativo)
SELECT 
  '💳 ASSINATURA:' as info,
  email,
  status,
  plan_type,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER as dias_restantes
FROM subscriptions
WHERE email = 'smartcellinova@gmail.com';

-- 5️⃣ Verificar quantos usuários agora devem aparecer no admin
SELECT 
  '📊 TOTAL QUE DEVE APARECER NO ADMIN:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE status = 'approved' AND user_role = 'owner';
