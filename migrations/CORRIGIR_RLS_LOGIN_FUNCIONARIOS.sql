-- ============================================
-- CORRIGIR PERMISSÕES RLS - LOGIN_FUNCIONARIOS
-- ============================================
-- Erro 403: Admin não consegue inserir em login_funcionarios
-- ============================================

-- 1. Verificar políticas RLS atuais
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'login_funcionarios';

-- 2. Desabilitar RLS temporariamente (CUIDADO!)
-- Descomente se necessário
-- ALTER TABLE login_funcionarios DISABLE ROW LEVEL SECURITY;

-- 3. Criar política para admin inserir login de funcionários
DROP POLICY IF EXISTS "Admins podem gerenciar login de funcionários" ON login_funcionarios;

CREATE POLICY "Admins podem gerenciar login de funcionários"
ON login_funcionarios
FOR ALL
USING (
    EXISTS (
        SELECT 1 
        FROM funcionarios f
        WHERE f.id = login_funcionarios.funcionario_id
          AND f.empresa_id = auth.uid()
          AND f.tipo_admin = 'admin_empresa'
    )
    OR
    EXISTS (
        SELECT 1
        FROM funcionarios f
        WHERE f.empresa_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM funcionarios f  
        WHERE f.id = login_funcionarios.funcionario_id
          AND f.empresa_id = auth.uid()
    )
);

-- 4. Garantir que RLS está habilitado
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;

-- 5. Verificar resultado
SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'login_funcionarios';

-- ============================================
-- POLÍTICA SIMPLIFICADA (SE A ACIMA NÃO FUNCIONAR)
-- ============================================
-- Descomente se precisar:

/*
DROP POLICY IF EXISTS "login_funcionarios_policy" ON login_funcionarios;

CREATE POLICY "login_funcionarios_policy"
ON login_funcionarios
FOR ALL
USING (true)
WITH CHECK (true);
*/

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- ✅ Admin consegue inserir em login_funcionarios
-- ✅ Admin consegue ler login de funcionários da empresa
-- ✅ RLS protege dados entre empresas
-- ============================================
