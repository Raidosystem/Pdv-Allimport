-- ================================================
-- 🔍 DIAGNÓSTICO COMPLETO RLS - VERIFICAR ERROS
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1. VERIFICAR STATUS RLS DE TODAS AS TABELAS
SELECT 
  '📊 STATUS RLS TODAS AS TABELAS' as diagnostico,
  schemaname,
  tablename,
  rowsecurity as rls_ativo,
  CASE WHEN rowsecurity THEN '🔒 ATIVO' ELSE '🔓 INATIVO' END as status_visual
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. VERIFICAR POLÍTICAS EXISTENTES (INCLUINDO DUPLICADAS)
SELECT 
  '🔑 TODAS AS POLÍTICAS RLS' as diagnostico,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd as comando,
  qual as condicao_using,
  with_check as condicao_with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3. BUSCAR POLÍTICAS DUPLICADAS
SELECT 
  '⚠️ POLÍTICAS DUPLICADAS (PROBLEMA)' as diagnostico,
  tablename,
  COUNT(*) as quantidade_policies,
  STRING_AGG(policyname, ', ') as nomes_policies
FROM pg_policies 
WHERE schemaname = 'public'
GROUP BY tablename
HAVING COUNT(*) > 3; -- Mais que 3 políticas por tabela pode indicar duplicação

-- 4. VERIFICAR TABELAS COM RLS DESABILITADO MAS COM POLÍTICAS
SELECT 
  '❌ TABELAS COM RLS OFF MAS COM POLÍTICAS' as diagnostico,
  t.tablename,
  t.rowsecurity as rls_status,
  COUNT(p.policyname) as total_policies
FROM pg_tables t
LEFT JOIN pg_policies p ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public' 
  AND t.rowsecurity = false
  AND p.policyname IS NOT NULL
GROUP BY t.tablename, t.rowsecurity;

-- 5. VERIFICAR COLUNAS USER_ID NAS TABELAS CRÍTICAS
SELECT 
  '👤 VERIFICAÇÃO COLUNAS USER_ID' as diagnostico,
  table_name,
  CASE 
    WHEN column_name IS NOT NULL THEN '✅ EXISTE'
    ELSE '❌ FALTA'
  END as status_user_id,
  data_type,
  is_nullable
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON (
  t.table_name = c.table_name 
  AND t.table_schema = c.table_schema 
  AND c.column_name = 'user_id'
)
WHERE t.table_schema = 'public' 
  AND t.table_name IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda')
ORDER BY t.table_name;

-- 6. VERIFICAR DADOS SEM USER_ID (ÓRFÃOS)
SELECT 
  '🚫 DADOS ÓRFÃOS SEM USER_ID' as diagnostico,
  'clientes' as tabela,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
  COUNT(DISTINCT user_id) as usuarios_diferentes
FROM public.clientes
UNION ALL
SELECT 
  '🚫 DADOS ÓRFÃOS SEM USER_ID',
  'produtos',
  COUNT(*),
  COUNT(CASE WHEN user_id IS NULL THEN 1 END),
  COUNT(DISTINCT user_id)
FROM public.produtos
UNION ALL
SELECT 
  '🚫 DADOS ÓRFÃOS SEM USER_ID',
  'vendas',
  COUNT(*),
  COUNT(CASE WHEN user_id IS NULL THEN 1 END),
  COUNT(DISTINCT user_id)
FROM public.vendas
UNION ALL
SELECT 
  '🚫 DADOS ÓRFÃOS SEM USER_ID',
  'caixa',
  COUNT(*),
  COUNT(CASE WHEN user_id IS NULL THEN 1 END),
  COUNT(DISTINCT user_id)
FROM public.caixa;

-- 7. VERIFICAR USUÁRIOS ATIVOS
SELECT 
  '👥 USUÁRIOS NO SISTEMA' as diagnostico,
  COUNT(*) as total_usuarios,
  STRING_AGG(email, ', ') as emails
FROM auth.users;

-- 8. VERIFICAR TRIGGERS EXISTENTES
SELECT 
  '⚙️ TRIGGERS AUTO USER_ID' as diagnostico,
  n.nspname as schemaname,
  c.relname as tablename,
  t.tgname as triggername,
  CASE WHEN t.tgenabled = 'O' THEN '✅ ATIVO' ELSE '❌ INATIVO' END as status
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND (t.tgname LIKE '%user_id%' OR t.tgname LIKE '%auto%')
  AND NOT t.tgisinternal
ORDER BY c.relname;

-- 9. VERIFICAR REFERÊNCIAS FOREIGN KEY PARA auth.users
SELECT 
  '🔗 FOREIGN KEYS PARA AUTH.USERS' as diagnostico,
  tc.table_name,
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_schema = 'public'
  AND ccu.table_name = 'users'
ORDER BY tc.table_name;

-- 10. TESTE PRÁTICO DE ISOLAMENTO
SELECT 
  '🧪 TESTE ISOLAMENTO PRÁTICO' as diagnostico,
  'CURRENT USER' as info,
  auth.uid() as user_id_atual,
  auth.email() as email_atual;

-- Testar se consegue ver dados de outros usuários
SELECT 
  '🧪 TESTE: Dados visíveis por tabela' as diagnostico,
  'clientes' as tabela,
  COUNT(*) as registros_visiveis
FROM public.clientes
UNION ALL
SELECT 
  '🧪 TESTE: Dados visíveis por tabela',
  'produtos',
  COUNT(*)
FROM public.produtos
UNION ALL
SELECT 
  '🧪 TESTE: Dados visíveis por tabela',
  'vendas',
  COUNT(*)
FROM public.vendas;

-- 11. RESUMO FINAL DE PROBLEMAS
SELECT 
  '🎯 RESUMO DE PROBLEMAS ENCONTRADOS' as diagnostico,
  CASE 
    WHEN EXISTS(
      SELECT 1 FROM pg_tables 
      WHERE schemaname = 'public' 
        AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa') 
        AND rowsecurity = false
    ) THEN '❌ ALGUMAS TABELAS SEM RLS'
    ELSE '✅ RLS ATIVO EM TABELAS CRÍTICAS'
  END as status_rls,
  
  CASE 
    WHEN EXISTS(
      SELECT 1 FROM pg_policies 
      WHERE schemaname = 'public' 
      GROUP BY tablename 
      HAVING COUNT(*) > 5
    ) THEN '⚠️ POSSÍVEIS POLÍTICAS DUPLICADAS'
    ELSE '✅ POLÍTICAS NORMAIS'
  END as status_policies,
  
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_sistema;

SELECT '📋 DIAGNÓSTICO COMPLETO FINALIZADO' as resultado;
