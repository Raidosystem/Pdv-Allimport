-- =====================================================
-- ATUALIZAR FUNCIONÁRIO EXISTENTE PARA ADMIN
-- =====================================================
-- Problema: Já existe funcionário com o email do admin
-- Solução: Atualizar funcionário existente para tipo admin
-- =====================================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- =====================================================
-- 1. VER TODOS OS FUNCIONÁRIOS DA EMPRESA
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  created_at,
  CASE 
    WHEN email = 'assistenciaallimport10@gmail.com' THEN '👑 DEVE SER ADMIN'
    ELSE '👤 FUNCIONÁRIO'
  END as tipo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at;

-- =====================================================
-- 2. ATUALIZAR PARA ADMIN_EMPRESA
-- =====================================================

-- Atualizar funcionário com email do admin para ser admin_empresa
UPDATE funcionarios 
SET 
  nome = 'Cristiano Ramos Mendes',
  tipo_admin = 'admin_empresa',
  telefone = '(17) 98834-2799',
  ativo = true,
  updated_at = NOW()
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- 3. VERIFICAR RESULTADO
-- =====================================================

-- Deve mostrar Cristiano como admin_empresa
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '✅ ATUALIZADO PARA ADMIN' as status
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND email = 'assistenciaallimport10@gmail.com';

-- Ver todos os funcionários
SELECT 
  id,
  nome,
  email,
  tipo_admin,
  ativo,
  CASE 
    WHEN tipo_admin = 'admin_empresa' THEN '👑 ADMINISTRADOR'
    WHEN tipo_admin = 'funcionario' THEN '👤 FUNCIONÁRIO'
    WHEN tipo_admin IS NULL THEN '⚠️ SEM TIPO'
    ELSE tipo_admin
  END as cargo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY 
  CASE 
    WHEN tipo_admin = 'admin_empresa' THEN 1
    ELSE 2
  END,
  nome;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Cristiano Ramos Mendes agora é admin_empresa
-- - Jennifer Sousa permanece como funcionária
-- - Login deve mostrar Cristiano com título de administrador
-- =====================================================
