-- =============================================
-- REMOVER TODOS OS TRIGGERS - VERSÃO SIMPLIFICADA
-- =============================================

-- 1. Ver TODOS os triggers na tabela clientes
SELECT 
    t.tgname AS trigger_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;

-- 2. REMOVER TODOS OS TRIGGERS possíveis
DROP TRIGGER IF EXISTS set_user_id_clientes_trigger ON clientes;
DROP TRIGGER IF EXISTS set_usuario_id_trigger ON clientes;
DROP TRIGGER IF EXISTS auto_set_user_id ON clientes;
DROP TRIGGER IF EXISTS auto_set_usuario_id ON clientes;
DROP TRIGGER IF EXISTS before_insert_clientes ON clientes;
DROP TRIGGER IF EXISTS set_empresa_id_trigger ON clientes;
DROP TRIGGER IF EXISTS handle_new_user ON clientes;
DROP TRIGGER IF EXISTS on_auth_user_created ON clientes;

SELECT '✅ Todos os triggers removidos!' as status;

-- 3. REMOVER TODAS as funções relacionadas
DROP FUNCTION IF EXISTS set_user_id_clientes() CASCADE;
DROP FUNCTION IF EXISTS set_usuario_id_clientes() CASCADE;
DROP FUNCTION IF EXISTS auto_set_user_id() CASCADE;
DROP FUNCTION IF EXISTS auto_set_usuario_id() CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

SELECT '✅ Todas as funções removidas!' as status;

-- 4. Verificar se ainda há triggers
SELECT 
    t.tgname AS trigger_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;

-- 5. Verificar estrutura final da tabela
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;
