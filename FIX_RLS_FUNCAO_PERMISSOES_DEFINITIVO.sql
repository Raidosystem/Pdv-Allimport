-- 🔒 CORRIGIR RLS funcao_permissoes - VERSÃO DEFINITIVA

-- ⚠️ PROBLEMA:
-- As políticas verificam funcionarios.empresa_id mas o user logado
-- usa empresas.id diretamente, então não encontra match

-- ====================================
-- 1. REMOVER TODAS AS POLÍTICAS ANTIGAS
-- ====================================
DROP POLICY IF EXISTS "rls_funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_delete" ON funcao_permissoes;

-- ====================================
-- 2. CRIAR POLÍTICAS CORRETAS
-- ====================================

-- SELECT: Ver permissões da sua empresa
CREATE POLICY "funcao_permissoes_select_policy" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (
  -- Permite se empresa_id é do usuário logado OU se é funcionário dessa empresa
  empresa_id = auth.uid()
  OR
  empresa_id IN (
    SELECT empresa_id FROM funcionarios WHERE id = auth.uid()
  )
);

-- INSERT: Inserir permissões (admin da empresa)
CREATE POLICY "funcao_permissoes_insert_policy" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Permite se:
  -- 1. empresa_id é o próprio auth.uid() (empresas.id)
  -- 2. OU é funcionário admin dessa empresa
  empresa_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND empresa_id = funcao_permissoes.empresa_id
    AND tipo_admin = 'admin_empresa'
  )
);

-- UPDATE: Atualizar permissões
CREATE POLICY "funcao_permissoes_update_policy" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  empresa_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND empresa_id = funcao_permissoes.empresa_id
    AND tipo_admin = 'admin_empresa'
  )
)
WITH CHECK (
  empresa_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND empresa_id = funcao_permissoes.empresa_id
    AND tipo_admin = 'admin_empresa'
  )
);

-- DELETE: Deletar permissões
CREATE POLICY "funcao_permissoes_delete_policy" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  empresa_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND empresa_id = funcao_permissoes.empresa_id
    AND tipo_admin = 'admin_empresa'
  )
);

-- ====================================
-- 3. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ POLÍTICAS RLS ATUALIZADAS' as status,
  policyname,
  cmd as operacao
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- ====================================
-- 4. TESTE COM SEU USER_ID
-- ====================================

-- Teste se consegue ver permissões (deve retornar dados)
SELECT 
  '🧪 TESTE SELECT' as teste,
  COUNT(*) as total_permissoes_visiveis
FROM funcao_permissoes
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- Ver estrutura
SELECT 
  '📋 ESTRUTURA' as info,
  'Agora empresa_id = auth.uid() funciona corretamente' as explicacao;
