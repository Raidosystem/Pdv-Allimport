-- =====================================================
-- VERIFICAR ESTADO ATUAL DO SISTEMA
-- =====================================================

-- 1. VERIFICAR FUNCIONÁRIOS EXISTENTES
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '✅ FUNCIONÁRIO' as tipo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at DESC;

-- 2. VERIFICAR CLIENTES ATIVOS
SELECT 
  COUNT(*) as total_clientes_ativos,
  COUNT(telefone) as com_telefone,
  COUNT(cpf_cnpj) as com_cpf_cnpj,
  COUNT(cpf_digits) as com_cpf_digits
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true;

-- 3. VERIFICAR CLIENTES (AMOSTRA)
SELECT 
  id,
  nome,
  telefone,
  cpf_cnpj,
  cpf_digits,
  email,
  ativo,
  '📋 CLIENTE' as tipo
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true
ORDER BY created_at DESC
LIMIT 10;

-- 4. VERIFICAR POLÍTICAS RLS DE CLIENTES
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 5. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('clientes', 'funcionarios');

-- =====================================================
-- DIAGNÓSTICO ESPERADO:
-- - 1 funcionário: Cristiano Ramos Mendes (admin_empresa)
-- - 98 clientes ativos com telefone e CPF
-- - Políticas RLS ativas mas permitindo acesso ao admin
-- =====================================================
