-- ============================================
-- RESTAURAÇÃO SIMPLIFICADA - TESTE
-- ============================================

-- PASSO 1: Inserir clientes
INSERT INTO clientes
SELECT * FROM clientes_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 2: Restaurar ordens
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 3: Verificar resultado
SELECT
  'Clientes' as tabela,
  COUNT(*) as total
FROM clientes
UNION ALL
SELECT
  'Ordens' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- PASSO 4: Verificar órfãos
SELECT COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 5: Testar EDVANIA
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
