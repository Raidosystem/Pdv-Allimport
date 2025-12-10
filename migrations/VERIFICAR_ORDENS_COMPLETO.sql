-- Verificar se havia ordens com o ID antigo da EDVANIA

-- 1. Contar ordens no backup com ID antigo
SELECT COUNT(*) as ordens_no_backup_com_id_antigo
FROM ordens_backup_seguranca_completo
WHERE cliente_id = 'e7491ef4-2e57-4ae4-9e7c-3912c0ad190b';

-- 2. Verificar se essas ordens foram inseridas na tabela ordens_servico
SELECT COUNT(*) as ordens_na_tabela_com_id_antigo
FROM ordens_servico
WHERE cliente_id = 'e7491ef4-2e57-4ae4-9e7c-3912c0ad190b';

-- 3. Total de ordens na tabela
SELECT COUNT(*) as total_ordens FROM ordens_servico;

-- 4. Total de clientes na tabela
SELECT COUNT(*) as total_clientes FROM clientes;

-- 5. Ver TODAS as ordens (qualquer cliente) para verificar se há dados
SELECT 
  os.numero_os,
  os.marca,
  os.modelo,
  os.data_entrada,
  c.nome
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
ORDER BY os.data_entrada DESC
LIMIT 20;
