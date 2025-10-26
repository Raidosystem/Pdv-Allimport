-- ============================================
-- RESTAURAÇÃO FINAL COMPLETA
-- ============================================

-- PASSO 1: Remover constraint perigosa
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- PASSO 2: Adicionar constraint segura
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL;

-- PASSO 3: Executar o arquivo RESTAURAR_CLIENTES_SQL_GERADO.sql
-- (Cole AQUI o conteúdo completo daquele arquivo - os 141 INSERTs)
-- Ou execute ele separadamente ANTES deste arquivo

-- VERIFICAR: Clientes inseridos
SELECT COUNT(*) as clientes_inseridos FROM clientes;
-- Deve retornar: 141

-- PASSO 4: Restaurar ordens que têm clientes válidos
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
WHERE cliente_id IN (SELECT id FROM clientes)
ON CONFLICT (id) DO NOTHING;

-- PASSO 5: Mapear IDs antigos para novos (clientes que mudaram de ID)
-- Criar tabela de mapeamento
CREATE TEMP TABLE mapeamento_ids AS
SELECT 
    b.id as id_antigo,
    b.cpf_cnpj,
    c.id as id_novo
FROM clientes_backup_seguranca_completo b
INNER JOIN clientes c ON b.cpf_cnpj = c.cpf_cnpj
WHERE b.id != c.id;

-- Ver quantos IDs mudaram
SELECT COUNT(*) as clientes_com_id_diferente FROM mapeamento_ids;

-- PASSO 6: Atualizar cliente_id das ordens usando o mapeamento
UPDATE ordens_servico os
SET cliente_id = m.id_novo
FROM mapeamento_ids m
WHERE os.cliente_id = m.id_antigo;

-- PASSO 7: Verificar resultado final
SELECT
  'Clientes' as tabela,
  COUNT(*) as total
FROM clientes
UNION ALL
SELECT
  'Ordens' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- PASSO 8: Órfãos restantes
SELECT COUNT(*) as orfaos FROM ordens_servico WHERE cliente_id IS NULL;

-- PASSO 9: TESTAR EDVANIA - DEVE APARECER EQUIPAMENTOS!
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
