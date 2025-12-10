-- ========================================
-- 🔍 ANÁLISE COMPLETA EM UMA QUERY
-- ========================================

-- Contar usuários e dados em uma única tabela
WITH analise AS (
  -- Contar usuários totais
  SELECT 
    1 as ordem,
    'USUÁRIOS TOTAIS' as categoria,
    COUNT(*)::text as valor,
    STRING_AGG(email, ', ' ORDER BY created_at) as detalhes
  FROM auth.users
  
  UNION ALL
  
  -- Contar usuários ativos (fizeram login nos últimos 30 dias)
  SELECT 
    2 as ordem,
    'USUÁRIOS ATIVOS (30 dias)' as categoria,
    COUNT(*)::text as valor,
    STRING_AGG(email, ', ' ORDER BY last_sign_in_at DESC) as detalhes
  FROM auth.users 
  WHERE last_sign_in_at > NOW() - INTERVAL '30 days'
  
  UNION ALL
  
  -- Produtos com dono vs órfãos
  SELECT 
    3 as ordem,
    'PRODUTOS COM DONO' as categoria,
    COUNT(*)::text as valor,
    'Produtos que têm user_id definido' as detalhes
  FROM produtos 
  WHERE user_id IS NOT NULL
  
  UNION ALL
  
  SELECT 
    4 as ordem,
    'PRODUTOS ÓRFÃOS' as categoria,
    COUNT(*)::text as valor,
    'Produtos sem user_id (SEM DONO)' as detalhes
  FROM produtos 
  WHERE user_id IS NULL
  
  UNION ALL
  
  -- Clientes com dono vs órfãos
  SELECT 
    5 as ordem,
    'CLIENTES COM DONO' as categoria,
    COUNT(*)::text as valor,
    'Clientes que têm user_id definido' as detalhes
  FROM clientes 
  WHERE user_id IS NOT NULL
  
  UNION ALL
  
  SELECT 
    6 as ordem,
    'CLIENTES ÓRFÃOS' as categoria,
    COUNT(*)::text as valor,
    'Clientes sem user_id (SEM DONO)' as detalhes
  FROM clientes 
  WHERE user_id IS NULL
  
  UNION ALL
  
  -- Vendas com dono vs órfãos
  SELECT 
    7 as ordem,
    'VENDAS COM DONO' as categoria,
    COUNT(*)::text as valor,
    'Vendas que têm user_id definido' as detalhes
  FROM vendas 
  WHERE user_id IS NOT NULL
  
  UNION ALL
  
  SELECT 
    8 as ordem,
    'VENDAS ÓRFÃOS' as categoria,
    COUNT(*)::text as valor,
    'Vendas sem user_id (SEM DONO)' as detalhes
  FROM vendas 
  WHERE user_id IS NULL
)

SELECT 
  categoria,
  valor,
  detalhes
FROM analise 
ORDER BY ordem;

-- Mostrar distribuição por usuário específico
SELECT 
  '📊 RESUMO FINAL' as info,
  u.email as usuario,
  COALESCE(p.produtos, 0) as produtos,
  COALESCE(c.clientes, 0) as clientes,
  COALESCE(v.vendas, 0) as vendas,
  CASE 
    WHEN u.last_sign_in_at IS NULL THEN '❌ NUNCA LOGOU'
    WHEN u.last_sign_in_at < NOW() - INTERVAL '30 days' THEN '⚠️ INATIVO'
    ELSE '✅ ATIVO'
  END as status
FROM auth.users u
LEFT JOIN (SELECT user_id, COUNT(*) as produtos FROM produtos WHERE user_id IS NOT NULL GROUP BY user_id) p ON u.id = p.user_id
LEFT JOIN (SELECT user_id, COUNT(*) as clientes FROM clientes WHERE user_id IS NOT NULL GROUP BY user_id) c ON u.id = c.user_id
LEFT JOIN (SELECT user_id, COUNT(*) as vendas FROM vendas WHERE user_id IS NOT NULL GROUP BY user_id) v ON u.id = v.user_id
ORDER BY u.created_at;