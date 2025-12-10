-- =====================================================
-- CORRIGIR EMPRESA_ID DO FUNCIONÁRIO
-- =====================================================
-- Problema: Funcionário está vinculado ao empresa_id errado
-- Solução: Atualizar para o empresa_id correto do usuário
-- =====================================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- =====================================================
-- 1. VERIFICAR ESTADO ATUAL
-- =====================================================

-- Ver funcionário atual
SELECT 
  id,
  empresa_id as empresa_id_atual,
  nome,
  email,
  tipo_admin
FROM funcionarios 
WHERE id = '23f89969-3c78-4b1e-8131-d98c4b81facb';

-- =====================================================
-- 2. ATUALIZAR FUNCIONÁRIO PARA EMPRESA_ID CORRETO
-- =====================================================

-- Atualizar funcionário Cristiano Ramos Mendes
UPDATE funcionarios 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE id = '23f89969-3c78-4b1e-8131-d98c4b81facb'
  AND empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- Atualizar qualquer funcionário com empresa_id NULL para o correto
UPDATE funcionarios 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE email = 'assistenciaallimport10@gmail.com'
  AND empresa_id IS NULL;

-- =====================================================
-- 3. VERIFICAR CORREÇÃO
-- =====================================================

-- Confirmar funcionário corrigido
SELECT 
  id,
  empresa_id as empresa_id_corrigido,
  nome,
  email,
  tipo_admin,
  'CORRETO ✅' as status
FROM funcionarios 
WHERE id = '23f89969-3c78-4b1e-8131-d98c4b81facb'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Verificar se ainda existe algum funcionário com empresa_id errado
SELECT 
  COUNT(*) as funcionarios_empresa_errada
FROM funcionarios 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- Ver todos os funcionários da empresa correta
SELECT 
  id,
  nome,
  email,
  tipo_admin,
  ativo,
  created_at
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at DESC;

-- =====================================================
-- 4. VERIFICAR CLIENTES AGORA VISÍVEIS
-- =====================================================

SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj != '' THEN 1 END) as com_cpf_cnpj
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Funcionário atualizado: 1 registro
-- - Funcionários com empresa_id errado: 0
-- - Total de clientes visíveis: ~138
-- - Com telefone: ~133
-- - Com CPF/CNPJ: ~137
-- =====================================================
