-- =====================================================
-- DIAGNÓSTICO COMPLETO DA TABELA SUBSCRIPTIONS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- para diagnosticar o problema do erro 400
-- =====================================================

-- 1. Ver TODAS as colunas disponíveis
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default,
  character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'subscriptions'
ORDER BY ordinal_position;

-- 2. Testar UPDATE simples (mesmo que o código faz)
-- ATENÇÃO: Substitua o user_id pelo que está dando erro
DO $$
DECLARE
  v_user_id uuid := '922d4f20-6c99-4438-a922-e275eb527c0b';
  v_now timestamptz := now();
  v_end_date timestamptz := now() + interval '30 days';
BEGIN
  -- Tentar atualizar exatamente como o código faz
  UPDATE subscriptions
  SET
    updated_at = v_now,
    status = 'trial',
    trial_end_date = v_end_date,
    trial_start_date = COALESCE(trial_start_date, v_now),
    subscription_start_date = NULL,
    subscription_end_date = NULL
  WHERE user_id = v_user_id;
  
  RAISE NOTICE 'UPDATE executado com sucesso!';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'ERRO: % - %', SQLSTATE, SQLERRM;
END;
$$;

-- 3. Ver dados atuais da subscription
SELECT 
  user_id,
  email,
  status,
  trial_start_date,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  plan_type,
  created_at,
  updated_at
FROM subscriptions
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- 4. Verificar RLS (Row Level Security)
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'subscriptions';

-- 5. Verificar se há triggers que podem estar causando erro
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'subscriptions';
