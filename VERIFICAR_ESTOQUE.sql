-- =============================================
-- VERIFICAR SE O ESTOQUE ESTÁ SENDO SALVO
-- =============================================

-- 1. Verificar a estrutura da coluna estoque
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'produtos'
  AND column_name = 'estoque';

-- 2. Verificar alguns produtos e seus estoques
SELECT 
    id,
    nome,
    estoque,
    preco,
    codigo_interno,
    atualizado_em
FROM public.produtos
ORDER BY atualizado_em DESC
LIMIT 10;

-- 3. Forçar atualização do schema cache novamente
NOTIFY pgrst, 'reload schema';

-- 4. Teste de atualização direta (DESCOMENTE E AJUSTE O ID)
-- UPDATE public.produtos
-- SET estoque = 999
-- WHERE id = 'SEU_PRODUTO_ID_AQUI';

-- 5. Verificar se a atualização funcionou
-- SELECT id, nome, estoque FROM public.produtos WHERE id = 'SEU_PRODUTO_ID_AQUI';
