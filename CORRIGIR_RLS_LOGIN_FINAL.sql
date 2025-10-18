-- 🔧 SOLUÇÃO DEFINITIVA: RLS login_funcionarios

-- O PROBLEMA:
-- A política de INSERT usa get_funcionario_empresa_id(auth.uid())
-- Mas no frontend, auth.uid() retorna empresa_id diretamente
-- Então a verificação fica: f.empresa_id = get_funcionario_empresa_id(f1726fcf...)
-- E get_funcionario_empresa_id busca:
--   1. Na tabela empresas WHERE id = auth.uid() ✅ 
--   2. OU na tabela funcionarios WHERE user_id = auth.uid() ❌ (user_id pode ser NULL)

-- SOLUÇÃO: Permitir INSERT se o funcionario_id pertence à mesma empresa do admin

-- ✅ 1. Ver função atual
SELECT 
  '📋 FUNÇÃO ATUAL' as status,
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_name = 'get_funcionario_empresa_id';

-- ✅ 2. REMOVER políticas antigas
DROP POLICY IF EXISTS "login_funcionarios_insert_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_select_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_update_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_delete_policy" ON login_funcionarios;

-- ✅ 3. CRIAR POLÍTICAS SIMPLES E DIRETAS

-- SELECT: Ver logins de funcionários da minha empresa
CREATE POLICY "login_funcionarios_select_policy"
ON login_funcionarios
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = login_funcionarios.funcionario_id
    AND (
      -- Opção 1: Empresa diretamente (quando auth.uid() = empresa_id)
      f.empresa_id = auth.uid()
      OR
      -- Opção 2: Via get_funcionario_empresa_id (quando auth.uid() = user_id de funcionario)
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
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
      -- Opção 1: Empresa diretamente (quando auth.uid() = empresa_id)
      f.empresa_id = auth.uid()
      OR
      -- Opção 2: Via get_funcionario_empresa_id (quando auth.uid() = user_id de funcionario)
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
    )
  )
);

-- UPDATE: Atualizar logins de funcionários da minha empresa
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
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
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
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
    )
  )
);

-- DELETE: Deletar logins de funcionários da minha empresa
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
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
    )
  )
);

-- ✅ 4. Verificar políticas criadas
SELECT 
  '✅ POLÍTICAS CRIADAS' as status,
  policyname,
  cmd as acao
FROM pg_policies
WHERE tablename = 'login_funcionarios'
ORDER BY cmd;

-- 🧪 5. TESTAR com os IDs reais

-- Teste 1: Verificar auth.uid()
SELECT 
  '🔍 TESTE 1: auth.uid()' as teste,
  auth.uid() as meu_auth_uid;

-- Teste 2: Verificar se get_funcionario_empresa_id retorna empresa_id
SELECT 
  '🔍 TESTE 2: get_funcionario_empresa_id()' as teste,
  get_funcionario_empresa_id(auth.uid()) as empresa_id_via_funcao;

-- Teste 3: Verificar se Maria Silva tem empresa_id correto
SELECT 
  '🔍 TESTE 3: Maria Silva' as teste,
  f.id,
  f.nome,
  f.empresa_id,
  auth.uid() as meu_auth_uid,
  CASE 
    WHEN f.empresa_id = auth.uid() THEN '✅ MATCH DIRETO'
    WHEN f.empresa_id = get_funcionario_empresa_id(auth.uid()) THEN '✅ MATCH VIA FUNÇÃO'
    ELSE '❌ SEM MATCH'
  END as resultado
FROM funcionarios f
WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- Teste 4: Simular a política EXISTS do INSERT
SELECT 
  '🔍 TESTE 4: Política INSERT' as teste,
  EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa'
    AND (
      f.empresa_id = auth.uid()
      OR
      f.empresa_id = get_funcionario_empresa_id(auth.uid())
    )
  ) as politica_permite_insert;

-- 📊 Resumo final
SELECT 
  '📊 DIAGNÓSTICO FINAL' as status,
  CASE 
    WHEN auth.uid() = 'f1726fcf-d23b-4cca-8079-39314ae56e00' 
    THEN '✅ auth.uid() é empresa_id - usar f.empresa_id = auth.uid()'
    ELSE '⚠️ auth.uid() não é empresa_id - usar get_funcionario_empresa_id()'
  END as conclusao;
