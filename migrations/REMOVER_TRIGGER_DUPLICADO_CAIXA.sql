-- ========================================
-- REMOVER TRIGGER DUPLICADO DE MOVIMENTAÇÃO DE CAIXA
-- ========================================
-- 
-- PROBLEMA: Cada venda cria DUAS entradas em movimentacoes_caixa:
-- 1. Uma pelo trigger do banco (descrição: "Venda #[id]")
-- 2. Outra pelo código da aplicação (descrição: "Venda: Produto - Método")
--
-- SOLUÇÃO: Remover o trigger e deixar apenas o código da aplicação
-- que cria descrições mais detalhadas
-- ========================================

-- 1. Remover o trigger que está duplicando
DROP TRIGGER IF EXISTS trigger_registrar_movimentacao_caixa ON vendas;

-- 2. Remover a função associada
DROP FUNCTION IF EXISTS registrar_movimentacao_caixa() CASCADE;

-- 3. Verificar se foi removido
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Trigger removido com sucesso!'
        ELSE '⚠️ Trigger ainda existe!'
    END AS status
FROM pg_trigger
WHERE tgrelid = 'vendas'::regclass
  AND tgname = 'trigger_registrar_movimentacao_caixa';

-- 4. Listar triggers restantes na tabela vendas (para conferência)
SELECT 
    tgname AS trigger_name,
    pg_get_triggerdef(oid) AS trigger_definition
FROM pg_trigger
WHERE tgrelid = 'vendas'::regclass
ORDER BY tgname;

-- ========================================
-- IMPORTANTE: 
-- Após executar, testar uma venda para confirmar que:
-- - Apenas UMA entrada é criada em movimentacoes_caixa
-- - A descrição está detalhada (com nome do produto e método)
-- ========================================
