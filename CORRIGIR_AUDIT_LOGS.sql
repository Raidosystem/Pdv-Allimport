-- ============================================
-- CORREÇÃO CRÍTICA - TABELA AUDIT_LOGS
-- ============================================

-- 1️⃣ Verificar estrutura atual da audit_logs
SELECT 
    '📋 ESTRUTURA AUDIT_LOGS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'audit_logs'
ORDER BY ordinal_position;

-- 2️⃣ Adicionar coluna "tabela" se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'tabela'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN tabela TEXT;
        RAISE NOTICE '✅ Coluna tabela adicionada à audit_logs';
    ELSE
        RAISE NOTICE '⚠️ Coluna tabela já existe';
    END IF;

    -- Adicionar outras colunas comuns de auditoria se não existirem
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'operacao'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN operacao TEXT;
        RAISE NOTICE '✅ Coluna operacao adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'registro_id'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN registro_id UUID;
        RAISE NOTICE '✅ Coluna registro_id adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'dados_anteriores'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN dados_anteriores JSONB;
        RAISE NOTICE '✅ Coluna dados_anteriores adicionada';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'audit_logs' AND column_name = 'dados_novos'
    ) THEN
        ALTER TABLE audit_logs ADD COLUMN dados_novos JSONB;
        RAISE NOTICE '✅ Coluna dados_novos adicionada';
    END IF;
END $$;

-- 3️⃣ Verificar triggers que usam audit_logs
SELECT 
    '⚡ TRIGGERS QUE PODEM USAR AUDIT_LOGS' as info,
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE action_statement ILIKE '%audit_logs%'
   OR trigger_name ILIKE '%audit%'
ORDER BY event_object_table, trigger_name;

-- 4️⃣ Verificar função de auditoria
SELECT 
    '🔍 FUNÇÃO DE AUDITORIA' as info,
    routine_name,
    routine_definition
FROM information_schema.routines
WHERE routine_name ILIKE '%audit%'
   OR routine_definition ILIKE '%audit_logs%';

-- 5️⃣ OPÇÃO A: Desabilitar temporariamente triggers de auditoria em vendas
-- (Execute apenas se quiser desabilitar auditoria)
/*
DROP TRIGGER IF EXISTS audit_vendas_changes ON vendas;
DROP TRIGGER IF EXISTS log_vendas_changes ON vendas;
DROP TRIGGER IF EXISTS vendas_audit_trigger ON vendas;
*/

SELECT '✅ CORREÇÃO APLICADA! Teste a venda novamente.' as resultado;
