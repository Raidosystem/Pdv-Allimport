-- Verificar clientes com empresa_id NULL
SELECT 
  'Clientes com empresa_id NULL' as tipo,
  COUNT(*) as total
FROM clientes 
WHERE empresa_id IS NULL;

-- Verificar CPFs duplicados
SELECT 
  cpf_digits,
  COUNT(*) as quantidade,
  STRING_AGG(COALESCE(empresa_id::text, 'NULL'), ', ') as empresas
FROM clientes 
WHERE cpf_digits IS NOT NULL AND cpf_digits != ''
GROUP BY cpf_digits
HAVING COUNT(*) > 1
ORDER BY quantidade DESC
LIMIT 10;
