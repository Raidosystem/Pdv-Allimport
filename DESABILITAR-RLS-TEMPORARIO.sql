-- =====================================================
-- DESABILITAR RLS TEMPORARIAMENTE PARA TESTE
-- =====================================================
-- ⚠️ IMPORTANTE: Isso desabilita a segurança temporariamente para diagnóstico
-- Execute este SQL como SUPERUSER ou com role service_role

-- 1. DESABILITAR RLS NAS TABELAS
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;

-- 2. VERIFICAR TODOS OS CLIENTES (sem filtro RLS)
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
  COUNT(telefone) as com_telefone,
  COUNT(cpf_cnpj) as com_cpf_cnpj
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 3. VERIFICAR AMOSTRA DE CLIENTES
SELECT 
  id,
  nome,
  telefone,
  cpf_cnpj,
  email,
  ativo,
  created_at
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true
ORDER BY created_at DESC
LIMIT 10;

-- 4. VERIFICAR FUNCIONÁRIOS
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  created_at
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at DESC;

-- 5. REABILITAR RLS (IMPORTANTE!)
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Se aparecerem os 98 clientes aqui, o problema é RLS
-- - Se não aparecerem, os clientes não estão no banco
-- =====================================================
