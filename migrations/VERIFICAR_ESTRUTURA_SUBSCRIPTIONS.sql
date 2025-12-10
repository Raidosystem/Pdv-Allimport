-- VERIFICAR ESTRUTURA ATUAL DA TABELA SUBSCRIPTIONS
-- Execute este comando primeiro para ver a estrutura atual

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'subscriptions'
ORDER BY ordinal_position;

-- Também verificar uma linha de exemplo
SELECT * FROM public.subscriptions LIMIT 1;