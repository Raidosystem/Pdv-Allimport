-- 🔧 CORREÇÃO DEFINITIVA: Atualizar políticas RLS para usar user_id (campo correto)
-- Execute este SQL no Supabase SQL Editor

-- ============================================================================
-- CONTEXTO DO PROBLEMA:
-- - Tabela tem 2 campos: user_id (NOT NULL - correto) e usuario_id (nullable - antigo)
-- - Políticas RLS estão verificando usuario_id (campo errado!)
-- - Código está enviando user_id (correto!)
-- - Resultado: RLS bloqueia porque auth.uid() = usuario_id retorna NULL
-- ============================================================================

BEGIN;

-- 1. Remover políticas antigas
DROP POLICY IF EXISTS "movimentacoes_insert" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_select" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_update" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_delete" ON public.movimentacoes_caixa;

-- 2. Criar políticas CORRETAS usando user_id (campo NOT NULL)

-- SELECT: Usuário vê movimentações dos seus caixas
CREATE POLICY "movimentacoes_select" 
ON public.movimentacoes_caixa
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.user_id = auth.uid()
    )
);

-- INSERT: Usuário pode criar movimentações nos seus caixas
CREATE POLICY "movimentacoes_insert" 
ON public.movimentacoes_caixa
FOR INSERT 
WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.user_id = auth.uid()
    )
);

-- UPDATE: Usuário pode atualizar movimentações dos seus caixas
CREATE POLICY "movimentacoes_update" 
ON public.movimentacoes_caixa
FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.user_id = auth.uid()
    )
);

-- DELETE: Usuário pode deletar movimentações dos seus caixas
CREATE POLICY "movimentacoes_delete" 
ON public.movimentacoes_caixa
FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.user_id = auth.uid()
    )
);

COMMIT;

-- ============================================================================
-- VERIFICAÇÃO: Confirmar que políticas foram atualizadas
-- ============================================================================

SELECT 
    '✅ Políticas RLS atualizadas com sucesso!' as resultado;

-- Mostrar políticas ativas
SELECT 
    policyname as nome_politica,
    cmd as comando,
    CASE 
        WHEN with_check LIKE '%user_id%' THEN '✅ Usa user_id (correto)'
        WHEN with_check LIKE '%usuario_id%' THEN '❌ Usa usuario_id (errado)'
        ELSE 'N/A'
    END as campo_verificado
FROM pg_policies
WHERE tablename = 'movimentacoes_caixa'
ORDER BY cmd;

-- ============================================================================
-- OPCIONAL: Remover campo usuario_id antigo (recomendado após testar)
-- ============================================================================

-- ⚠️ DESCOMENTE APENAS APÓS CONFIRMAR QUE AS VENDAS FUNCIONAM:
-- ALTER TABLE public.movimentacoes_caixa DROP COLUMN IF EXISTS usuario_id CASCADE;
-- SELECT '✅ Campo usuario_id antigo removido!' as resultado;
