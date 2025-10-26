-- ============================================
-- SOLUÇÃO FINAL SIMPLIFICADA
-- Usa tabelas de backup que já existem
-- ============================================

-- PASSO 1: Verificar que temos os backups
SELECT 'Backup Clientes' as tabela, COUNT(*) as registros FROM clientes_backup_seguranca_completo
UNION ALL
SELECT 'Backup Ordens' as tabela, COUNT(*) as registros FROM ordens_backup_seguranca_completo;

-- PASSO 2: Remover constraint CASCADE
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- PASSO 3: Restaurar clientes do backup de segurança
INSERT INTO clientes
SELECT * FROM clientes_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 4: Restaurar ordens do backup de segurança (SEM constraint)
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 5: Adicionar constraint segura (SET NULL) DEPOIS de inserir
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL
NOT VALID;  -- Não valida dados existentes

-- PASSO 6: Verificar totais
SELECT
  'Clientes' as tabela,
  COUNT(*) as total
FROM clientes
UNION ALL
SELECT
  'Ordens' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- PASSO 7: Verificar órfãos
SELECT COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 8: TESTAR NO SISTEMA AGORA!
-- Abra o formulário de Ordem de Serviço
-- Selecione EDVANIA DA SILVA (CPF: 375.117.738-85)
-- Verifique se aparecem equipamentos anteriores no dropdown!

SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.tipo,
  os.data_entrada,
  c.nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj IN ('37511773885', '375.117.738-85')
ORDER BY os.data_entrada DESC
LIMIT 10;
