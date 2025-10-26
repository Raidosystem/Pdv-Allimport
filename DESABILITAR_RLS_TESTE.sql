-- ============================================
-- DESABILITAR RLS TEMPORARIAMENTE (TESTE)
-- ============================================
-- user_id correto mas ainda não aparece
-- Vamos desabilitar RLS para testar
-- ============================================

-- 1. Verificar se user_id está correto
SELECT 
  'CLIENTES' as tabela,
  COUNT(*) as total_no_banco,
  COUNT(CASE WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as com_user_id_correto
FROM clientes
UNION ALL
SELECT 
  'ORDENS' as tabela,
  COUNT(*) as total_no_banco,
  COUNT(CASE WHEN usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as com_user_id_correto
FROM ordens_servico;

-- 2. Ver políticas RLS que podem estar bloqueando
SELECT 
  tablename,
  policyname,
  cmd,
  permissive,
  roles,
  SUBSTRING(qual, 1, 150) as condicao
FROM pg_policies
WHERE tablename IN ('clientes', 'ordens_servico')
ORDER BY tablename, policyname;

-- 3. DESABILITAR RLS TEMPORARIAMENTE (apenas para teste)
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

-- 4. Verificar se RLS foi desabilitado
SELECT 
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE tablename IN ('clientes', 'ordens_servico', 'produtos');

-- ============================================
-- APÓS EXECUTAR:
-- 1. Recarregue o navegador (Ctrl+Shift+R)
-- 2. Se aparecer, o problema é nas políticas RLS
-- 3. Depois podemos reabilitar RLS com políticas corretas
-- ============================================
