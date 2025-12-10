-- ============================================
-- SOLUÇÃO CORRETA: RLS SEGURO POR EMPRESA
-- ============================================
-- Cada admin vê APENAS funcionários da SUA empresa
-- Protege privacidade entre diferentes empresas
-- ============================================

-- 1. HABILITAR RLS nas tabelas
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;

-- 2. LIMPAR políticas antigas
DROP POLICY IF EXISTS "funcionarios_policy" ON funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "allow_all_login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem gerenciar login de funcionários" ON login_funcionarios;

-- ============================================
-- 3. POLÍTICA CORRETA PARA FUNCIONARIOS
-- ============================================
-- Admin vê/edita APENAS funcionários da SUA empresa

CREATE POLICY "funcionarios_empresa_policy"
ON funcionarios
FOR ALL
TO authenticated
USING (
    -- Pode ver funcionários da própria empresa
    empresa_id = auth.uid()
)
WITH CHECK (
    -- Pode criar/editar funcionários da própria empresa
    empresa_id = auth.uid()
);

-- ============================================
-- 4. POLÍTICA CORRETA PARA LOGIN_FUNCIONARIOS
-- ============================================
-- Admin gerencia logins de funcionários da SUA empresa

CREATE POLICY "login_funcionarios_empresa_policy"
ON login_funcionarios
FOR ALL
TO authenticated
USING (
    -- Pode ver logins de funcionários da própria empresa
    EXISTS (
        SELECT 1 
        FROM funcionarios f
        WHERE f.id = login_funcionarios.funcionario_id
          AND f.empresa_id = auth.uid()
    )
)
WITH CHECK (
    -- Pode criar logins para funcionários da própria empresa
    EXISTS (
        SELECT 1
        FROM funcionarios f
        WHERE f.id = login_funcionarios.funcionario_id
          AND f.empresa_id = auth.uid()
    )
);

-- ============================================
-- 5. VERIFICAR POLÍTICAS CRIADAS
-- ============================================

SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;

-- ============================================
-- 6. TESTAR SE FUNCIONA
-- ============================================

-- Ver apenas funcionários da SUA empresa
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
-- RESULTADO ESPERADO:
-- ============================================
-- ✅ Cada admin vê APENAS funcionários da própria empresa
-- ✅ Admin da empresa A NÃO vê funcionários da empresa B
-- ✅ Privacidade protegida
-- ✅ Sistema funciona corretamente
-- ✅ Maria Silva aparece na lista (para você)
-- ============================================

-- ============================================
-- IMPORTANTE:
-- ============================================
-- auth.uid() retorna o ID da empresa do admin logado
-- Por isso: empresa_id = auth.uid()
-- Isso garante isolamento entre empresas!
-- ============================================
