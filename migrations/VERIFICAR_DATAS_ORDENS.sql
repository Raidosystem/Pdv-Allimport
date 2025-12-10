-- Verificar datas das ordens de serviço
SELECT 
  id,
  cliente_id,
  marca,
  modelo,
  tipo,
  data_entrada,
  valor_orcamento,
  valor_final,
  status,
  EXTRACT(MONTH FROM data_entrada) as mes,
  EXTRACT(YEAR FROM data_entrada) as ano
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 20;

-- Contar ordens por mês
SELECT 
  TO_CHAR(data_entrada, 'YYYY-MM') as mes_ano,
  COUNT(*) as total_ordens,
  SUM(COALESCE(valor_final, valor_orcamento, 0)) as receita_total
FROM ordens_servico
GROUP BY TO_CHAR(data_entrada, 'YYYY-MM')
ORDER BY mes_ano DESC;

-- Verificar ordens dos últimos 6 meses
SELECT 
  COUNT(*) as total_ordens,
  COUNT(DISTINCT cliente_id) as total_clientes,
  SUM(COALESCE(valor_final, valor_orcamento, 0)) as receita_total
FROM ordens_servico
WHERE data_entrada >= CURRENT_DATE - INTERVAL '6 months';

-- Verificar ordens de todo o período
SELECT 
  COUNT(*) as total_ordens,
  COUNT(DISTINCT cliente_id) as total_clientes,
  MIN(data_entrada) as primeira_ordem,
  MAX(data_entrada) as ultima_ordem,
  SUM(COALESCE(valor_final, valor_orcamento, 0)) as receita_total
FROM ordens_servico;
