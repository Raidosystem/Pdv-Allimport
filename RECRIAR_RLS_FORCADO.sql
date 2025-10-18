-- ============================================
-- RECRIAR RLS SEGURO (FORÇADO)
-- ============================================

-- 1. REMOVER TODAS as políticas antigas (FORÇADO)
DROP POLICY IF EXISTS "funcionarios_empresa_policy" ON funcionarios CASCADE;
DROP POLICY IF EXISTS "login_funcionarios_empresa_policy" ON login_funcionarios CASCADE;
DROP POLICY IF EXISTS "funcionarios_policy" ON funcionarios CASCADE;
DROP POLICY IF EXISTS "login_funcionarios_policy" ON login_funcionarios CASCADE;
DROP POLICY IF EXISTS "allow_all_login_funcionarios" ON login_funcionarios CASCADE;
DROP POLICY IF EXISTS "Admins podem gerenciar login de funcionários" ON login_funcionarios CASCADE;

-- 2. GARANTIR que RLS está habilitado
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR política NOVA para funcionarios
CREATE POLICY "funcionarios_empresa_policy"
ON funcionarios
FOR ALL
TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

-- 4. CRIAR política NOVA para login_funcionarios
CREATE POLICY "login_funcionarios_empresa_policy"
ON login_funcionarios
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 
        FROM funcionarios f
        WHERE f.id = login_funcionarios.funcionario_id
          AND f.empresa_id = auth.uid()
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

-- 5. VERIFICAR se criou
SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;

-- 6. TESTAR - deve mostrar APENAS Maria Silva
SELECT 
    f.id,
    f.nome,
    f.empresa_id,
    f.status,
    lf.usuario
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'
ORDER BY f.created_at DESC;

-- ============================================
-- EXECUTE ESTE! (Já remove as antigas antes)
-- ============================================
