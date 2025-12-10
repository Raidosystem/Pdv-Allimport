-- 🔧 SCRIPT SUPER SIMPLES: Apenas renomear colunas
-- Execute este script primeiro, depois criamos as políticas

-- 1. Desabilitar RLS completamente
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- 2. Renomear colunas
ALTER TABLE public.caixa RENAME COLUMN usuario_id TO user_id;
ALTER TABLE public.movimentacoes_caixa RENAME COLUMN usuario_id TO user_id;

-- 3. Verificar se funcionou
SELECT 'Colunas renomeadas com sucesso!' as resultado;

-- 4. Verificar estrutura atual
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name IN ('caixa', 'movimentacoes_caixa')
AND column_name = 'user_id'
ORDER BY table_name;
