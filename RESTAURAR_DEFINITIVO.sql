-- ============================================
-- RESTAURAÇÃO DEFINITIVA - SEM CASCADE
-- ============================================

-- PASSO 1: Remover constraint CASCADE (se existir)
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- PASSO 2: Adicionar constraint SEM CASCADE (SET NULL em vez de DELETE)
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL;

-- PASSO 3: Restaurar clientes
INSERT INTO clientes
SELECT * FROM clientes_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 4: Restaurar ordens
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 5: Atualizar ID da EDVANIA
UPDATE ordens_servico
SET cliente_id = 'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62'
WHERE cliente_id = 'e7491ef4-2e57-4ae4-9e7c-3912c0ad190b';

-- PASSO 6: Verificar resultado
SELECT
  'Clientes' as tabela,
  COUNT(*) as total
FROM clientes
UNION ALL
SELECT
  'Ordens' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- PASSO 7: Órfãos
SELECT COUNT(*) as orfaos FROM ordens_servico WHERE cliente_id IS NULL;

-- PASSO 8: Testar EDVANIA
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
