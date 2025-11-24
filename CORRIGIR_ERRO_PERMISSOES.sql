-- =============================================
-- CORREÇÃO: Erro de Permissões - Funcionário não encontrado
-- =============================================
-- Problema: Usuário não tem registro na tabela funcionarios
-- Solução: Criar funcionário e configurar RLS adequado
-- =============================================

-- 1. Verificar se o funcionário existe
DO $$
DECLARE
  v_user_email text := 'assistenciaallimport10@gmail.com';
  v_user_id uuid;
  v_empresa_id uuid;
  v_funcionario_exists boolean;
BEGIN
  -- Buscar user_id do auth
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_user_email;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário % não encontrado no auth.users', v_user_email;
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ Usuário encontrado: %', v_user_id;
  
  -- Buscar empresa do usuário
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = v_user_id;
  
  IF v_empresa_id IS NULL THEN
    RAISE NOTICE '❌ Empresa não encontrada para o usuário';
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ Empresa encontrada: %', v_empresa_id;
  
  -- Verificar se funcionário já existe
  SELECT EXISTS(
    SELECT 1 FROM funcionarios 
    WHERE email = v_user_email OR user_id = v_user_id
  ) INTO v_funcionario_exists;
  
  IF v_funcionario_exists THEN
    RAISE NOTICE '✅ Funcionário já existe no banco';
  ELSE
    RAISE NOTICE '⚠️  Funcionário não existe - será criado';
    
    -- Criar funcionário
    INSERT INTO funcionarios (
      nome,
      email,
      user_id,
      empresa_id,
      tipo_admin,
      usuario_ativo,
      senha_definida,
      primeiro_acesso
    ) VALUES (
      'Admin Assistência Allimport',
      v_user_email,
      v_user_id,
      v_empresa_id,
      'admin_empresa',
      true,
      true,
      false
    );
    
    RAISE NOTICE '✅ Funcionário criado com sucesso!';
  END IF;
END $$;

-- 2. Corrigir RLS da tabela funcionarios
DROP POLICY IF EXISTS "Usuários podem ver seus funcionários" ON funcionarios;
DROP POLICY IF EXISTS "Funcionarios isolados por empresa" ON funcionarios;

-- Política para SELECT
CREATE POLICY "Usuários podem ver funcionários da empresa"
ON funcionarios
FOR SELECT
USING (
  -- Pode ver se:
  -- 1. É o próprio funcionário
  user_id = auth.uid()
  OR
  -- 2. Pertence à mesma empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- Política para INSERT (admins podem criar funcionários)
DROP POLICY IF EXISTS "Admins podem criar funcionários" ON funcionarios;

CREATE POLICY "Admins podem criar funcionários"
ON funcionarios
FOR INSERT
WITH CHECK (
  -- Só pode inserir funcionários na sua própria empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- Política para UPDATE
DROP POLICY IF EXISTS "Admins podem atualizar funcionários" ON funcionarios;

CREATE POLICY "Admins podem atualizar funcionários"
ON funcionarios
FOR UPDATE
USING (
  -- Pode atualizar se é da mesma empresa OU é ele mesmo
  user_id = auth.uid()
  OR
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  -- Não pode mudar para outra empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 3. Garantir que RLS está habilitado
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

-- =============================================
-- VERIFICAÇÃO
-- =============================================
SELECT 
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.usuario_ativo,
  f.empresa_id,
  e.nome as empresa_nome
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE f.email = 'assistenciaallimport10@gmail.com';

-- =============================================
-- LOG FINAL
-- =============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Correção de permissões concluída!';
  RAISE NOTICE '';
  RAISE NOTICE 'Execute a query de VERIFICAÇÃO acima para confirmar.';
END $$;
