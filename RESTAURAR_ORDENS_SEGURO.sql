-- ============================================
-- VERIFICAR E USAR BACKUP JSON
-- ============================================

-- PASSO 1: Verificar quantos clientes temos agora
SELECT COUNT(*) as clientes_atuais FROM clientes;

-- PASSO 2: Verificar quantos estão no backup do JSON (já inseridos)
SELECT COUNT(*) as clientes_no_backup_json 
FROM clientes
WHERE created_at <= '2025-08-01T21:17:02.031Z';

-- PASSO 3: Agora restaurar ordens usando os clientes que JÁ estão na tabela
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
WHERE cliente_id IN (SELECT id FROM clientes)
ON CONFLICT (id) DO NOTHING;

-- PASSO 4: Verificar resultado
SELECT
  'Clientes' as tabela,
  COUNT(*) as total
FROM clientes
UNION ALL
SELECT
  'Ordens' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- PASSO 5: Verificar órfãos
SELECT COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 6: Testar EDVANIA
SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.data_entrada,
  c.nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC
LIMIT 10;
