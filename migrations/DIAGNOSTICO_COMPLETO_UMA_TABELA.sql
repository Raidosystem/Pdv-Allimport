-- ========================================
-- 🚨 DIAGNÓSTICO COMPLETO EM UMA ÚNICA CONSULTA
-- Vai mostrar TUDO em uma tabela só
-- ========================================

WITH diagnostico_completo AS (
  -- 1. Contexto de execução
  SELECT 
    1 as ordem,
    '🔍 CONTEXTO' as categoria,
    'database_user' as item,
    current_user as valor,
    CASE 
      WHEN current_user = 'postgres' THEN '❌ POSTGRES (BYPASS TOTAL)'
      WHEN current_user LIKE '%service_role%' THEN '❌ SERVICE ROLE (BYPASS TOTAL)'
      ELSE '✅ USUÁRIO NORMAL'
    END as status
  
  UNION ALL
  
  SELECT 
    1 as ordem,
    '🔍 CONTEXTO' as categoria,
    'is_superuser' as item,
    current_setting('is_superuser') as valor,
    CASE 
      WHEN current_setting('is_superuser') = 'on' THEN '❌ SUPERUSER (BYPASS RLS)'
      ELSE '✅ USUÁRIO NORMAL'
    END as status
  
  UNION ALL
  
  -- 2. Autenticação Supabase
  SELECT 
    2 as ordem,
    '👤 AUTH SUPABASE' as categoria,
    'auth.uid()' as item,
    COALESCE(auth.uid()::text, 'NULL') as valor,
    CASE 
      WHEN auth.uid() IS NULL THEN '❌ SEM AUTENTICAÇÃO'
      ELSE '✅ AUTENTICADO'
    END as status
  
  UNION ALL
  
  SELECT 
    2 as ordem,
    '👤 AUTH SUPABASE' as categoria,
    'auth.email()' as item,
    COALESCE(auth.email(), 'NULL') as valor,
    CASE 
      WHEN auth.email() IS NULL THEN '❌ SEM EMAIL'
      ELSE '✅ EMAIL OK'
    END as status
  
  UNION ALL
  
  -- 3. Status RLS das tabelas
  SELECT 
    3 as ordem,
    '🔒 RLS STATUS' as categoria,
    'produtos' as item,
    CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as valor,
    CASE 
      WHEN rowsecurity THEN '✅ RLS ATIVO'
      ELSE '❌ RLS INATIVO'
    END as status
  FROM pg_tables 
  WHERE schemaname = 'public' AND tablename = 'produtos'
  
  UNION ALL
  
  SELECT 
    3 as ordem,
    '🔒 RLS STATUS' as categoria,
    'clientes' as item,
    CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as valor,
    CASE 
      WHEN rowsecurity THEN '✅ RLS ATIVO'
      ELSE '❌ RLS INATIVO'
    END as status
  FROM pg_tables 
  WHERE schemaname = 'public' AND tablename = 'clientes'
  
  UNION ALL
  
  -- 4. Contagem de políticas
  SELECT 
    4 as ordem,
    '🔑 POLÍTICAS' as categoria,
    'produtos_policies' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '❌ SEM POLÍTICAS'
      ELSE '✅ TEM POLÍTICAS'
    END as status
  FROM pg_policies 
  WHERE schemaname = 'public' AND tablename = 'produtos'
  
  UNION ALL
  
  -- 5. Teste de ownership
  SELECT 
    5 as ordem,
    '📊 OWNERSHIP PRODUTOS' as categoria,
    'produtos_meus' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '❌ NENHUM PRODUTO MEU'
      ELSE '✅ TENHO PRODUTOS'
    END as status
  FROM produtos 
  WHERE user_id = auth.uid()
  
  UNION ALL
  
  SELECT 
    5 as ordem,
    '📊 OWNERSHIP PRODUTOS' as categoria,
    'produtos_outros' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '✅ NÃO VEJO OUTROS'
      ELSE '❌ VEJO PRODUTOS DE OUTROS'
    END as status
  FROM produtos 
  WHERE user_id != auth.uid() OR user_id IS NULL
  
  UNION ALL
  
  SELECT 
    5 as ordem,
    '📊 OWNERSHIP PRODUTOS' as categoria,
    'produtos_total_visiveis' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '⚠️ NENHUM PRODUTO VISÍVEL'
      WHEN COUNT(*) > 100 THEN '❌ MUITOS PRODUTOS (VAZAMENTO)'
      ELSE '✅ QUANTIDADE NORMAL'
    END as status
  FROM produtos
  
  UNION ALL
  
  -- 6. Comparação de IDs
  SELECT 
    6 as ordem,
    '🆔 COMPARAÇÃO IDs' as categoria,
    'meu_user_id' as item,
    COALESCE(auth.uid()::text, 'NULL') as valor,
    '📋 REFERÊNCIA' as status
  
  UNION ALL
  
  SELECT 
    6 as ordem,
    '🆔 COMPARAÇÃO IDs' as categoria,
    'primeiro_produto_user_id' as item,
    COALESCE((SELECT user_id::text FROM produtos LIMIT 1), 'NULL') as valor,
    CASE 
      WHEN (SELECT user_id FROM produtos LIMIT 1) = auth.uid() THEN '✅ É MEU'
      WHEN (SELECT user_id FROM produtos LIMIT 1) IS NULL THEN '❌ SEM DONO'
      ELSE '❌ É DE OUTRO'
    END as status
)

SELECT 
  categoria,
  item,
  valor,
  status,
  CASE 
    WHEN status LIKE '❌%' THEN '🚨 PROBLEMA'
    WHEN status LIKE '✅%' THEN '✅ OK'
    WHEN status LIKE '⚠️%' THEN '⚠️ ATENÇÃO'
    ELSE '📋 INFO'
  END as prioridade
FROM diagnostico_completo 
ORDER BY ordem, categoria, item;