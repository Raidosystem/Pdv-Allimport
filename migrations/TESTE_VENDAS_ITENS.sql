-- 🔍 TESTE: Verificar se tabela vendas_itens existe
-- Execute no Supabase para diagnóstico

-- 1. Verificar se tabela existe
SELECT 
  table_name,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'vendas_itens'
  ) 
  THEN '✅ EXISTE' 
  ELSE '❌ NÃO EXISTE' 
  END as status;

-- 2. Se existir, mostrar estrutura
SELECT 'ESTRUTURA DA TABELA vendas_itens:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'vendas_itens' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Verificar RLS
SELECT 'RLS DA TABELA vendas_itens:' as info;
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'vendas_itens' 
  AND schemaname = 'public';

-- 4. Verificar políticas
SELECT 'POLÍTICAS DA TABELA vendas_itens:' as info;
SELECT policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'vendas_itens' 
  AND schemaname = 'public';

-- 5. Verificar se há um caixa aberto
SELECT 'CAIXA DISPONÍVEL:' as info;
SELECT id, status, valor_inicial, valor_atual, observacoes
FROM public.caixa 
WHERE status = 'aberto'
LIMIT 1;

-- 6. Testar inserção básica (sem commit)
BEGIN;
  INSERT INTO public.vendas_itens (
    venda_id, 
    produto_id, 
    quantidade, 
    preco_unitario, 
    subtotal
  ) VALUES (
    gen_random_uuid(), 
    gen_random_uuid(), 
    1, 
    10.00, 
    10.00
  );
  SELECT 'TESTE DE INSERÇÃO: ✅ SUCESSO' as resultado;
ROLLBACK;

SELECT '🎯 DIAGNÓSTICO COMPLETO EXECUTADO!' as status;