-- Verificar políticas RLS da tabela clientes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename IN ('clientes', 'ordens_servico');

-- Testar se consegue ler clientes diretamente
SELECT COUNT(*) as total_clientes FROM clientes;

-- Testar JOIN manual
SELECT 
  os.numero_os,
  os.cliente_id,
  c.id as cliente_id_encontrado,
  c.nome
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os IN ('OS-2025-06-17-001', 'OS-2025-06-17-002')
ORDER BY os.numero_os;
