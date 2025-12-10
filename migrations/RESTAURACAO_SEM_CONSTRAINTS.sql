-- ============================================
-- PASSO 1: REMOVER CONSTRAINTS TEMPORARIAMENTE
-- ============================================

-- Remover constraint de user_id dos clientes
ALTER TABLE clientes
DROP CONSTRAINT IF EXISTS clientes_user_id_fkey;

-- Remover constraint de cliente_id das ordens
ALTER TABLE ordens_servico
DROP CONSTRAINT IF EXISTS ordens_servico_cliente_id_fkey;

-- ============================================
-- PASSO 2: LIMPAR DADOS ANTIGOS
-- ============================================

TRUNCATE TABLE clientes CASCADE;

-- ============================================
-- PASSO 3: VERIFICAR QUE ESTÁ VAZIO
-- ============================================

SELECT 'Clientes' as tabela, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'Ordens' as tabela, COUNT(*) as total FROM ordens_servico;
-- Deve mostrar 0 em ambos!

-- ============================================
-- PASSO 4: AGORA EXECUTE OS 2 ARQUIVOS:
-- 1️⃣ RESTAURAR_CLIENTES_SQL_GERADO.sql
-- 2️⃣ INSERIR_ORDENS_BACKUP_JSON.sql
-- ============================================

-- ============================================
-- PASSO 5: RECRIAR CONSTRAINTS (EXECUTE APÓS OS INSERTS)
-- ============================================

-- Recriar constraint de user_id (com NOT VALID para aceitar NULLs)
ALTER TABLE clientes
ADD CONSTRAINT clientes_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES auth.users(id)
ON DELETE SET NULL
NOT VALID;

-- Recriar constraint de cliente_id
ALTER TABLE ordens_servico
ADD CONSTRAINT ordens_servico_cliente_id_fkey 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id)
ON DELETE SET NULL
NOT VALID;

-- ============================================
-- PASSO 6: VERIFICAR RESULTADO
-- ============================================

SELECT 'Clientes' as tabela, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'Ordens' as tabela, COUNT(*) as total FROM ordens_servico;
-- Deve mostrar: Clientes=141, Ordens=160

-- ============================================
-- PASSO 7: VERIFICAR ÓRFÃOS (DEVE SER 0!)
-- ============================================

SELECT 'Órfãos' as status, COUNT(*) as total
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- ============================================
-- 🎯 PASSO 8: TESTE FINAL - EDVANIA!
-- ============================================

SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.tipo,
  os.descricao_problema,
  os.data_entrada,
  c.nome,
  c.cpf_cnpj
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;

-- DEVE RETORNAR 2 ORDENS:
-- 1. OS-2025-06-17-001 - CELULAR MOTO E13 - TELA QUEBRADA
-- 2. OS-2025-06-17-002 - CELULAR SAMSUNG A06 - BLOQUEIO GMAIL
