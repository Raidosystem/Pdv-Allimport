-- =============================================
-- TESTE DE AUTENTICAÇÃO E PERMISSÕES
-- =============================================

-- IMPORTANTE: Execute este script quando estiver:
-- 1. LOGADO no sistema frontend
-- 2. Com o navegador aberto na aplicação
-- 3. NO SQL EDITOR do Supabase Dashboard (não na aplicação)

-- 1. Verificar contexto de autenticação (SQL Editor)
SELECT 
    auth.uid() as user_id_sql_editor,
    auth.role() as role_sql_editor,
    current_user as postgres_user;

-- 2. Ver todos os usuários registrados
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- 3. Verificar se a tabela clientes tem RLS habilitado
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'clientes';

-- 4. Ver políticas atuais
SELECT 
    policyname,
    cmd,
    roles,
    permissive
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd;

-- =============================================
-- OPÇÃO 1: DESABILITAR RLS TEMPORARIAMENTE
-- (Use apenas em desenvolvimento, NUNCA em produção!)
-- =============================================
-- ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
-- SELECT '⚠️ RLS DESABILITADO - Use apenas em desenvolvimento!' as status;

-- =============================================
-- OPÇÃO 2: CRIAR POLÍTICA PARA ROLE ANON
-- (Permite acesso com a chave anônima)
-- =============================================

-- Remover políticas antigas
DROP POLICY IF EXISTS clientes_select_all ON clientes;
DROP POLICY IF EXISTS clientes_insert_all ON clientes;
DROP POLICY IF EXISTS clientes_update_all ON clientes;
DROP POLICY IF EXISTS clientes_delete_all ON clientes;

-- Criar políticas para authenticated E anon
CREATE POLICY clientes_select_all ON clientes
FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY clientes_insert_all ON clientes
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY clientes_update_all ON clientes
FOR UPDATE
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY clientes_delete_all ON clientes
FOR DELETE
TO authenticated, anon
USING (true);

SELECT '✅ Políticas criadas para authenticated E anon!' as status;

-- 6. Verificar políticas finais
SELECT 
    policyname,
    cmd,
    roles::text[] as roles
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd;
