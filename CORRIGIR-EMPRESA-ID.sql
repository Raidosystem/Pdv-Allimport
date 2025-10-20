-- =============================================
-- CORREÇÃO: MOVER CLIENTES PARA EMPRESA CORRETA
-- =============================================

SET session_replication_role = replica;

-- Atualizar empresa_id dos clientes que estão na empresa errada
UPDATE clientes 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- Atualizar clientes órfãos também
UPDATE clientes 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id IS NULL;

SET session_replication_role = DEFAULT;

-- Verificar correção
SELECT 
  'Após correção' as momento,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf
FROM clientes
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Verificar se ainda tem na empresa errada
SELECT 
  COUNT(*) as clientes_empresa_errada
FROM clientes
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';
