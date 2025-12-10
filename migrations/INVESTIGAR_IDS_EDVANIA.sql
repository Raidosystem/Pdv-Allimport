-- Investigar IDs da EDVANIA

-- 1. Qual ID ela tem na tabela clientes atual?
SELECT id, nome, cpf_cnpj, telefone, created_at
FROM clientes
WHERE cpf_cnpj = '37511773885';

-- 2. Qual ID ela tinha no backup de segurança?
SELECT id, nome, cpf_cnpj, telefone, created_at
FROM clientes_backup_seguranca_completo
WHERE cpf_cnpj = '37511773885';

-- 3. Quantas EDVANIAS existem nos backups?
SELECT 'Atual' as origem, COUNT(*) as total
FROM clientes
WHERE cpf_cnpj = '37511773885'
UNION ALL
SELECT 'Backup Segurança' as origem, COUNT(*) as total
FROM clientes_backup_seguranca_completo
WHERE cpf_cnpj = '37511773885';

-- 4. Verificar se há ordens com o ID antigo da EDVANIA (do backup de segurança)
SELECT os.numero_os, os.cliente_id, os.marca, os.modelo, os.data_entrada
FROM ordens_backup_seguranca_completo os
WHERE os.cliente_id IN (
  SELECT id FROM clientes_backup_seguranca_completo WHERE cpf_cnpj = '37511773885'
)
ORDER BY os.data_entrada DESC
LIMIT 10;

-- 5. Comparar IDs
SELECT 
  'ID no backup JSON (atual)' as descricao,
  id
FROM clientes
WHERE cpf_cnpj = '37511773885'
UNION ALL
SELECT 
  'ID no backup segurança (antigo)' as descricao,
  id
FROM clientes_backup_seguranca_completo
WHERE cpf_cnpj = '37511773885';
