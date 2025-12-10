-- ============================================
-- CORREÇÃO AUDIT_LOGS - COLUNA RECURSO
-- ============================================
-- Problema: Coluna "recurso" está como NOT NULL mas não está sendo preenchida pelo trigger
-- Solução: Tornar a coluna NULLABLE (permitir NULL)

-- 1️⃣ Verificar estrutura atual da coluna recurso
SELECT 
    '🔍 ESTRUTURA ATUAL DA COLUNA RECURSO' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'audit_logs' 
AND column_name = 'recurso';

-- 2️⃣ Tornar a coluna recurso NULLABLE (permitir NULL)
ALTER TABLE audit_logs 
ALTER COLUMN recurso DROP NOT NULL;

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
AND column_name = 'recurso';

-- 4️⃣ Verificar todas as colunas de audit_logs e suas constraints
SELECT 
    '📋 TODAS AS COLUNAS DE AUDIT_LOGS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'audit_logs'
ORDER BY ordinal_position;

-- 5️⃣ (OPCIONAL) Se a coluna não existir, criar como NULLABLE
/*
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'recurso'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN recurso TEXT NULL;
    END IF;
END $$;
*/

SELECT '✅ CORREÇÃO APLICADA! Coluna "recurso" agora permite NULL. Teste a venda novamente.' as resultado;
