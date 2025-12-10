-- Verificação rápida do status RLS
SELECT 
  'STATUS_RLS' as tipo,
  tablename,
  CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
ORDER BY tablename;

-- Verificar políticas existentes
SELECT 
  'POLITICAS_RLS' as tipo,
  tablename,
  policyname,
  cmd as operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
ORDER BY tablename, policyname;

-- Verificar usuário atual
SELECT 
  'USUARIO_ATUAL' as tipo,
  auth.uid() as user_id,
  auth.email() as email;

-- Teste de contagem de dados sem filtro
SELECT 'TOTAL_CLIENTES' as tipo, COUNT(*) as quantidade FROM public.clientes;
SELECT 'TOTAL_PRODUTOS' as tipo, COUNT(*) as quantidade FROM public.produtos;
SELECT 'TOTAL_VENDAS' as tipo, COUNT(*) as quantidade FROM public.vendas;