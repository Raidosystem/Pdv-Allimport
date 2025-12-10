-- =============================================
-- REMOVER TODOS OS TRIGGERS OCULTOS
-- =============================================

-- 1. Ver TODOS os triggers na tabela clientes (usando pg_trigger)
SELECT 
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    p.proname AS function_name,
    pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;

-- 2. REMOVER TODOS OS TRIGGERS manualmente
DROP TRIGGER IF EXISTS set_user_id_clientes_trigger ON clientes;
DROP TRIGGER IF EXISTS set_usuario_id_trigger ON clientes;
DROP TRIGGER IF EXISTS auto_set_user_id ON clientes;
DROP TRIGGER IF EXISTS auto_set_usuario_id ON clientes;
DROP TRIGGER IF EXISTS before_insert_clientes ON clientes;
DROP TRIGGER IF EXISTS set_empresa_id_trigger ON clientes;

SELECT '✅ Todos os triggers removidos manualmente!' as status;

-- 3. Ver TODAS as funções que mencionam 'usuario_id' ou 'user_id'
SELECT 
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND pg_get_functiondef(p.oid) ILIKE '%usuario_id%';

-- 4. REMOVER TODAS as funções relacionadas
DROP FUNCTION IF EXISTS set_user_id_clientes();
DROP FUNCTION IF EXISTS set_usuario_id_clientes();
DROP FUNCTION IF EXISTS auto_set_user_id();
DROP FUNCTION IF EXISTS auto_set_usuario_id();

SELECT '✅ Todas as funções relacionadas removidas!' as status;

-- 5. Verificar se ainda há triggers
SELECT 
    t.tgname AS trigger_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;

-- 6. Se ainda houver, listar o SQL para removê-los
SELECT 
    'DROP TRIGGER IF EXISTS ' || tgname || ' ON clientes;' AS comando
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;
