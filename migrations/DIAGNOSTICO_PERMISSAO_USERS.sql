-- ========================================
-- DIAGNÓSTICO: Encontrar referência à tabela users
-- ========================================
-- O erro "permission denied for table users" sugere que há:
-- 1. Uma trigger que acessa auth.users
-- 2. Uma função que faz JOIN com users
-- 3. Uma coluna computed/generated que referencia users
-- ========================================

-- 1. Verificar TRIGGERS na tabela ordens_servico
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'ordens_servico';

-- 2. Verificar FUNÇÕES relacionadas
SELECT 
  proname AS function_name,
  prosrc AS function_code
FROM pg_proc
WHERE prosrc ILIKE '%ordens_servico%'
  AND prosrc ILIKE '%users%';

-- 3. Verificar se há colunas GENERATED/COMPUTED
SELECT 
  column_name,
  data_type,
  is_generated,
  generation_expression
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
  AND table_schema = 'public';

-- 4. Verificar se usuário tem permissão em auth.users
SELECT 
  grantee, 
  privilege_type 
FROM information_schema.role_table_grants 
WHERE table_schema = 'auth' 
  AND table_name = 'users';

-- 5. Tentar UPDATE direto (teste manual)
-- DESCOMENTE PARA TESTAR:
-- UPDATE ordens_servico 
-- SET observacoes = 'teste de permissão'
-- WHERE id = '57c2ed01-a5d1-4493-bd60-6a7673186863';
