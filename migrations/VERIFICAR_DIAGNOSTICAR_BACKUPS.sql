-- =====================================================
-- DIAGNÓSTICO COMPLETO DO SISTEMA DE BACKUPS
-- =====================================================

-- 1. Verificar se a tabela backups existe
SELECT 
  table_name,
  table_schema
FROM information_schema.tables
WHERE table_name = 'backups'
AND table_schema = 'public';

-- 2. Verificar estrutura da tabela backups
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'backups'
ORDER BY ordinal_position;

-- 3. Verificar RLS na tabela backups
SELECT 
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'backups';

-- 4. Verificar políticas RLS existentes
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
AND tablename = 'backups';

-- 5. Contar registros na tabela backups
SELECT COUNT(*) as total_backups
FROM public.backups;

-- 6. Verificar coluna backup_config em empresas
SELECT 
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'empresas'
AND column_name = 'backup_config';

-- 7. Verificar empresas
SELECT 
  id,
  nome,
  backup_config IS NOT NULL as tem_config
FROM public.empresas
LIMIT 5;
