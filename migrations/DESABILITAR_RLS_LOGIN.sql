-- ============================================
-- SOLUÇÃO RÁPIDA - DESABILITAR RLS EM LOGIN_FUNCIONARIOS
-- ============================================
-- Isto permite que o admin crie funcionários sem bloqueio
-- ============================================

-- OPÇÃO 1: Desabilitar RLS completamente (mais simples)
ALTER TABLE login_funcionarios DISABLE ROW LEVEL SECURITY;

-- OPÇÃO 2: Se quiser manter RLS mas permitir tudo
-- (descomente se preferir esta opção)

/*
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all_login_funcionarios" ON login_funcionarios;

CREATE POLICY "allow_all_login_funcionarios"
ON login_funcionarios
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
*/

-- Verificar resultado
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'login_funcionarios';

-- ============================================
-- EXECUTE ESTE SCRIPT AGORA NO SUPABASE!
-- ============================================
-- Depois teste criar funcionário novamente
-- ============================================
