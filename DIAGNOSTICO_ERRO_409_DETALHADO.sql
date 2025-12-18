-- =====================================================
-- 🔍 DIAGNÓSTICO DETALHADO: ERRO 409 PERSISTENTE
-- =====================================================
-- Data: 2025-12-18
-- Problema: Erro 409 ao inserir produtos mesmo após correção de triggers
-- =====================================================

-- 1️⃣ VERIFICAR CONSTRAINTS UNIQUE NA TABELA
SELECT 
    '🔒 CONSTRAINTS UNIQUE' AS info,
    conname AS constraint_name,
    pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'produtos'::regclass
    AND contype = 'u'
ORDER BY conname;

-- 2️⃣ VERIFICAR ÍNDICES UNIQUE
SELECT 
    '🔑 ÍNDICES UNIQUE' AS info,
    indexname AS index_name,
    indexdef AS definition
FROM pg_indexes
WHERE tablename = 'produtos'
    AND indexdef LIKE '%UNIQUE%'
ORDER BY indexname;

-- 3️⃣ VERIFICAR TODOS OS TRIGGERS ATIVOS
SELECT 
    '⚡ TRIGGERS ATIVOS' AS info,
    tgname AS trigger_name,
    tgenabled AS habilitado,
    CASE tgtype
        WHEN 7 THEN 'BEFORE INSERT'
        WHEN 19 THEN 'BEFORE UPDATE'
        WHEN 27 THEN 'BEFORE INSERT OR UPDATE'
        WHEN 29 THEN 'AFTER INSERT/UPDATE/DELETE'
        ELSE tgtype::text
    END AS tipo,
    pg_get_triggerdef(oid) AS definition
FROM pg_trigger
WHERE tgrelid = 'produtos'::regclass
    AND tgisinternal = false
ORDER BY tgtype, tgname;

-- 4️⃣ VERIFICAR FUNÇÃO DO TRIGGER codigo_interno
SELECT 
    '📋 FUNÇÃO TRIGGER CODIGO_INTERNO' AS info,
    proname AS function_name,
    prosrc AS function_code
FROM pg_proc
WHERE proname LIKE '%codigo_interno%'
    OR proname LIKE '%auto_fill%';

-- 5️⃣ VERIFICAR SE HÁ PRODUTOS COM codigo_interno DUPLICADO
SELECT 
    '🔄 DUPLICADOS codigo_interno' AS info,
    codigo_interno,
    user_id,
    COUNT(*) AS total
FROM produtos
WHERE codigo_interno IS NOT NULL
GROUP BY codigo_interno, user_id
HAVING COUNT(*) > 1
ORDER BY total DESC;

-- 6️⃣ VERIFICAR ÚLTIMO codigo_interno GERADO
SELECT 
    '📊 ÚLTIMOS CÓDIGOS INTERNOS' AS info,
    codigo_interno,
    nome,
    user_id,
    updated_at
FROM produtos
WHERE codigo_interno IS NOT NULL
ORDER BY updated_at DESC
LIMIT 10;

-- 7️⃣ TESTAR INSERT DIRETO (VAI FALHAR SE HOUVER CONFLITO)
-- IMPORTANTE: Execute apenas para diagnóstico, depois DELETE o registro teste

/*
DO $$
DECLARE
    test_user_id UUID := auth.uid();
BEGIN
    RAISE NOTICE '🧪 Testando INSERT para user_id: %', test_user_id;
    
    INSERT INTO produtos (
        nome,
        preco,
        estoque,
        ativo,
        user_id
    ) VALUES (
        'TESTE DIAGNÓSTICO 409',
        10.00,
        1,
        true,
        test_user_id
    );
    
    RAISE NOTICE '✅ INSERT bem-sucedido!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO: % - %', SQLSTATE, SQLERRM;
END $$;
*/

-- 8️⃣ VERIFICAR POLÍTICAS RLS DE INSERT
SELECT 
    '🛡️ POLÍTICAS RLS INSERT' AS info,
    policyname,
    with_check AS expressao_with_check
FROM pg_policies
WHERE tablename = 'produtos' 
    AND cmd = 'INSERT';

-- 9️⃣ VERIFICAR SE HÁ SEQUENCE PARA codigo_interno
SELECT 
    '🔢 SEQUENCES RELACIONADAS' AS info,
    sequence_name,
    start_value,
    minimum_value,
    maximum_value,
    increment
FROM information_schema.sequences
WHERE sequence_name LIKE '%produto%'
    OR sequence_name LIKE '%codigo%';

-- 🔟 VERIFICAR LOG DE ERROS RECENTES (se disponível)
-- Nota: Nem todas as instalações PostgreSQL têm pg_stat_statements habilitado
/*
SELECT 
    '📝 QUERIES COM ERRO RECENTE' AS info,
    query,
    calls,
    rows,
    mean_exec_time
FROM pg_stat_statements
WHERE query LIKE '%INSERT INTO produtos%'
    AND calls > 0
ORDER BY calls DESC
LIMIT 5;
*/

-- =====================================================
-- 📊 RESUMO DO DIAGNÓSTICO
-- =====================================================
SELECT 
    '📊 RESUMO' AS secao,
    (SELECT COUNT(*) FROM pg_constraint WHERE conrelid = 'produtos'::regclass AND contype = 'u') AS total_unique_constraints,
    (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'produtos' AND indexdef LIKE '%UNIQUE%') AS total_unique_indexes,
    (SELECT COUNT(*) FROM pg_trigger WHERE tgrelid = 'produtos'::regclass AND tgisinternal = false) AS total_triggers,
    (SELECT COUNT(*) FROM produtos WHERE codigo_interno IS NULL) AS produtos_sem_codigo_interno;

-- =====================================================
-- 🎯 PRÓXIMOS PASSOS:
-- =====================================================
-- 1. Execute este script inteiro no Supabase SQL Editor
-- 2. Copie TODOS os resultados e cole na conversa
-- 3. Especialmente preste atenção em:
--    - Índices UNIQUE que podem estar causando conflito
--    - Triggers que geram codigo_interno automaticamente
--    - Duplicatas de codigo_interno
-- =====================================================
