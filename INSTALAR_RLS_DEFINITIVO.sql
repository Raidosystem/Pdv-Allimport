-- 🎯 INSTALAR POLÍTICAS RLS DEFINITIVAS - login_funcionarios

-- ⚠️ CONTEXTO:
-- - SQL Editor: auth.uid() = NULL (superusuário)
-- - Frontend Admin: auth.uid() = empresa_id (f1726fcf-d23b-4cca-8079-39314ae56e00)
-- - Frontend Funcionário: auth.uid() = user_id do funcionario

-- ✅ PASSO 1: LIMPAR políticas antigas
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Admins podem inserir login_funcionarios" ON login_funcionarios;
  DROP POLICY IF EXISTS "Admins podem ver login_funcionarios" ON login_funcionarios;
  DROP POLICY IF EXISTS "Admins podem atualizar login_funcionarios" ON login_funcionarios;
  DROP POLICY IF EXISTS "Admins podem deletar login_funcionarios" ON login_funcionarios;
  DROP POLICY IF EXISTS "login_funcionarios_insert_policy" ON login_funcionarios;
  DROP POLICY IF EXISTS "login_funcionarios_select_policy" ON login_funcionarios;
  DROP POLICY IF EXISTS "login_funcionarios_update_policy" ON login_funcionarios;
  DROP POLICY IF EXISTS "login_funcionarios_delete_policy" ON login_funcionarios;
  
  RAISE NOTICE '✅ Políticas antigas removidas';
END $$;

-- ✅ PASSO 2: CRIAR políticas novas e flexíveis

-- SELECT: Ver logins dos funcionários da minha empresa
CREATE POLICY "login_funcionarios_select_policy"
ON login_funcionarios
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      -- Caso 1: Sou admin da empresa (auth.uid() = empresa_id)
      f.empresa_id = auth.uid()
      OR
      -- Caso 2: Sou funcionário (auth.uid() = meu user_id, busco minha empresa)
      f.empresa_id = (
        SELECT empresa_id FROM funcionarios 
        WHERE user_id = auth.uid() 
        LIMIT 1
      )
      OR
      -- Caso 3: Sou o próprio funcionário deste login
      f.user_id = auth.uid()
    )
  )
);

-- INSERT: Criar login para funcionários da minha empresa
CREATE POLICY "login_funcionarios_insert_policy"
ON login_funcionarios
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      -- Caso 1: Sou admin da empresa (auth.uid() = empresa_id)
      f.empresa_id = auth.uid()
      OR
      -- Caso 2: Sou funcionário admin (auth.uid() = meu user_id, busco minha empresa)
      (
        f.empresa_id = (
          SELECT empresa_id FROM funcionarios 
          WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
          LIMIT 1
        )
      )
    )
  )
);

-- UPDATE: Atualizar logins da minha empresa
CREATE POLICY "login_funcionarios_update_policy"
ON login_funcionarios
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR
      f.empresa_id = (
        SELECT empresa_id FROM funcionarios 
        WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
        LIMIT 1
      )
      OR
      -- Posso atualizar meu próprio login
      f.user_id = auth.uid()
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR
      f.empresa_id = (
        SELECT empresa_id FROM funcionarios 
        WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
        LIMIT 1
      )
      OR
      f.user_id = auth.uid()
    )
  )
);

-- DELETE: Deletar logins da minha empresa
CREATE POLICY "login_funcionarios_delete_policy"
ON login_funcionarios
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      f.empresa_id = auth.uid()
      OR
      f.empresa_id = (
        SELECT empresa_id FROM funcionarios 
        WHERE user_id = auth.uid() AND tipo_admin IN ('admin_empresa', 'admin_funcionario')
        LIMIT 1
      )
    )
  )
);

-- ✅ PASSO 3: Verificar políticas criadas
SELECT 
  '✅ POLÍTICAS INSTALADAS' as status,
  policyname,
  cmd as acao,
  'login_funcionarios' as tabela
FROM pg_policies
WHERE tablename = 'login_funcionarios'
ORDER BY cmd;

-- ✅ PASSO 4: Verificar se RLS está ativo
SELECT 
  '🔒 RLS ATIVO?' as status,
  tablename,
  rowsecurity as rls_ativo,
  CASE 
    WHEN rowsecurity THEN '✅ SIM - Políticas serão aplicadas'
    ELSE '❌ NÃO - Tabela desprotegida!'
  END as resultado
FROM pg_tables
WHERE tablename = 'login_funcionarios';

-- 📊 PASSO 5: Resumo final
SELECT 
  '📊 INSTALAÇÃO COMPLETA' as titulo,
  COUNT(*) as total_politicas,
  STRING_AGG(cmd::text, ', ' ORDER BY cmd) as acoes_cobertas
FROM pg_policies
WHERE tablename = 'login_funcionarios';

-- 🎯 PRÓXIMO PASSO
SELECT 
  '🎯 PRÓXIMO PASSO' as titulo,
  'Tente criar um novo funcionário no frontend' as acao,
  'Se der erro 403, copie o erro completo aqui' as se_falhar,
  'Se funcionar, teste pausar/ativar/deletar' as se_sucesso;
