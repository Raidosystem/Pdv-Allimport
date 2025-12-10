-- =====================================================
-- DIAGNÓSTICO COMPLETO DO RLS
-- =====================================================

-- 1. VER TODAS AS POLÍTICAS DA TABELA CLIENTES
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual as "using_clause",
  with_check as "with_check_clause"
FROM pg_policies 
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 2. VER TODAS AS POLÍTICAS QUE MENCIONAM "USERS"
SELECT 
  schemaname,
  tablename,
  policyname,
  qual as "using_clause",
  with_check as "with_check_clause"
FROM pg_policies 
WHERE 
  tablename = 'clientes' 
  AND (qual::text LIKE '%users%' OR with_check::text LIKE '%users%')
ORDER BY tablename, policyname;

-- 3. VER TODOS OS TRIGGERS NA TABELA CLIENTES
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'clientes';

-- 4. VER COLUNAS DA TABELA CLIENTES
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 5. VERIFICAR SE EXISTE CONSTRAINT COM REFERÊNCIA A USERS
SELECT
  constraint_name,
  constraint_type,
  table_name
FROM information_schema.table_constraints
WHERE table_name = 'clientes'
ORDER BY constraint_name;

-- 6. VER SEQUÊNCIAS DE TRIGGERS
SELECT 
  trigger_schema,
  trigger_name,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'clientes'
ORDER BY trigger_name;
