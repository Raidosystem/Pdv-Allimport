-- =====================================================
-- VERIFICAR RLS E CONSTRAINTS DA TABELA SUBSCRIPTIONS
-- =====================================================

-- 1. Verificar RLS (Row Level Security)
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'subscriptions'
ORDER BY cmd, policyname;

-- 2. Verificar CHECK constraints
SELECT
  con.conname AS constraint_name,
  pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public'
  AND rel.relname = 'subscriptions'
  AND con.contype = 'c'; -- Check constraint

-- 3. Verificar se o RLS está ativado
SELECT 
  schemaname,
  tablename,
  rowsecurity AS rls_enabled,
  CASE 
    WHEN rowsecurity THEN '✅ RLS ATIVADO'
    ELSE '❌ RLS DESATIVADO'
  END AS status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'subscriptions';

-- 4. Testar UPDATE manualmente (substitua o user_id)
-- ATENÇÃO: Este UPDATE será executado! Comente se não quiser testar.
/*
UPDATE subscriptions
SET
  updated_at = now(),
  status = 'trial',
  plan_type = 'trial',
  trial_end_date = now() + interval '30 days',
  trial_start_date = COALESCE(trial_start_date, now()),
  payment_method = 'trial',
  amount = 0.00,
  subscription_start_date = NULL,
  subscription_end_date = NULL,
  last_payment_date = NULL,
  next_payment_date = NULL
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- Ver o resultado
SELECT * FROM subscriptions 
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';
*/
