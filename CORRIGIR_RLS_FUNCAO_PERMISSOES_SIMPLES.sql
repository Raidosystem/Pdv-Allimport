-- ========================================
-- CORREÇÃO: RLS para funcao_permissoes
-- ========================================
-- As permissões não estão sendo salvas porque falta política RLS

-- 1. VERIFICAR políticas atuais
SELECT 
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- 2. DESABILITAR RLS temporariamente
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;

-- 3. REMOVER políticas antigas
DROP POLICY IF EXISTS "funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_all" ON funcao_permissoes;

-- 4. REATIVAR RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR política SIMPLES de SELECT
CREATE POLICY "funcao_permissoes_select_simple" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (
  -- Pode ver permissões das funções da sua empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 6. CRIAR política SIMPLES de INSERT
CREATE POLICY "funcao_permissoes_insert_simple" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Admin da empresa pode adicionar permissões
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 7. CRIAR política SIMPLES de UPDATE
CREATE POLICY "funcao_permissoes_update_simple" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  -- Pode atualizar permissões da sua empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  -- E a empresa continua sendo a mesma
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 8. CRIAR política SIMPLES de DELETE
CREATE POLICY "funcao_permissoes_delete_simple" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  -- Pode deletar permissões da sua empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 9. VERIFICAR políticas criadas
SELECT 
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd, policyname;

-- 10. VERIFICAR se as permissões da função Vendedor existem
SELECT 
  fp.id,
  fp.funcao_id,
  fp.permissao_id,
  fp.empresa_id,
  f.nome as funcao_nome,
  p.recurso,
  p.acao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor';

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Políticas RLS simples sem recursão
-- ✅ Admin pode criar/editar/deletar permissões
-- ✅ Permissões serão salvas corretamente
