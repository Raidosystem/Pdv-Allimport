-- ============================================
-- IDENTIFICAR USUÁRIOS ATIVOS (SEM AUDIT LOG)
-- ============================================

-- PASSO 1: Verificar usuários com login recente
-- ============================================
SELECT 
  id as user_id,
  email,
  created_at as cadastro_em,
  last_sign_in_at as ultimo_login,
  EXTRACT(DAY FROM (NOW() - last_sign_in_at)) as dias_sem_login
FROM auth.users
WHERE last_sign_in_at > NOW() - INTERVAL '30 days'
ORDER BY last_sign_in_at DESC;

-- PASSO 2: Verificar empresas cadastradas
-- ============================================
SELECT 
  e.user_id,
  u.email,
  e.nome,
  e.razao_social,
  e.cnpj,
  e.created_at,
  e.updated_at,
  u.last_sign_in_at,
  EXTRACT(DAY FROM (NOW() - u.last_sign_in_at)) as dias_sem_login
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE (e.cnpj IS NOT NULL AND e.cnpj != '') 
   OR (e.razao_social IS NOT NULL AND e.razao_social != '')
ORDER BY u.last_sign_in_at DESC NULLS LAST;

-- PASSO 3: Verificar vendas recentes (últimos 90 dias)
-- ============================================
SELECT 
  user_id,
  COUNT(*) as num_vendas,
  SUM(total) as valor_total,
  MAX(created_at) as ultima_venda,
  MIN(created_at) as primeira_venda
FROM vendas
WHERE created_at > NOW() - INTERVAL '90 days'
GROUP BY user_id
ORDER BY num_vendas DESC;

-- PASSO 4: Verificar produtos cadastrados
-- ============================================
SELECT 
  p.user_id,
  u.email,
  COUNT(*) as num_produtos,
  MAX(p.created_at) as ultimo_produto_cadastrado
FROM produtos p
JOIN auth.users u ON u.id = p.user_id
GROUP BY p.user_id, u.email
HAVING COUNT(*) > 5
ORDER BY num_produtos DESC;

-- PASSO 5: Verificar clientes cadastrados
-- ============================================
SELECT 
  c.user_id,
  u.email,
  COUNT(*) as num_clientes,
  MAX(c.created_at) as ultimo_cliente_cadastrado
FROM clientes c
JOIN auth.users u ON u.id = c.user_id
GROUP BY c.user_id, u.email
HAVING COUNT(*) > 3
ORDER BY num_clientes DESC;

