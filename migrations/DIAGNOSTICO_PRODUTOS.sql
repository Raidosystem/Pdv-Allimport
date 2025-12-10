-- DIAGNÓSTICO COMPLETO - Verificar produtos no Supabase
-- User ID: 28e56a69-90df-4852-b663-9b02f4358c6f

-- 1. Verificar quantos produtos existem no total
SELECT 'TOTAL DE PRODUTOS NO BANCO' as diagnostico, COUNT(*) as quantidade
FROM public.produtos;

-- 2. Verificar produtos por user_id
SELECT 'PRODUTOS DO USUÁRIO ESPECÍFICO' as diagnostico, COUNT(*) as quantidade
FROM public.produtos 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

-- 3. Verificar se existem produtos com preço > 0
SELECT 'PRODUTOS COM PREÇO > 0' as diagnostico, COUNT(*) as quantidade
FROM public.produtos 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f' 
AND preco > 0;

-- 4. Verificar produtos válidos (sem filtro ativo)
SELECT 'TODOS OS PRODUTOS DO USUÁRIO' as diagnostico, COUNT(*) as quantidade
FROM public.produtos 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

-- 5. Mostrar alguns produtos específicos para debug (sem coluna ativo)
SELECT 'EXEMPLO DE PRODUTOS' as tipo, id, nome, preco
FROM public.produtos 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f'
ORDER BY nome
LIMIT 10;

-- 6. Verificar se há algum filtro ou coluna que pode estar impedindo
SELECT 'ESTRUTURA DA TABELA' as info, column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'produtos' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 7. Verificar RLS (Row Level Security)
SELECT 'VERIFICAR RLS' as info, 
       schemaname, tablename, rowsecurity, 
       CASE WHEN rowsecurity THEN 'RLS ATIVO' ELSE 'RLS DESABILITADO' END as status
FROM pg_tables 
WHERE tablename = 'produtos' 
AND schemaname = 'public';

-- 8. Verificar políticas RLS ativas
SELECT 'POLÍTICAS RLS' as info, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'produtos' 
AND schemaname = 'public';
