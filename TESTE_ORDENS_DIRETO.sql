-- =====================================================
-- TESTE DIRETO: Contar ordens sem filtros
-- =====================================================

-- Ver se há algum problema de RLS ou filtros
SELECT COUNT(*) as total
FROM ordens_servico;

-- Ver as primeiras 5 ordens
SELECT 
  id,
  created_at,
  status,
  equipamento
FROM ordens_servico
ORDER BY created_at DESC
LIMIT 5;

-- Ver distribuição por status
SELECT 
  status,
  COUNT(*) as quantidade
FROM ordens_servico
GROUP BY status;
