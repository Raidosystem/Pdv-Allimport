-- ============================================================================
-- VERIFICAR DADOS DE VENDAS E PRODUTOS
-- ============================================================================

-- 1️⃣ VERIFICAR PRODUTOS CADASTRADOS
SELECT 
  COUNT(*) as total_produtos,
  COUNT(DISTINCT categoria_id) as total_categorias
FROM produtos;

-- 2️⃣ VER CATEGORIAS DISPONÍVEIS
SELECT 
  c.nome as categoria,
  COUNT(p.id) as total_produtos
FROM produtos p
LEFT JOIN categorias c ON c.id = p.categoria_id
GROUP BY c.nome
ORDER BY total_produtos DESC;

-- 3️⃣ VERIFICAR VENDAS
SELECT 
  COUNT(*) as total_vendas,
  MIN(created_at) as primeira_venda,
  MAX(created_at) as ultima_venda,
  SUM(total) as faturamento_total
FROM vendas;

-- 4️⃣ VERIFICAR ITENS VENDIDOS
SELECT 
  COUNT(*) as total_itens,
  SUM(quantidade) as unidades_vendidas,
  SUM(subtotal) as receita_total
FROM itens_venda;

-- 5️⃣ VER PRODUTOS MAIS VENDIDOS
SELECT 
  p.nome as produto,
  c.nome as categoria,
  COUNT(iv.id) as vendas,
  SUM(iv.quantidade) as unidades,
  SUM(iv.subtotal) as receita
FROM itens_venda iv
LEFT JOIN produtos p ON p.id = iv.produto_id
LEFT JOIN categorias c ON c.id = p.categoria_id
GROUP BY p.id, p.nome, c.nome
ORDER BY receita DESC
LIMIT 10;

-- 6️⃣ VER CATEGORIAS MAIS VENDIDAS
SELECT 
  c.nome as categoria,
  COUNT(iv.id) as vendas,
  SUM(iv.quantidade) as unidades,
  SUM(iv.subtotal) as receita
FROM itens_venda iv
LEFT JOIN produtos p ON p.id = iv.produto_id
LEFT JOIN categorias c ON c.id = p.categoria_id
WHERE c.nome IS NOT NULL
GROUP BY c.nome
ORDER BY receita DESC;

-- ============================================================================
-- Execute estas queries para verificar se existem dados de vendas
-- ============================================================================
