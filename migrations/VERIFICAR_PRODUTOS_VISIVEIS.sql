-- ============================================
-- VERIFICAR PRODUTOS VISÍVEIS E OCULTOS
-- ============================================
-- Problema: Somente alguns produtos aparecem
-- Diagnóstico: Comparar user_id/empresa_id
-- ============================================

-- 1. Contar total de produtos no banco
SELECT COUNT(*) as total_produtos_banco FROM produtos;

-- 2. Ver produtos com seus user_id/empresa_id
SELECT 
  id,
  nome,
  preco,
  user_id,
  empresa_id,
  CASE 
    WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MEU USER_ID'
    WHEN user_id IS NULL THEN '⚠️ USER_ID NULL'
    ELSE '❌ OUTRO USER_ID: ' || user_id
  END as status_user,
  CASE 
    WHEN empresa_id IS NOT NULL THEN '✅ TEM EMPRESA_ID: ' || empresa_id
    ELSE '⚠️ EMPRESA_ID NULL'
  END as status_empresa
FROM produtos
ORDER BY id
LIMIT 20;

-- 3. Agrupar produtos por user_id
SELECT 
  user_id,
  COUNT(*) as total_produtos,
  CASE 
    WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MEUS PRODUTOS'
    WHEN user_id IS NULL THEN '⚠️ SEM USER_ID'
    ELSE '❌ OUTRO USUÁRIO'
  END as status
FROM produtos
GROUP BY user_id
ORDER BY total_produtos DESC;

-- 4. Ver clientes e ordens com mesmo diagnóstico
SELECT 
  'CLIENTES' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as meus,
  COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
  COUNT(CASE WHEN user_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as outros
FROM clientes
UNION ALL
SELECT 
  'ORDENS' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as meus,
  COUNT(CASE WHEN usuario_id IS NULL THEN 1 END) as sem_user_id,
  COUNT(CASE WHEN usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as outros
FROM ordens_servico
UNION ALL
SELECT 
  'PRODUTOS' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as meus,
  COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
  COUNT(CASE WHEN user_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as outros
FROM produtos;

-- 5. Verificar políticas RLS de produtos
SELECT 
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'produtos'
ORDER BY policyname;

-- 6. SOLUÇÃO: Atualizar user_id de TODAS as tabelas
-- Execute se Query 4 mostrar dados com user_id diferente ou NULL:
/*
UPDATE produtos 
SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE user_id IS NULL OR user_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

UPDATE clientes 
SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE user_id IS NULL OR user_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

UPDATE ordens_servico 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE usuario_id IS NULL OR usuario_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
*/

-- 7. ALTERNATIVA: Desabilitar RLS temporariamente
/*
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;
*/

-- ============================================
-- EXECUTE Query 1-5 para diagnóstico
-- Se produtos tiverem user_id diferente, execute Query 6
-- ============================================
