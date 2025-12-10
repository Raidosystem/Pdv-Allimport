-- ============================================
-- 🔍 DIAGNÓSTICO COMPLETO DO BANCO DE DADOS
-- ============================================
-- Execute no Supabase SQL Editor
-- Copie TODOS os resultados e envie para análise
-- ============================================

-- 1️⃣ LISTAR TODAS AS TABELAS
SELECT 
  '1️⃣ TABELAS NO BANCO' as secao,
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE columns.table_name = t.table_name AND columns.table_schema = 'public') as total_colunas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2️⃣ VERIFICAR TABELAS CRÍTICAS
SELECT 
  '2️⃣ TABELAS CRÍTICAS' as secao,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'funcionarios' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as funcionarios,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'funcoes' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as funcoes,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'permissoes' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as permissoes,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'funcao_permissoes' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as funcao_permissoes,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as subscriptions,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'produtos' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as produtos,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendas' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as vendas,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as clientes,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'empresas' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as empresas,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_approvals' AND table_schema = 'public') 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as user_approvals;

-- 3️⃣ ESTRUTURA: FUNCIONARIOS
SELECT 
  '3️⃣ ESTRUTURA: funcionarios' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4️⃣ ESTRUTURA: FUNCOES
SELECT 
  '4️⃣ ESTRUTURA: funcoes' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcoes'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5️⃣ ESTRUTURA: PERMISSOES
SELECT 
  '5️⃣ ESTRUTURA: permissoes' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'permissoes'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6️⃣ ESTRUTURA: FUNCAO_PERMISSOES
SELECT 
  '6️⃣ ESTRUTURA: funcao_permissoes' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 7️⃣ ESTRUTURA: SUBSCRIPTIONS
SELECT 
  '7️⃣ ESTRUTURA: subscriptions' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'subscriptions'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 8️⃣ POLÍTICAS RLS
SELECT 
  '8️⃣ POLÍTICAS RLS' as secao,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles::text,
  cmd,
  LEFT(qual::text, 100) as qual_preview,
  LEFT(with_check::text, 100) as with_check_preview
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 9️⃣ FUNÇÕES POSTGRESQL CUSTOMIZADAS
SELECT 
  '9️⃣ FUNÇÕES' as secao,
  routine_name as funcao,
  routine_type as tipo,
  data_type as retorno
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- 🔟 TRIGGERS
SELECT 
  '🔟 TRIGGERS' as secao,
  trigger_name,
  event_object_table as tabela,
  action_timing as quando,
  event_manipulation as acao
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY trigger_name;

-- 1️⃣1️⃣ EXTENSIONS INSTALADAS
SELECT 
  '1️⃣1️⃣ EXTENSIONS' as secao,
  extname as extensao,
  extversion as versao
FROM pg_extension
WHERE extname NOT IN ('plpgsql')
ORDER BY extname;

-- 1️⃣2️⃣ VERIFICAR FUNÇÃO check_subscription_status
SELECT 
  '1️⃣2️⃣ FUNÇÃO check_subscription_status' as secao,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_name = 'check_subscription_status'
        AND routine_schema = 'public'
    ) 
    THEN '✅ EXISTE' 
    ELSE '❌ NÃO EXISTE' 
  END as status;

-- 1️⃣3️⃣ CONTAGEM DE REGISTROS (funcionarios)
SELECT 
  '1️⃣3️⃣ DADOS: funcionarios' as secao,
  COUNT(*) as total_registros
FROM funcionarios;

-- 1️⃣4️⃣ CONTAGEM DE REGISTROS (funcoes)
SELECT 
  '1️⃣4️⃣ DADOS: funcoes' as secao,
  COUNT(*) as total_registros
FROM funcoes;

-- 1️⃣5️⃣ CONTAGEM DE REGISTROS (permissoes)
SELECT 
  '1️⃣5️⃣ DADOS: permissoes' as secao,
  COUNT(*) as total_registros
FROM permissoes;

-- 1️⃣6️⃣ CONTAGEM DE REGISTROS (funcao_permissoes)
SELECT 
  '1️⃣6️⃣ DADOS: funcao_permissoes' as secao,
  COUNT(*) as total_registros
FROM funcao_permissoes;

-- 1️⃣7️⃣ CONTAGEM DE REGISTROS (subscriptions)
SELECT 
  '1️⃣7️⃣ DADOS: subscriptions' as secao,
  COUNT(*) as total_registros
FROM subscriptions;

-- 1️⃣8️⃣ CONTAGEM DE REGISTROS (user_approvals)
SELECT 
  '1️⃣8️⃣ DADOS: user_approvals' as secao,
  COUNT(*) as total_registros
FROM user_approvals;

-- 1️⃣9️⃣ CONTAGEM DE REGISTROS (empresas)
SELECT 
  '1️⃣9️⃣ DADOS: empresas' as secao,
  COUNT(*) as total_registros
FROM empresas;

-- 2️⃣0️⃣ RESUMO FINAL
SELECT 
  '2️⃣0️⃣ RESUMO FINAL' as secao,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') as total_tabelas,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public') as total_politicas_rls,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public') as total_funcoes,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'public') as total_triggers,
  (SELECT COUNT(*) FROM pg_extension WHERE extname NOT IN ('plpgsql')) as total_extensions;
