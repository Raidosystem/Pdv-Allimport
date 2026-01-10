-- ============================================================================
-- VERIFICAR ÚLTIMO USUÁRIO CADASTRADO
-- ============================================================================
-- Ver se o trigger criou user_approvals, empresa e subscription
-- ============================================================================

-- 1. Último usuário criado em auth.users
SELECT 
  id as user_id,
  email,
  created_at,
  email_confirmed_at,
  'Última conta criada' as info
FROM auth.users
ORDER BY created_at DESC
LIMIT 1;

-- 2. Verificar se ele tem registro em user_approvals
SELECT 
  user_id,
  email,
  user_role,
  status,
  created_at,
  'Tem em user_approvals?' as status_tabela
FROM user_approvals
WHERE user_id = (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1);

-- 3. Verificar se ele tem empresa
SELECT 
  user_id,
  nome,
  email,
  tipo_conta,
  data_fim_teste,
  created_at,
  'Tem empresa?' as status_tabela
FROM empresas
WHERE user_id = (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1);

-- 4. Verificar se ele tem subscription
SELECT 
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  created_at,
  'Tem subscription?' as status_tabela
FROM subscriptions
WHERE user_id = (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1);

-- 5. Verificar se os triggers estão ativos
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users'
ORDER BY trigger_name;
