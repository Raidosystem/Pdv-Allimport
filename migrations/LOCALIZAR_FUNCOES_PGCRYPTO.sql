-- ============================================
-- DIAGNÓSTICO E CORREÇÃO: LOCALIZAR FUNÇÕES PGCRYPTO
-- ============================================

-- 1. VERIFICAR EM QUAL SCHEMA ESTÁ O PGCRYPTO
-- ============================================
SELECT 
    e.extname,
    n.nspname as schema_extensao
FROM pg_extension e
JOIN pg_namespace n ON e.extnamespace = n.oid
WHERE e.extname = 'pgcrypto';

-- 2. LOCALIZAR FUNÇÕES crypt E gen_salt
-- ============================================
SELECT 
    p.proname as funcao,
    n.nspname as schema,
    pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname IN ('crypt', 'gen_salt')
ORDER BY n.nspname, p.proname;

-- 3. TESTAR FUNÇÕES SEM PREFIXO
-- ============================================
DO $$
DECLARE
    v_hash TEXT;
BEGIN
    RAISE NOTICE '🔍 Testando funções pgcrypto...';
    
    -- Testar gen_salt SEM prefixo
    BEGIN
        v_hash := gen_salt('bf');
        RAISE NOTICE '✅ gen_salt() funciona SEM prefixo: %', SUBSTRING(v_hash, 1, 10);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ gen_salt() SEM prefixo falhou: %', SQLERRM;
    END;
    
    -- Testar crypt SEM prefixo
    BEGIN
        v_hash := crypt('teste123', gen_salt('bf'));
        RAISE NOTICE '✅ crypt() funciona SEM prefixo: %', SUBSTRING(v_hash, 1, 20);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ crypt() SEM prefixo falhou: %', SQLERRM;
    END;
END;
$$;

-- 4. RESULTADO E RECOMENDAÇÃO
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '📋 DIAGNÓSTICO COMPLETO';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ Se as funções funcionaram SEM prefixo:';
    RAISE NOTICE '   → Use: gen_salt() e crypt() (sem public.)';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ Se as funções estão em outro schema:';
    RAISE NOTICE '   → Use: extensions.gen_salt() e extensions.crypt()';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END;
$$;
