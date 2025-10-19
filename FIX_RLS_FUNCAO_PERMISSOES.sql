-- 🔒 CORRIGIR RLS DA TABELA funcao_permissoes - VERSÃO 2

-- ⚠️ PROBLEMA:
-- Erro: "new row violates row-level security policy for table funcao_permissoes"
-- O admin não consegue inserir/atualizar permissões das funções

-- ====================================
-- 1. VER POLÍTICAS ATUAIS
-- ====================================
SELECT 
  '📋 POLÍTICAS ATUAIS' as titulo,
  policyname,
  cmd as operacao
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY policyname;

-- ====================================
-- 2. REMOVER POLÍTICAS ANTIGAS
-- ====================================
DROP POLICY IF EXISTS "Admin empresa gerencia permissoes" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuarios visualizam permissoes" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;

-- ====================================
-- 3. CRIAR POLÍTICAS CORRETAS
-- ====================================

-- SELECT: Todos podem ver permissões da sua empresa
CREATE POLICY "rls_funcao_permissoes_select" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (
  empresa_id = auth.uid()
  OR
  empresa_id IN (
    SELECT empresa_id FROM funcionarios WHERE id = auth.uid()
  )
);

-- INSERT: Apenas admin pode inserir
CREATE POLICY "rls_funcao_permissoes_insert" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND tipo_admin = 'admin_empresa'
    AND empresa_id = funcao_permissoes.empresa_id
  )
  OR
  empresa_id = auth.uid()
);

-- UPDATE: Apenas admin pode atualizar
CREATE POLICY "rls_funcao_permissoes_update" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND tipo_admin = 'admin_empresa'
    AND empresa_id = funcao_permissoes.empresa_id
  )
  OR
  empresa_id = auth.uid()
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND tipo_admin = 'admin_empresa'
    AND empresa_id = funcao_permissoes.empresa_id
  )
  OR
  empresa_id = auth.uid()
);

-- DELETE: Apenas admin pode deletar
CREATE POLICY "rls_funcao_permissoes_delete" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE id = auth.uid() 
    AND tipo_admin = 'admin_empresa'
    AND empresa_id = funcao_permissoes.empresa_id
  )
  OR
  empresa_id = auth.uid()
);

-- ====================================
-- 4. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ POLÍTICAS RLS CRIADAS' as status,
  policyname,
  cmd as operacao
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- ====================================
-- 5. VERIFICAR SE RLS ESTÁ ATIVO
-- ====================================
SELECT 
  '🔒 RLS STATUS' as info,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables
WHERE tablename = 'funcao_permissoes';
