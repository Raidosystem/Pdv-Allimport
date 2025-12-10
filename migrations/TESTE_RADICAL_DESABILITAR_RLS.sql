-- =============================================
-- TESTE RADICAL: DESABILITAR RLS E VERIFICAR
-- =============================================

-- 1. DESABILITAR RLS
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;

SELECT '⚠️ RLS DESABILITADO para teste' as status;

-- 2. Verificar se há alguma coluna 'usuario_id' que não vimos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 3. Ver TODAS as foreign keys da tabela (usando outra query)
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS foreign_table_name,
    a.attname AS column_name,
    af.attname AS foreign_column_name
FROM pg_constraint AS c
JOIN pg_attribute AS a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
JOIN pg_attribute AS af ON af.attnum = ANY(c.confkey) AND af.attrelid = c.confrelid
WHERE c.contype = 'f'
    AND conrelid::regclass::text = 'clientes';

-- 4. VERIFICAR se há triggers ocultos usando pg_trigger
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    proname AS function_name,
    prosrc AS function_source
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid::regclass::text = 'clientes'
    AND tgisinternal = false;

-- 5. SOLUÇÃO EXTREMA: Remover a coluna user_id temporariamente
-- (Comentado - só use se necessário)
-- ALTER TABLE clientes DROP COLUMN IF EXISTS user_id CASCADE;
-- ALTER TABLE clientes DROP COLUMN IF EXISTS usuario_id CASCADE;
-- SELECT '⚠️ Colunas user_id/usuario_id removidas!' as status;
