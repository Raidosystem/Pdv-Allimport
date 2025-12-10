-- =====================================================
-- VERIFICAR ORDENS DE SERVIÇO NO BANCO
-- =====================================================

-- 0. Verificar estrutura da tabela primeiro
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;

-- 1. Ver todas as ordens de serviço cadastradas (selecionando todas as colunas)
SELECT *
FROM ordens_servico
ORDER BY created_at DESC
LIMIT 20;

-- 2. Contar ordens por status
SELECT 
  status,
  COUNT(*) as quantidade
FROM ordens_servico
GROUP BY status
ORDER BY quantidade DESC;

-- 3. Verificar user_id e empresa_id das ordens
SELECT 
  DISTINCT user_id,
  empresa_id,
  COUNT(*) as total_ordens
FROM ordens_servico
GROUP BY user_id, empresa_id;

-- 4. Verificar se há ordens nos últimos 30 dias
SELECT 
  COUNT(*) as ordens_ultimo_mes,
  MIN(created_at) as primeira_ordem,
  MAX(created_at) as ultima_ordem
FROM ordens_servico
WHERE created_at >= NOW() - INTERVAL '30 days';

-- 5. Contar TOTAL de ordens
SELECT COUNT(*) as total_geral
FROM ordens_servico;
