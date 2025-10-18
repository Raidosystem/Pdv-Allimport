-- 🎯 COPIE E EXECUTE TUDO ABAIXO NO SQL EDITOR

-- PASSO 1: LIMPAR políticas antigas
DROP POLICY IF EXISTS "Admins podem inserir login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem ver login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem atualizar login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem deletar login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_insert_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_select_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_update_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_delete_policy" ON login_funcionarios;

-- PASSO 2: CRIAR políticas novas

-- SELECT: Ver logins dos funcionários da minha empresa
CREATE POLICY "login_funcionarios_select_policy"
ON login_funcionarios FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() LIMIT 1)
      OR f.user_id = auth.uid()
    )
  )
);

-- INSERT: Criar login para funcionários da minha empresa
CREATE POLICY "login_funcionarios_insert_policy"
ON login_funcionarios FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
    )
  )
);

-- UPDATE: Atualizar logins da minha empresa
CREATE POLICY "login_funcionarios_update_policy"
ON login_funcionarios FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
      OR f.user_id = auth.uid()
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
      OR f.user_id = auth.uid()
    )
  )
);

-- DELETE: Deletar logins da minha empresa
CREATE POLICY "login_funcionarios_delete_policy"
ON login_funcionarios FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario') LIMIT 1)
    )
  )
);

-- PASSO 3: Verificar políticas criadas
SELECT '✅ POLÍTICAS INSTALADAS' as status, policyname, cmd as acao
FROM pg_policies
WHERE tablename = 'login_funcionarios'
ORDER BY cmd;
