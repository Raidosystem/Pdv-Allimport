-- ================================================
-- FORCE DISABLE RLS - API ACCESS FIX
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1. Remover todas as policies existentes
DROP POLICY IF EXISTS "Enable read access for all users" ON produtos;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON produtos;
DROP POLICY IF EXISTS "Enable update for users based on email" ON produtos;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON produtos;

-- 2. Desabilitar RLS definitivamente
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

-- 3. Garantir que anon tem acesso
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO authenticated;

-- 4. Verificar permissões
SELECT 
  schemaname,
  tablename,
  rowsecurity,
  hasselect,
  hasinsert,
  hasupdate,
  hasdelete
FROM pg_tables 
LEFT JOIN information_schema.table_privileges ON table_name = tablename
WHERE tablename = 'produtos' 
AND schemaname = 'public';

-- 5. Teste final de acesso
SELECT COUNT(*) as total FROM produtos;
