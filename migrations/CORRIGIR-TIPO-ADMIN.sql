-- =====================================================
-- CORRIGIR TIPO DE ADMIN DO FUNCIONÁRIO
-- =====================================================

-- 1. VERIFICAR FUNCIONÁRIO ATUAL
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '❌ ANTES DA CORREÇÃO' as status
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 2. ATUALIZAR PARA ADMIN_EMPRESA
UPDATE funcionarios 
SET 
  tipo_admin = 'admin_empresa',
  nome = 'Cristiano Ramos Mendes',
  updated_at = NOW()
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND email = 'assistenciaallimport10@gmail.com';

-- 3. VERIFICAR CORREÇÃO
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '✅ DEPOIS DA CORREÇÃO' as status
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 4. VERIFICAR SE AGORA TEM ACESSO AOS CLIENTES
SELECT 
  COUNT(*) as total_clientes_ativos,
  COUNT(telefone) as com_telefone,
  COUNT(cpf_cnpj) as com_cpf_cnpj
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true;

-- 5. VERIFICAR AMOSTRA DE CLIENTES
SELECT 
  id,
  nome,
  telefone,
  cpf_cnpj,
  email,
  ativo
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true
ORDER BY created_at DESC
LIMIT 5;

-- =====================================================
-- RESULTADO ESPERADO:
-- - tipo_admin mudado para 'admin_empresa'
-- - nome mudado para 'Cristiano Ramos Mendes'
-- - 98 clientes ativos agora visíveis
-- =====================================================
