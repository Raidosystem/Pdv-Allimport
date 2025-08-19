-- ================================================
-- 🔍 DIAGNÓSTICO RLS SIMPLIFICADO E SEGURO
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1. STATUS RLS BÁSICO
SELECT 
  '📊 STATUS RLS' as info,
  tablename,
  CASE WHEN rowsecurity THEN '🔒 RLS ATIVO' ELSE '🔓 RLS INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
ORDER BY tablename;

-- 2. POLÍTICAS EXISTENTES
SELECT 
  '🔑 POLÍTICAS RLS' as info,
  tablename,
  policyname,
  cmd as tipo_operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
ORDER BY tablename, policyname;

-- 3. CONTAR POLÍTICAS POR TABELA
SELECT 
  '📊 QUANTIDADE POLÍTICAS' as info,
  tablename,
  COUNT(*) as total_policies
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
GROUP BY tablename
ORDER BY tablename;

-- 4. VERIFICAR COLUNAS USER_ID
SELECT 
  '👤 COLUNAS USER_ID' as info,
  table_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = t.table_name 
        AND table_schema = 'public'
        AND column_name = 'user_id'
    ) THEN '✅ EXISTE'
    ELSE '❌ FALTA'
  END as tem_user_id
FROM (
  SELECT 'clientes' as table_name
  UNION SELECT 'produtos'
  UNION SELECT 'vendas'
  UNION SELECT 'caixa'
  UNION SELECT 'itens_venda'
) t
ORDER BY table_name;

-- 5. VERIFICAR DADOS SEM USER_ID (se a coluna existir)
DO $$
BEGIN
  -- Verificar clientes
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'user_id' AND table_schema = 'public') THEN
    EXECUTE 'SELECT ''🚫 CLIENTES SEM USER_ID'' as info, COUNT(*) as total, COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id FROM public.clientes';
  END IF;
  
  -- Verificar produtos  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'user_id' AND table_schema = 'public') THEN
    EXECUTE 'SELECT ''🚫 PRODUTOS SEM USER_ID'' as info, COUNT(*) as total, COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id FROM public.produtos';
  END IF;
END $$;

-- 6. USUÁRIOS ATIVOS
SELECT 
  '👥 USUÁRIOS SISTEMA' as info,
  COUNT(*) as total_usuarios
FROM auth.users;

SELECT 
  '👥 LISTA USUÁRIOS' as info,
  email,
  created_at
FROM auth.users 
ORDER BY created_at;

-- 7. TESTE USUÁRIO ATUAL
SELECT 
  '🧪 USUÁRIO ATUAL' as info,
  auth.uid() as meu_user_id,
  COALESCE(auth.email(), 'NÃO LOGADO') as meu_email;

-- 8. TESTE CONTAGEM DADOS VISÍVEIS
SELECT 
  '🧪 DADOS VISÍVEIS CLIENTES' as info,
  COUNT(*) as total_visiveis
FROM public.clientes;

SELECT 
  '🧪 DADOS VISÍVEIS PRODUTOS' as info,
  COUNT(*) as total_visiveis
FROM public.produtos;

-- 9. RESUMO DE PROBLEMAS
SELECT 
  '🎯 RESUMO PROBLEMAS' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_tables 
      WHERE schemaname = 'public' 
        AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa') 
        AND rowsecurity = false
    ) THEN '❌ ALGUMAS TABELAS SEM RLS'
    ELSE '✅ RLS ATIVO EM TODAS'
  END as status_rls,
  
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE schemaname = 'public'
        AND tablename IN ('clientes', 'produtos')
      GROUP BY tablename 
      HAVING COUNT(*) > 2
    ) THEN '⚠️ MUITAS POLÍTICAS'
    ELSE '✅ POLÍTICAS OK'
  END as status_policies;

SELECT '✅ DIAGNÓSTICO SIMPLIFICADO COMPLETO' as resultado;
