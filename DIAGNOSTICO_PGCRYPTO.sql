-- ============================================
-- DIAGNÓSTICO: PGCRYPTO
-- ============================================

-- 1. VERIFICAR SE EXTENSÃO PGCRYPTO EXISTE
-- ============================================
SELECT 
    extname as extensao,
    extversion as versao,
    '✅ HABILITADA' as status
FROM pg_extension
WHERE extname = 'pgcrypto';

-- Se retornar 0 linhas = NÃO ESTÁ HABILITADA

-- 2. LISTAR TODAS AS EXTENSÕES DISPONÍVEIS
-- ============================================
SELECT 
    name,
    default_version,
    installed_version,
    CASE 
        WHEN installed_version IS NOT NULL THEN '✅ INSTALADA'
        ELSE '❌ NÃO INSTALADA'
    END as status
FROM pg_available_extensions
WHERE name IN ('pgcrypto', 'uuid-ossp', 'pg_stat_statements')
ORDER BY name;

-- 3. TENTAR HABILITAR PGCRYPTO NOVAMENTE
-- ============================================
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;

-- 4. VERIFICAR SE FUNÇÕES CRYPT EXISTEM
-- ============================================
SELECT 
    p.proname as funcao,
    pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname IN ('crypt', 'gen_salt')
ORDER BY p.proname;

-- 5. RESULTADO ESPERADO
-- ============================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
        RAISE NOTICE '✅ pgcrypto está HABILITADA';
        RAISE NOTICE '✅ Funções crypt() e gen_salt() disponíveis';
    ELSE
        RAISE NOTICE '❌ pgcrypto NÃO está habilitada';
        RAISE NOTICE '⚠️ Execute: CREATE EXTENSION pgcrypto;';
    END IF;
END;
$$;
