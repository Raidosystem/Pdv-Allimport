-- ========================================
-- INVESTIGAR E CORRIGIR FUNÇÃO registrar_movimentacao_caixa
-- ========================================

-- 1. Ver o código da função registrar_movimentacao_caixa
SELECT 
    proname AS function_name,
    pg_get_functiondef(oid) AS function_definition
FROM pg_proc
WHERE proname = 'registrar_movimentacao_caixa';

-- 2. Verificar se a função criar_backup_automatico_diario existe
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'criar_backup_automatico_diario') 
        THEN '✅ Função criar_backup_automatico_diario existe'
        ELSE '❌ Função criar_backup_automatico_diario NÃO existe'
    END AS status;

-- 3. SOLUÇÃO: Remover o trigger que está causando problema
DROP TRIGGER IF EXISTS trigger_registrar_movimentacao_caixa ON vendas;

-- 4. Remover a função problemática
DROP FUNCTION IF EXISTS registrar_movimentacao_caixa() CASCADE;

-- 5. Recriar a função SEM a chamada ao backup
CREATE OR REPLACE FUNCTION registrar_movimentacao_caixa()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar movimentação de caixa quando uma venda é criada
    -- REMOVIDO: chamada para criar_backup_automatico_diario()
    
    -- Apenas registra a movimentação sem fazer backup
    INSERT INTO movimentacoes_caixa (
        caixa_id,
        tipo,
        valor,
        descricao,
        venda_id,
        user_id,
        empresa_id,
        data
    ) VALUES (
        NEW.caixa_id,
        'entrada',
        NEW.total,
        'Venda #' || NEW.id::TEXT,
        NEW.id,
        NEW.user_id,
        NEW.empresa_id,
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Recriar o trigger
CREATE TRIGGER trigger_registrar_movimentacao_caixa
    AFTER INSERT ON vendas
    FOR EACH ROW
    EXECUTE FUNCTION registrar_movimentacao_caixa();

-- 7. Verificar se funcionou
SELECT 
    '✅ Função e trigger recriados com sucesso!' AS status,
    COUNT(*) AS triggers_na_tabela_vendas
FROM pg_trigger
WHERE tgrelid = 'vendas'::regclass
  AND tgname = 'trigger_registrar_movimentacao_caixa';
