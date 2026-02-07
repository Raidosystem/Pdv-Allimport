-- ============================================
-- VERIFICAR QUAL FUNÇÃO/TRIGGER ESTÁ ATIVA
-- ============================================

-- 1. Ver a função atual que cria empresa
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'create_empresa_for_new_user';

-- 2. Ver triggers ativos
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name LIKE '%empresa%' OR trigger_name LIKE '%trial%';

-- 3. Ver assinatura do último usuário criado
SELECT 
  u.email,
  u.created_at as data_cadastro,
  s.status,
  s.plan_type,
  s.trial_start_date,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW())) as dias_restantes,
  s.subscription_start_date,
  s.subscription_end_date
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 5;

-- 4. Ver subscription status do último usuário
SELECT 
  email,
  check_subscription_status(email) as status
FROM auth.users
ORDER BY created_at DESC
LIMIT 3;
