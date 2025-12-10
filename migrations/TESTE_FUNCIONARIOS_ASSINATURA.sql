-- ============================================
-- 🧪 TESTE: Verificar funcionários e suas assinaturas
-- ============================================

-- 1️⃣ LISTAR FUNCIONÁRIOS ATIVOS DO CRISTIANO
SELECT 
  '=== FUNCIONÁRIOS CADASTRADOS ===' as info,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id,
  u_dono.email as email_dono
FROM funcionarios f
LEFT JOIN auth.users u_dono ON f.empresa_id = u_dono.id
WHERE f.empresa_id = (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
AND f.status = 'ativo'
ORDER BY f.created_at DESC;

-- 2️⃣ TESTAR check_subscription_status PARA CADA FUNCIONÁRIO
-- (Substitua os emails abaixo pelos emails reais encontrados na query acima)

-- Exemplo de teste (ajuste com emails reais):
-- SELECT 
--   '=== TESTE: FUNCIONÁRIO 1 ===' as info,
--   check_subscription_status('funcionario1@email.com') as resultado;

-- SELECT 
--   '=== TESTE: FUNCIONÁRIO 2 ===' as info,
--   check_subscription_status('funcionario2@email.com') as resultado;

-- 3️⃣ VERIFICAR ASSINATURA DO DONO (CRISTIANO)
SELECT 
  '=== ASSINATURA DO DONO ===' as info,
  s.id,
  s.user_id,
  s.email,
  s.status,
  s.plan_type,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW()))::integer as dias_restantes
FROM subscriptions s
WHERE s.user_id = (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
);

-- ============================================
-- 📋 RESULTADO ESPERADO
-- ============================================
-- 
-- FUNCIONÁRIOS:
-- - Devem ter empresa_id = UUID do Cristiano
-- - Devem ter status = 'ativo'
-- - tipo_admin deve ser NULL ou diferente de 'admin_empresa'
--
-- TESTE check_subscription_status:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "premium",
--   "access_allowed": true,    ← DEVE SER TRUE!
--   "subscription_end_date": "2026-12-01...",
--   "days_remaining": 358,
--   "is_employee": true,        ← Confirma que é funcionário
--   "empresa_id": "uuid-do-cristiano"
-- }
--
-- ============================================
