-- 🔧 CORRIGIR RLS da tabela login_funcionarios

-- ✅ 1. Ver políticas atuais
SELECT 
  '📋 POLÍTICAS ATUAIS' as status,
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

-- ✅ 2. Verificar se RLS está ativo
SELECT 
  '🔍 RLS ATIVO?' as status,
  schemaname,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables
WHERE tablename = 'login_funcionarios';

-- 🔧 3. REMOVER políticas antigas que podem estar bloqueando
DROP POLICY IF EXISTS "Admins podem inserir login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem ver login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem atualizar login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "Admins podem deletar login_funcionarios" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_insert_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_select_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_update_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_delete_policy" ON login_funcionarios;

-- ✅ 4. CRIAR políticas CORRETAS usando get_funcionario_empresa_id()

-- SELECT: Admin pode ver login_funcionarios da sua empresa
CREATE POLICY "login_funcionarios_select_policy"
ON login_funcionarios
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  )
);

-- INSERT: Admin pode criar login_funcionarios para funcionários da sua empresa
CREATE POLICY "login_funcionarios_insert_policy"
ON login_funcionarios
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  )
);

-- UPDATE: Admin pode atualizar login_funcionarios da sua empresa
CREATE POLICY "login_funcionarios_update_policy"
ON login_funcionarios
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  )
);

-- DELETE: Admin pode deletar login_funcionarios da sua empresa
CREATE POLICY "login_funcionarios_delete_policy"
ON login_funcionarios
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  )
);

-- ✅ 5. Verificar políticas criadas
SELECT 
  '✅ POLÍTICAS NOVAS' as status,
  policyname,
  cmd,
  CASE 
    WHEN cmd = 'SELECT' THEN 'Ver'
    WHEN cmd = 'INSERT' THEN 'Criar'
    WHEN cmd = 'UPDATE' THEN 'Editar'
    WHEN cmd = 'DELETE' THEN 'Deletar'
  END as acao
FROM pg_policies
WHERE tablename = 'login_funcionarios'
ORDER BY cmd;

-- 🧪 6. TESTAR INSERT como usuário autenticado
-- Este teste simula o que o frontend está fazendo

-- Primeiro, verificar empresa_id do auth.uid() atual
SELECT 
  '🔍 TESTE 1: Verificar empresa_id' as teste,
  auth.uid() as auth_user_id,
  get_funcionario_empresa_id(auth.uid()) as empresa_id_retornado;

-- Segundo, verificar se Maria Silva existe e tem empresa_id correto
SELECT 
  '🔍 TESTE 2: Maria Silva' as teste,
  f.id as maria_id,
  f.empresa_id as maria_empresa_id,
  get_funcionario_empresa_id(auth.uid()) as empresa_id_esperado,
  CASE 
    WHEN f.empresa_id = get_funcionario_empresa_id(auth.uid()) THEN '✅ MATCH'
    ELSE '❌ MISMATCH'
  END as status
FROM funcionarios f
WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- Terceiro, testar se a política permite verificar funcionário
SELECT 
  '🔍 TESTE 3: Política EXISTS' as teste,
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa'
    AND f.empresa_id = get_funcionario_empresa_id(auth.uid())
  ) as politica_permite;

-- ⚠️ IMPORTANTE: Se os testes acima passarem, o problema pode ser:
-- 1. Frontend está usando auth.uid() errado
-- 2. get_funcionario_empresa_id() retorna valor diferente no contexto do frontend

SELECT '📊 RESUMO' as status,
  'Se TESTE 1, 2 e 3 passaram (✅), o problema é no frontend' as diagnostico,
  'Se algum teste falhou (❌), o problema é no banco de dados' as diagnostico2;
