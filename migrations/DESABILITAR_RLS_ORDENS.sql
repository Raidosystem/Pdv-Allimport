-- =====================================================
-- VERIFICAR E DESABILITAR RLS TEMPORARIAMENTE
-- =====================================================

-- 1. Verificar se RLS está ativo na tabela ordens_servico
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables
WHERE tablename = 'ordens_servico';

-- 2. Ver políticas ativas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'ordens_servico';

-- 3. DESABILITAR RLS TEMPORARIAMENTE PARA TESTE
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

-- 4. Testar contagem novamente
SELECT COUNT(*) as total_sem_rls
FROM ordens_servico;

-- 5. REABILITAR RLS (execute depois do teste)
-- ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
