-- =====================================================
-- RECUPERAR ADMINISTRADOR CORRETO
-- =====================================================
-- Problema: Deletamos o admin principal Cristiano Ramos Mendes
-- Solução: Verificar quem existe e restaurar o admin correto
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
    WHEN email = 'assistenciaallimport10@gmail.com' THEN '👑 ADMIN PRINCIPAL'
    ELSE '👤 FUNCIONÁRIO'
  END as tipo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at;

-- =====================================================
-- 2. VERIFICAR SE EXISTE CRISTIANO (ADMIN)
-- =====================================================

SELECT 
  COUNT(*) as existe_admin
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- 3. CRIAR/RESTAURAR ADMIN CRISTIANO RAMOS MENDES
-- =====================================================

-- Inserir admin principal (se não existir)
INSERT INTO funcionarios (
  id,
  empresa_id,
  nome,
  email,
  telefone,
  tipo_admin,
  ativo,
  created_at,
  updated_at
)
VALUES (
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1', -- Usar empresa_id como ID do funcionário admin
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1', -- empresa_id CORRETO
  'Cristiano Ramos Mendes',
  'assistenciaallimport10@gmail.com',
  '(17) 98834-2799',
  'admin_empresa',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  nome = 'Cristiano Ramos Mendes',
  email = 'assistenciaallimport10@gmail.com',
  telefone = '(17) 98834-2799',
  tipo_admin = 'admin_empresa',
  ativo = true,
  updated_at = NOW();

-- =====================================================
-- 4. VERIFICAR RESULTADO
-- =====================================================

-- Deve mostrar Cristiano como admin
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '✅ ADMIN RESTAURADO' as status
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND email = 'assistenciaallimport10@gmail.com';

-- Ver todos os funcionários da empresa
SELECT 
  id,
  nome,
  email,
  tipo_admin,
  ativo,
  CASE 
    WHEN tipo_admin = 'admin_empresa' THEN '👑 ADMINISTRADOR'
    WHEN tipo_admin = 'funcionario' THEN '👤 FUNCIONÁRIO'
    ELSE '⚠️ SEM TIPO'
  END as cargo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY tipo_admin DESC, nome;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Admin Cristiano Ramos Mendes restaurado
-- - Jennifer Sousa permanece como funcionária
-- - Login deve mostrar Cristiano como admin principal
-- =====================================================
