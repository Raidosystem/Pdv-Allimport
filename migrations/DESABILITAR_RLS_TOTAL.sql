-- ============================================
-- DESABILITAR RLS EM FUNCIONARIOS (LEITURA)
-- ============================================

-- Desabilitar RLS para permitir leitura
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;

-- Verificar status
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename IN ('funcionarios', 'login_funcionarios');

-- ============================================
-- EXECUTE AGORA!
-- ============================================
-- Depois recarregue a página
-- Maria Silva deve aparecer na lista
-- ============================================
