-- ========================================
-- 🔍 DIAGNÓSTICO COMPLETO DA TABELA SUBSCRIPTIONS
-- ========================================

-- 1️⃣ Verificar estrutura atual da tabela
SELECT 
  '📋 ESTRUTURA DA TABELA SUBSCRIPTIONS' as titulo;

SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'subscriptions'
ORDER BY ordinal_position;

-- 2️⃣ Verificar constraints (incluindo CHECK constraints)
SELECT 
  '🔒 CONSTRAINTS DA TABELA' as titulo;

SELECT 
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'subscriptions'::regclass;

-- 3️⃣ Verificar valores únicos existentes em plan_type
SELECT 
  '📊 VALORES ATUAIS EM PLAN_TYPE' as titulo;

SELECT 
  plan_type,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY plan_type
ORDER BY quantidade DESC;

-- 4️⃣ Verificar valores únicos existentes em status
SELECT 
  '📊 VALORES ATUAIS EM STATUS' as titulo;

SELECT 
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status
ORDER BY quantidade DESC;

-- 5️⃣ Mostrar todos os registros atuais
SELECT 
  '📋 TODOS OS REGISTROS ATUAIS' as titulo;

SELECT 
  id,
  user_id,
  email,
  status,
  plan_type,
  subscription_end_date,
  created_at
FROM subscriptions
ORDER BY created_at DESC;
