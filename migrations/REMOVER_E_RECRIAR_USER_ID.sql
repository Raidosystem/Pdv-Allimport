-- =============================================
-- BUSCA SIMPLIFICADA DE TRIGGER OCULTO
-- =============================================

-- 1. Listar TODOS os triggers na tabela clientes (mesmo os que parecem não existir)
SELECT 
    t.oid,
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes';

-- 2. Buscar todas as funções do schema public
SELECT 
    p.proname AS function_name
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
ORDER BY p.proname;

-- 3. SOLUÇÃO: Remover a coluna user_id e recriá-la
ALTER TABLE clientes DROP COLUMN IF EXISTS user_id CASCADE;

SELECT '⚠️ Coluna user_id REMOVIDA com CASCADE!' as status;

-- 4. Recriar a coluna user_id SEM foreign key
ALTER TABLE clientes ADD COLUMN user_id UUID;

SELECT '✅ Coluna user_id RECRIADA sem constraints!' as status;

-- 5. Verificar se ainda há triggers
SELECT 
    t.tgname AS trigger_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
    AND t.tgisinternal = false;

-- 6. Verificar estrutura final
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'clientes'
    AND column_name LIKE '%user%';
