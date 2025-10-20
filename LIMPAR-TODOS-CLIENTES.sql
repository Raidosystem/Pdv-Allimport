-- =====================================================
-- LIMPAR TODOS OS CLIENTES DE TODOS OS USUÁRIOS
-- =====================================================
-- ⚠️ ATENÇÃO: Isso vai DELETAR TODOS OS CLIENTES!

-- 1. CONTAR CLIENTES ANTES DE DELETAR
SELECT 
  COUNT(*) as total_clientes_antes,
  COUNT(DISTINCT empresa_id) as total_empresas,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM clientes;

-- 2. VER DISTRIBUIÇÃO POR EMPRESA
SELECT 
  empresa_id,
  COUNT(*) as total_clientes
FROM clientes
GROUP BY empresa_id
ORDER BY total_clientes DESC;

-- 3. DELETAR ORDENS DE SERVIÇO PRIMEIRO (para evitar erro de foreign key)
DELETE FROM ordens_servico;

-- 4. DELETAR VENDAS (se existirem e tiverem FK com clientes)
DELETE FROM vendas;

-- 5. DELETAR TODOS OS CLIENTES
DELETE FROM clientes;

-- 6. VERIFICAR LIMPEZA
SELECT 
  COUNT(*) as clientes_restantes,
  'Clientes deletados' as tabela
FROM clientes
UNION ALL
SELECT 
  COUNT(*) as ordens_restantes,
  'Ordens de serviço deletadas' as tabela
FROM ordens_servico
UNION ALL
SELECT 
  COUNT(*) as vendas_restantes,
  'Vendas deletadas' as tabela
FROM vendas;

-- 5. VERIFICAR EMPRESAS (não vamos deletar empresas, só clientes)
SELECT 
  COUNT(*) as total_empresas
FROM empresas;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Todos os clientes deletados
-- - clientes_restantes = 0
-- - Empresas mantidas intactas
-- =====================================================
