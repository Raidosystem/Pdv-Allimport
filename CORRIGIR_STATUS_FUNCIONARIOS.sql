-- ============================================
-- CORRIGIR COLUNA STATUS E SINCRONIZAÇÃO COM ATIVO
-- ============================================
-- Este script garante que a coluna 'status' existe
-- e cria triggers para sincronizar status ↔ ativo
-- ============================================

-- PASSO 1: Adicionar coluna status (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN status VARCHAR(20) DEFAULT 'ativo' 
        CHECK (status IN ('ativo', 'pausado', 'inativo'));
        
        RAISE NOTICE '✅ Coluna status adicionada com sucesso!';
    ELSE
        RAISE NOTICE '✅ Coluna status já existe.';
    END IF;
END $$;

-- PASSO 2: Sincronizar dados existentes (status baseado em ativo)
UPDATE funcionarios
SET status = CASE 
    WHEN ativo = true THEN 'ativo'
    WHEN ativo = false THEN 'pausado'
    ELSE 'inativo'
END
WHERE status IS NULL OR status = '';

-- PASSO 3: Criar função de sincronização status → ativo
CREATE OR REPLACE FUNCTION sync_funcionario_status_to_ativo()
RETURNS TRIGGER AS $$
BEGIN
    -- Quando status é alterado, atualizar ativo
    IF NEW.status = 'ativo' THEN
        NEW.ativo := true;
    ELSE
        NEW.ativo := false;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PASSO 4: Criar função de sincronização ativo → status
CREATE OR REPLACE FUNCTION sync_funcionario_ativo_to_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Quando ativo é alterado, atualizar status
    IF NEW.ativo = true THEN
        NEW.status := 'ativo';
    ELSE
        -- Se não foi especificado status, usar 'pausado'
        IF NEW.status = 'ativo' OR NEW.status IS NULL THEN
            NEW.status := 'pausado';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PASSO 5: Criar triggers (DROP primeiro se existirem)
DROP TRIGGER IF EXISTS trigger_sync_status_to_ativo ON funcionarios;
DROP TRIGGER IF EXISTS trigger_sync_ativo_to_status ON funcionarios;

CREATE TRIGGER trigger_sync_status_to_ativo
    BEFORE INSERT OR UPDATE OF status ON funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION sync_funcionario_status_to_ativo();

CREATE TRIGGER trigger_sync_ativo_to_status
    BEFORE INSERT OR UPDATE OF ativo ON funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION sync_funcionario_ativo_to_status();

-- PASSO 6: Atualizar RLS policies (se necessário)
-- Garantir que status está visível em todas as policies existentes

-- PASSO 7: Verificar resultado
SELECT 
    '✅ CONFIGURAÇÃO FINAL' as info,
    id,
    nome,
    ativo,
    status,
    CASE 
        WHEN (ativo = true AND status = 'ativo') THEN '✅ Sincronizado'
        WHEN (ativo = false AND status IN ('pausado', 'inativo')) THEN '✅ Sincronizado'
        ELSE '⚠️ Fora de sincronia'
    END as sincronia
FROM funcionarios
ORDER BY nome
LIMIT 20;

-- PASSO 8: Testar atualização manual
/*
-- Teste 1: Atualizar status (ativo deve ser atualizado automaticamente)
UPDATE funcionarios 
SET status = 'pausado' 
WHERE id = 'SEU_ID_AQUI';

-- Teste 2: Atualizar ativo (status deve ser atualizado automaticamente)
UPDATE funcionarios 
SET ativo = true 
WHERE id = 'SEU_ID_AQUI';

-- Verificar resultado
SELECT id, nome, ativo, status 
FROM funcionarios 
WHERE id = 'SEU_ID_AQUI';
*/

-- ============================================
-- RESUMO
-- ============================================
-- ✅ Coluna status criada/verificada
-- ✅ Dados existentes sincronizados
-- ✅ Triggers criados para sincronização automática
-- ✅ Agora você pode usar TANTO ativo QUANTO status
-- ============================================

SELECT 
    '🎉 CONCLUÍDO!' as status,
    'Agora você pode atualizar funcionarios.status OU funcionarios.ativo' as mensagem,
    'Ambos serão sincronizados automaticamente pelos triggers' as observacao;
