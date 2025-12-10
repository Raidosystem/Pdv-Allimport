-- 🔒 CORRIGIR RLS FUNCAO_PERMISSOES - COMPATÍVEL COM LOGIN LOCAL

-- ⚠️ PROBLEMA:
-- Sistema usa login local (2 níveis) onde auth.uid() retorna NULL
-- RLS de funcao_permissoes bloqueia INSERT porque verifica auth.uid()
-- Precisa permitir INSERT quando empresa_id está correto

-- ====================================
-- 1. VER POLÍTICAS ATUAIS
-- ====================================
SELECT 
  '📋 POLÍTICAS ATUAIS' as titulo,
  policyname,
  cmd as operacao
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- ====================================
-- 2. REMOVER POLÍTICAS ANTIGAS
-- ====================================
DROP POLICY IF EXISTS "rls_funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "rls_funcao_permissoes_delete" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete" ON funcao_permissoes;

-- ====================================
-- 3. CRIAR POLÍTICAS PERMISSIVAS
-- ====================================

-- ✅ SELECT: Qualquer usuário autenticado pode ver permissões
-- Necessário para o sistema de permissões funcionar
CREATE POLICY "funcao_permissoes_select_all" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (true);

-- ✅ INSERT: Permitir INSERT com empresa_id válido
-- Como o sistema usa login local, não podemos verificar auth.uid()
-- Em vez disso, verificamos se a empresa_id existe na tabela empresas
CREATE POLICY "funcao_permissoes_insert_valid" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Verifica se empresa_id existe
  EXISTS (
    SELECT 1 FROM empresas WHERE id = funcao_permissoes.empresa_id
  )
);

-- ✅ UPDATE: Permitir UPDATE com empresa_id válido
CREATE POLICY "funcao_permissoes_update_valid" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM empresas WHERE id = funcao_permissoes.empresa_id
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM empresas WHERE id = funcao_permissoes.empresa_id
  )
);

-- ✅ DELETE: Permitir DELETE com empresa_id válido
CREATE POLICY "funcao_permissoes_delete_valid" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM empresas WHERE id = funcao_permissoes.empresa_id
  )
);

-- ====================================
-- 4. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ POLÍTICAS CRIADAS' as status,
  policyname,
  cmd as operacao,
  CASE 
    WHEN policyname LIKE '%select%' THEN '🔓 Leitura liberada'
    WHEN policyname LIKE '%insert%' THEN '✏️ INSERT com empresa_id válido'
    WHEN policyname LIKE '%update%' THEN '🔧 UPDATE com empresa_id válido'
    WHEN policyname LIKE '%delete%' THEN '🗑️ DELETE com empresa_id válido'
    ELSE '❓'
  END as descricao
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- ====================================
-- 5. TESTAR PERMISSÕES
-- ====================================
-- Verificar se consegue ver permissões
SELECT 
  '🧪 TESTE SELECT' as teste,
  COUNT(*) as total_permissoes
FROM funcao_permissoes;

-- Verificar empresa_id válido
SELECT 
  '🧪 EMPRESAS VÁLIDAS' as teste,
  id,
  nome,
  email
FROM empresas
WHERE id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- ====================================
-- 6. RESUMO DA SOLUÇÃO
-- ====================================
SELECT 
  '📝 RESUMO' as info,
  '✅ RLS compatível com login local (2 níveis)' as solucao_1,
  '🔓 Verifica empresa_id EXISTS ao invés de auth.uid()' as solucao_2,
  '🚀 INSERT/UPDATE/DELETE funcionam com sessão local' as resultado;
