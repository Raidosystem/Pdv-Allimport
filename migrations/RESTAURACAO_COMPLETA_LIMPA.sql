-- ============================================
-- RESTAURAÇÃO COMPLETA E LIMPA DO BACKUP JSON
-- ============================================

-- PASSO 1: Remover constraint temporariamente
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- PASSO 2: Limpar tudo
TRUNCATE TABLE clientes CASCADE;

-- PASSO 3: Inserir clientes do backup JSON (execute o RESTAURAR_CLIENTES_SQL_GERADO.sql aqui)
-- OU execute ele separadamente ANTES de continuar

-- PASSO 4: Verificar clientes inseridos
SELECT COUNT(*) as total_clientes FROM clientes;
-- Deve retornar: 141

-- PASSO 5: Inserir ordens (execute o INSERIR_ORDENS_BACKUP_JSON.sql aqui)
-- OU execute ele separadamente

-- PASSO 6: Adicionar constraint segura
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL
NOT VALID;

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

-- PASSO 8: Verificar órfãos (deve ser 0!)
SELECT COUNT(*) as orfaos
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 9: TESTAR EDVANIA!
SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.tipo,
  os.descricao_problema,
  os.data_entrada,
  c.nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;
