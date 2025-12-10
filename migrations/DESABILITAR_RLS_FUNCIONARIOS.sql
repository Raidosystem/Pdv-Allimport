-- ============================================
-- DESABILITAR RLS EM FUNCIONARIOS TAMBÉM
-- ============================================

-- Ver status atual do RLS
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename IN ('funcionarios', 'login_funcionarios');

-- Desabilitar RLS em funcionarios
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;

-- Verificar novamente
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename IN ('funcionarios', 'login_funcionarios');

-- ============================================
-- EXECUTE ESTE TAMBÉM!
-- ============================================
-- Pode ser que o RLS esteja bloqueando a LEITURA
-- ============================================
