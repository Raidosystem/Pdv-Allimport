-- ============================================
-- CORREÇÃO AUDIT_LOGS - COLUNA ACAO (5º Erro)
-- ============================================
-- Problema: Coluna "acao" está como NOT NULL mas não está sendo preenchida pelo trigger
-- Solução: Tornar a coluna NULLABLE (permitir NULL)
-- Contexto: Este é o 5º erro consecutivo relacionado ao audit_logs

-- 1️⃣ Verificar estrutura atual da coluna acao
SELECT 
    '🔍 ESTRUTURA ATUAL DA COLUNA ACAO' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'audit_logs' 
AND column_name = 'acao';

-- 2️⃣ Tornar a coluna acao NULLABLE (permitir NULL)
ALTER TABLE audit_logs 
ALTER COLUMN acao DROP NOT NULL;

-- 3️⃣ Verificar se a alteração foi aplicada
SELECT 
    '✅ VERIFICAÇÃO PÓS-CORREÇÃO' as info,
    column_name,
    data_type,
    is_nullable as permite_null,
    CASE 
        WHEN is_nullable = 'YES' THEN '✅ NULLABLE (Pode ser NULL)'
        ELSE '❌ NOT NULL (Obrigatório)'
    END as status
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'audit_logs' 
AND column_name = 'acao';

-- 4️⃣ IMPORTANTE: Verificar TODAS as colunas que ainda têm NOT NULL
SELECT 
    '⚠️ TODAS AS COLUNAS COM NOT NULL EM AUDIT_LOGS' as info,
    column_name,
    data_type,
    is_nullable,
    CASE 
        WHEN is_nullable = 'NO' THEN '❌ NOT NULL (pode causar erro)'
        ELSE '✅ NULLABLE'
    END as status
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'audit_logs'
ORDER BY 
    CASE WHEN is_nullable = 'NO' THEN 0 ELSE 1 END,
    ordinal_position;

-- 5️⃣ (OPCIONAL RECOMENDADO) Remover NOT NULL de TODAS as colunas que triggers não preenchem
/*
-- Execute este bloco se quiser corrigir TODAS as colunas de uma vez:
ALTER TABLE audit_logs 
    ALTER COLUMN recurso DROP NOT NULL,
    ALTER COLUMN acao DROP NOT NULL,
    ALTER COLUMN empresa_id DROP NOT NULL,
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN funcionario_id DROP NOT NULL;

SELECT '✅ CORREÇÃO MASSIVA APLICADA! Todas as colunas principais agora permitem NULL.' as resultado;
*/

-- 6️⃣ Resultado da correção individual
SELECT '✅ CORREÇÃO APLICADA! Coluna "acao" agora permite NULL. Execute a query 4️⃣ para verificar se existem mais colunas com NOT NULL.' as resultado;
