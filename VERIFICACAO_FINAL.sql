-- VERIFICAÇÃO FINAL - Execute no Supabase SQL Editor
-- User ID: 28e56a69-90df-4852-b663-9b02f4358c6f

-- 1. Contar produtos
SELECT 'TOTAL PRODUTOS' as info, COUNT(*) as quantidade FROM public.produtos;

-- 2. Contar produtos com preço
SELECT 'PRODUTOS COM PREÇO' as info, COUNT(*) as quantidade 
FROM public.produtos WHERE preco > 0;

-- 3. Verificar user_id específico
SELECT 'PRODUTOS DO USER' as info, COUNT(*) as quantidade 
FROM public.produtos WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

-- 4. Testar query que o site faz
SELECT COUNT(*) as total_via_site FROM public.produtos 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

-- 5. Verificar RLS ativo
SELECT 'RLS STATUS' as info, 
       CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'DESABILITADO' END as status
FROM pg_tables 
WHERE tablename = 'produtos';

-- 6. Verificar políticas atuais
SELECT 'POLÍTICAS ATIVAS' as info, policyname, cmd, qual
FROM pg_policies 
WHERE tablename = 'produtos';

-- 7. Simular consulta sem user_id (como site faz)
SELECT 'SEM FILTRO USER_ID' as teste, COUNT(*) as quantidade 
FROM public.produtos;

-- 8. Exemplos de produtos para debug
SELECT nome, preco, user_id FROM public.produtos 
WHERE preco > 0 
ORDER BY nome 
LIMIT 10;
