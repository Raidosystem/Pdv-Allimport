-- Verificar colunas da tabela ordens_servico
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;

-- Ver dados de exemplo
SELECT 
  id, 
  cliente_id, 
  equipamento, 
  defeito_relatado,
  status,
  created_at
FROM ordens_servico
LIMIT 5;