-- ============================================
-- ANÁLISE COMPLETA: SCORE DE ATIVIDADE
-- ============================================
WITH user_stats AS (
  SELECT 
    u.id,
    u.email,
    u.created_at as cadastro_em,
    u.last_sign_in_at,
    e.nome as empresa_nome,
    e.razao_social,
    e.cnpj,
    COALESCE(p.num_produtos, 0) as produtos,
    COALESCE(c.num_clientes, 0) as clientes,
    COALESCE(v.num_vendas, 0) as vendas,
    COALESCE(v.valor_total, 0) as valor_total_vendas
  FROM auth.users u
  LEFT JOIN empresas e ON e.user_id = u.id
  LEFT JOIN (
    SELECT user_id, COUNT(*) as num_produtos 
    FROM produtos 
    GROUP BY user_id
  ) p ON p.user_id = u.id
  LEFT JOIN (
    SELECT user_id, COUNT(*) as num_clientes 
    FROM clientes 
    GROUP BY user_id
  ) c ON c.user_id = u.id
  LEFT JOIN (
    SELECT 
      user_id, 
      COUNT(*) as num_vendas,
      SUM(total) as valor_total
    FROM vendas 
    WHERE created_at > NOW() - INTERVAL '90 days'
    GROUP BY user_id
  ) v ON v.user_id = u.id
)
SELECT 
  id,
  email,
  cadastro_em,
  last_sign_in_at,
  EXTRACT(DAY FROM (NOW() - last_sign_in_at)) as dias_sem_login,
  empresa_nome,
  razao_social,
  cnpj,
  produtos,
  clientes,
  vendas,
  ROUND(valor_total_vendas::numeric, 2) as valor_total_vendas,
  -- SCORE DE ATIVIDADE
  (
    -- Pontos por login recente
    CASE 
      WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 20
      WHEN last_sign_in_at > NOW() - INTERVAL '14 days' THEN 15
      WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 10
      WHEN last_sign_in_at > NOW() - INTERVAL '60 days' THEN 5
      ELSE 0 
    END +
    -- Pontos por dados da empresa
    CASE 
      WHEN cnpj IS NOT NULL AND cnpj != '' THEN 15
      WHEN razao_social IS NOT NULL AND razao_social != '' THEN 10
      WHEN empresa_nome IS NOT NULL AND empresa_nome != '' THEN 5
      ELSE 0 
    END +
    -- Pontos por produtos
    CASE 
      WHEN produtos > 100 THEN 25
      WHEN produtos > 50 THEN 20
      WHEN produtos > 20 THEN 15
      WHEN produtos > 10 THEN 10
      WHEN produtos > 5 THEN 5
      ELSE 0 
    END +
    -- Pontos por clientes
    CASE 
      WHEN clientes > 50 THEN 20
      WHEN clientes > 20 THEN 15
      WHEN clientes > 10 THEN 10
      WHEN clientes > 5 THEN 5
      ELSE 0 
    END +
    -- Pontos por vendas
    CASE 
      WHEN vendas > 100 THEN 30
      WHEN vendas > 50 THEN 25
      WHEN vendas > 20 THEN 20
      WHEN vendas > 10 THEN 15
      WHEN vendas > 5 THEN 10
      WHEN vendas > 1 THEN 5
      ELSE 0 
    END +
    -- Pontos por valor de vendas
    CASE 
      WHEN valor_total_vendas > 50000 THEN 20
      WHEN valor_total_vendas > 20000 THEN 15
      WHEN valor_total_vendas > 10000 THEN 10
      WHEN valor_total_vendas > 5000 THEN 5
      ELSE 0 
    END
  ) as activity_score,
  -- CLASSIFICAÇÃO
  CASE 
    WHEN (
      CASE 
        WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 20
        WHEN last_sign_in_at > NOW() - INTERVAL '14 days' THEN 15
        WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 10
        WHEN last_sign_in_at > NOW() - INTERVAL '60 days' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN cnpj IS NOT NULL AND cnpj != '' THEN 15
        WHEN razao_social IS NOT NULL AND razao_social != '' THEN 10
        WHEN empresa_nome IS NOT NULL AND empresa_nome != '' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN produtos > 100 THEN 25
        WHEN produtos > 50 THEN 20
        WHEN produtos > 20 THEN 15
        WHEN produtos > 10 THEN 10
        WHEN produtos > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN clientes > 50 THEN 20
        WHEN clientes > 20 THEN 15
        WHEN clientes > 10 THEN 10
        WHEN clientes > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN vendas > 100 THEN 30
        WHEN vendas > 50 THEN 25
        WHEN vendas > 20 THEN 20
        WHEN vendas > 10 THEN 15
        WHEN vendas > 5 THEN 10
        WHEN vendas > 1 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN valor_total_vendas > 50000 THEN 20
        WHEN valor_total_vendas > 20000 THEN 15
        WHEN valor_total_vendas > 10000 THEN 10
        WHEN valor_total_vendas > 5000 THEN 5
        ELSE 0 
      END
    ) >= 70 THEN '🔥 MUITO PROVÁVEL (Cliente Pago)'
    WHEN (
      CASE 
        WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 20
        WHEN last_sign_in_at > NOW() - INTERVAL '14 days' THEN 15
        WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 10
        WHEN last_sign_in_at > NOW() - INTERVAL '60 days' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN cnpj IS NOT NULL AND cnpj != '' THEN 15
        WHEN razao_social IS NOT NULL AND razao_social != '' THEN 10
        WHEN empresa_nome IS NOT NULL AND empresa_nome != '' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN produtos > 100 THEN 25
        WHEN produtos > 50 THEN 20
        WHEN produtos > 20 THEN 15
        WHEN produtos > 10 THEN 10
        WHEN produtos > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN clientes > 50 THEN 20
        WHEN clientes > 20 THEN 15
        WHEN clientes > 10 THEN 10
        WHEN clientes > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN vendas > 100 THEN 30
        WHEN vendas > 50 THEN 25
        WHEN vendas > 20 THEN 20
        WHEN vendas > 10 THEN 15
        WHEN vendas > 5 THEN 10
        WHEN vendas > 1 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN valor_total_vendas > 50000 THEN 20
        WHEN valor_total_vendas > 20000 THEN 15
        WHEN valor_total_vendas > 10000 THEN 10
        WHEN valor_total_vendas > 5000 THEN 5
        ELSE 0 
      END
    ) >= 40 THEN '✅ PROVÁVEL (Usuário Ativo)'
    WHEN (
      CASE 
        WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 20
        WHEN last_sign_in_at > NOW() - INTERVAL '14 days' THEN 15
        WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 10
        WHEN last_sign_in_at > NOW() - INTERVAL '60 days' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN cnpj IS NOT NULL AND cnpj != '' THEN 15
        WHEN razao_social IS NOT NULL AND razao_social != '' THEN 10
        WHEN empresa_nome IS NOT NULL AND empresa_nome != '' THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN produtos > 100 THEN 25
        WHEN produtos > 50 THEN 20
        WHEN produtos > 20 THEN 15
        WHEN produtos > 10 THEN 10
        WHEN produtos > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN clientes > 50 THEN 20
        WHEN clientes > 20 THEN 15
        WHEN clientes > 10 THEN 10
        WHEN clientes > 5 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN vendas > 100 THEN 30
        WHEN vendas > 50 THEN 25
        WHEN vendas > 20 THEN 20
        WHEN vendas > 10 THEN 15
        WHEN vendas > 5 THEN 10
        WHEN vendas > 1 THEN 5
        ELSE 0 
      END +
      CASE 
        WHEN valor_total_vendas > 50000 THEN 20
        WHEN valor_total_vendas > 20000 THEN 15
        WHEN valor_total_vendas > 10000 THEN 10
        WHEN valor_total_vendas > 5000 THEN 5
        ELSE 0 
      END
    ) >= 20 THEN '⚠️ POSSÍVEL (Teste Ativo)'
    ELSE '❌ IMPROVÁVEL (Teste Inativo)'
  END as classificacao
FROM user_stats
WHERE id IS NOT NULL
ORDER BY activity_score DESC, last_sign_in_at DESC NULLS LAST;

-- ============================================
-- INSTRUÇÕES
-- ============================================
-- Score >= 70: MUITO PROVÁVEL que era cliente pago - DAR 3 MESES GRÁTIS
-- Score 40-69: PROVÁVEL usuário ativo - DAR 1 MÊS GRÁTIS
-- Score 20-39: POSSÍVEL usuário em teste - DAR 15 DIAS EXTRAS
-- Score < 20: Improvável - Manter teste padrão de 15 dias
