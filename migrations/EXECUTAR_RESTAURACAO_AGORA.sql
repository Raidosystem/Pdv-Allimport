-- ============================================
-- RESTAURAÇÃO COMPLETA - EXECUTE PASSO A PASSO
-- ============================================

-- ✅ PASSO 1: Remover constraint
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- ✅ PASSO 2: Limpar dados antigos
TRUNCATE TABLE clientes CASCADE;

-- ✅ PASSO 3: Verificar que está vazio
SELECT 'Clientes' as tabela, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'Ordens' as tabela, COUNT(*) as total FROM ordens_servico;
-- Deve mostrar 0 em ambos!

-- ⏸️ AGUARDE! Antes de continuar, execute estes 2 comandos:
-- 1️⃣ Execute TODO o arquivo: RESTAURAR_CLIENTES_SQL_GERADO.sql
-- 2️⃣ Execute TODO o arquivo: INSERIR_ORDENS_BACKUP_JSON.sql

-- ✅ PASSO 4: Depois de executar os 2 arquivos acima, volte aqui e execute:

-- Verificar se clientes foram inseridos
SELECT 'Clientes inseridos' as status, COUNT(*) as total FROM clientes;
-- Deve ser 141

-- Verificar se ordens foram inseridas
SELECT 'Ordens inseridas' as status, COUNT(*) as total FROM ordens_servico;
-- Deve ser 160

-- ✅ PASSO 5: Recriar constraint segura
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL
NOT VALID;

-- ✅ PASSO 6: Verificar órfãos (DEVE SER 0!)
SELECT 'Órfãos' as status, COUNT(*) as total
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- 🎯 PASSO 7: TESTE FINAL - EDVANIA!
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

-- DEVE RETORNAR 2 ORDENS:
-- 1. OS-2025-06-17-001 - CELULAR MOTO E13 - TELA QUEBRADA
-- 2. OS-2025-06-17-002 - CELULAR SAMSUNG A06 - BLOQUEIO GMAIL
