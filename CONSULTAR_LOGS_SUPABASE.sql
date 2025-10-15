-- ============================================
-- TENTAR RECUPERAR INFORMAÇÕES DE LOGS
-- ============================================

-- ⚠️ AVISO: Este arquivo está OBSOLETO
-- Use o arquivo: CONSULTAR_USUARIOS_ATIVOS_SIMPLES.sql
-- Ele tem análise mais completa e funciona sem audit logs

-- 1. VERIFICAR LOGS DE AUTENTICAÇÃO
-- Pode dar pistas sobre usuários ativos recentemente
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  email_confirmed_at
FROM auth.users
WHERE last_sign_in_at > NOW() - INTERVAL '30 days'
ORDER BY last_sign_in_at DESC;

-- 3. VERIFICAR SE HÁ DADOS EM OUTRAS TABELAS
-- que possam indicar usuários ativos (vendas, produtos, etc.)
SELECT 
  user_id,
  COUNT(*) as num_vendas,
  MAX(created_at) as ultima_venda
FROM vendas
WHERE created_at > NOW() - INTERVAL '90 days'
GROUP BY user_id
ORDER BY num_vendas DESC;

-- 4. VERIFICAR TABELA EMPRESAS
-- Empresas com dados preenchidos provavelmente estavam ativas
SELECT 
  e.user_id,
  u.email,
  e.nome,
  e.razao_social,
  e.cnpj,
  e.created_at,
  e.updated_at,
  u.last_sign_in_at
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE e.cnpj IS NOT NULL AND e.cnpj != ''
ORDER BY u.last_sign_in_at DESC NULLS LAST;

-- 5. BUSCAR PRODUTOS CADASTRADOS
-- Usuários com muitos produtos provavelmente tinham plano ativo
SELECT 
  p.user_id,
  u.email,
  COUNT(*) as num_produtos,
  MAX(p.created_at) as ultimo_produto
FROM produtos p
JOIN auth.users u ON u.id = p.user_id
GROUP BY p.user_id, u.email
HAVING COUNT(*) > 10  -- Ajuste este número conforme necessário
ORDER BY num_produtos DESC;

-- 6. BUSCAR CLIENTES CADASTRADOS
-- Muitos clientes = usuário ativo
SELECT 
  c.user_id,
  u.email,
  COUNT(*) as num_clientes,
  MAX(c.created_at) as ultimo_cliente
FROM clientes c
JOIN auth.users u ON u.id = c.user_id
GROUP BY c.user_id, u.email
HAVING COUNT(*) > 5
ORDER BY num_clientes DESC;

-- ============================================
-- HEURÍSTICA: IDENTIFICAR USUÁRIOS "ATIVOS"
-- ============================================
-- Usuários que provavelmente tinham plano pago:
-- - Login recente (últimos 30 dias)
-- - Dados completos na tabela empresas
-- - Muitos produtos/clientes/vendas cadastrados

WITH user_activity AS (
  SELECT 
    u.id,
    u.email,
    u.created_at as cadastro_em,
    u.last_sign_in_at,
    e.nome as empresa_nome,
    e.cnpj,
    COALESCE(p.num_produtos, 0) as produtos,
    COALESCE(c.num_clientes, 0) as clientes,
    COALESCE(v.num_vendas, 0) as vendas
  FROM auth.users u
  LEFT JOIN empresas e ON e.user_id = u.id
  LEFT JOIN (SELECT user_id, COUNT(*) as num_produtos FROM produtos GROUP BY user_id) p ON p.user_id = u.id
  LEFT JOIN (SELECT user_id, COUNT(*) as num_clientes FROM clientes GROUP BY user_id) c ON c.user_id = u.id
  LEFT JOIN (SELECT user_id, COUNT(*) as num_vendas FROM vendas GROUP BY user_id) v ON v.user_id = u.id
)
SELECT 
  *,
  -- Score de atividade (quanto maior, mais provável que era cliente pago)
  (
    CASE WHEN last_sign_in_at > NOW() - INTERVAL '7 days' THEN 10 ELSE 0 END +
    CASE WHEN last_sign_in_at > NOW() - INTERVAL '30 days' THEN 5 ELSE 0 END +
    CASE WHEN cnpj IS NOT NULL AND cnpj != '' THEN 10 ELSE 0 END +
    CASE WHEN produtos > 50 THEN 15 
         WHEN produtos > 20 THEN 10 
         WHEN produtos > 5 THEN 5 
         ELSE 0 END +
    CASE WHEN clientes > 20 THEN 10 
         WHEN clientes > 5 THEN 5 
         ELSE 0 END +
    CASE WHEN vendas > 50 THEN 20 
         WHEN vendas > 10 THEN 10 
         WHEN vendas > 1 THEN 5 
         ELSE 0 END
  ) as activity_score
FROM user_activity
ORDER BY activity_score DESC;

-- Usuários com score > 30 provavelmente tinham plano ativo
-- Usuários com score > 50 muito provavelmente eram clientes pagos
