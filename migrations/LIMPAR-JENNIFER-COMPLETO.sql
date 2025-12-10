-- =====================================================
-- VERIFICAR E LIMPAR JENNIFER SOUSA
-- =====================================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- =====================================================
-- 1. BUSCAR JENNIFER EM TODAS AS EMPRESAS
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  created_at,
  'ENCONTRADO' as status
FROM funcionarios 
WHERE nome ILIKE '%Jennifer%' OR email ILIKE '%jennifer%'
ORDER BY created_at;

-- =====================================================
-- 2. BUSCAR TODOS FUNCIONÁRIOS DA EMPRESA CORRETA
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =====================================================
-- 3. BUSCAR FUNCIONÁRIOS DA EMPRESA ERRADA (antiga)
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '❌ EMPRESA ERRADA' as status
FROM funcionarios 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- =====================================================
-- 4. DELETAR JENNIFER DE QUALQUER EMPRESA
-- =====================================================

DELETE FROM funcionarios 
WHERE nome ILIKE '%Jennifer%' OR email ILIKE '%jennifer%';

-- =====================================================
-- 5. DELETAR TODOS DA EMPRESA ERRADA (se houver)
-- =====================================================

DELETE FROM funcionarios 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- =====================================================
-- 6. VERIFICAR LIMPEZA COMPLETA
-- =====================================================

-- Deve retornar 0 para empresa correta
SELECT 
  COUNT(*) as funcionarios_empresa_correta
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Deve retornar 0 para empresa errada
SELECT 
  COUNT(*) as funcionarios_empresa_errada
FROM funcionarios 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- Não deve encontrar Jennifer
SELECT 
  COUNT(*) as jennifer_encontrada
FROM funcionarios 
WHERE nome ILIKE '%Jennifer%' OR email ILIKE '%jennifer%';

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Jennifer deletada de todas as empresas
-- - Empresa correta: 0 funcionários
-- - Empresa errada: 0 funcionários
-- - Sistema pronto para criar admin automático no próximo login
-- =====================================================
