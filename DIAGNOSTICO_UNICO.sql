-- ========================================
-- 🚨 DIAGNÓSTICO ÚNICO - TODOS RESULTADOS EM UMA TABELA
-- ========================================

WITH diagnostico AS (
  -- Informações básicas
  SELECT 
    1 as ordem,
    '👤 USUÁRIO ATUAL' as categoria,
    COALESCE(auth.email(), 'NÃO AUTENTICADO') as item,
    COALESCE(auth.uid()::text, 'NULL') as valor,
    CASE 
      WHEN auth.uid() IS NULL THEN '❌ PROBLEMA: SEM AUTENTICAÇÃO'
      ELSE '✅ AUTENTICADO'
    END as status
  
  UNION ALL
  
  -- Status RLS das tabelas
  SELECT 
    2 as ordem,
    '🔍 RLS STATUS' as categoria,
    tablename as item,
    CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as valor,
    CASE WHEN rowsecurity THEN '✅ OK' ELSE '❌ PROBLEMA: RLS DESATIVADO' END as status
  FROM pg_tables 
  WHERE schemaname = 'public' 
    AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
  
  UNION ALL
  
  -- Contagem de políticas
  SELECT 
    3 as ordem,
    '🔑 POLÍTICAS' as categoria,
    tablename as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '❌ PROBLEMA: SEM POLÍTICAS'
      ELSE '✅ TEM POLÍTICAS'
    END as status
  FROM pg_policies 
  WHERE schemaname = 'public'
    AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
  GROUP BY tablename
  
  UNION ALL
  
  -- Registros visíveis
  SELECT 
    4 as ordem,
    '🖥️ REGISTROS VISÍVEIS' as categoria,
    'Produtos' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '⚠️ NENHUM PRODUTO VISÍVEL'
      WHEN COUNT(*) > 100 THEN '❌ MUITOS PRODUTOS (POSSÍVEL VAZAMENTO)'
      ELSE '✅ QUANTIDADE NORMAL'
    END as status
  FROM produtos
  
  UNION ALL
  
  SELECT 
    4 as ordem,
    '🖥️ REGISTROS VISÍVEIS' as categoria,
    'Clientes' as item,
    COUNT(*)::text as valor,
    CASE 
      WHEN COUNT(*) = 0 THEN '⚠️ NENHUM CLIENTE VISÍVEL'
      WHEN COUNT(*) > 100 THEN '❌ MUITOS CLIENTES (POSSÍVEL VAZAMENTO)'
      ELSE '✅ QUANTIDADE NORMAL'
    END as status
  FROM clientes
  
  UNION ALL
  
  -- Info da sessão
  SELECT 
    5 as ordem,
    '🔓 SESSÃO DATABASE' as categoria,
    'current_user' as item,
    current_user as valor,
    CASE 
      WHEN current_user = 'postgres' THEN '❌ PROBLEMA: EXECUTANDO COMO ADMIN (BYPASS RLS)'
      ELSE '✅ USUÁRIO NORMAL'
    END as status
)

SELECT 
  categoria,
  item,
  valor,
  status
FROM diagnostico 
ORDER BY ordem, categoria, item;

-- Diagnóstico específico de ownership
SELECT 
  '📊 OWNERSHIP PRODUTOS' as info,
  CASE 
    WHEN user_id IS NULL THEN '❌ SEM DONO'
    WHEN user_id = auth.uid() THEN '✅ MEU'
    ELSE '⚠️ OUTRO USUÁRIO'
  END as ownership,
  COUNT(*) as quantidade
FROM produtos 
GROUP BY 
  CASE 
    WHEN user_id IS NULL THEN '❌ SEM DONO'
    WHEN user_id = auth.uid() THEN '✅ MEU'
    ELSE '⚠️ OUTRO USUÁRIO'
  END
ORDER BY quantidade DESC;