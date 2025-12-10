-- Descobrir onde está a tabela empresas
SELECT 
  table_schema,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_name = 'empresas';
