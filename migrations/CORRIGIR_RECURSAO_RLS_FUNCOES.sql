-- ========================================
-- CORREÇÃO: Remover recursão infinita na política RLS de funcoes
-- ========================================

-- 1. VER políticas atuais que causam recursão
SELECT 
  policyname,
  cmd,
  with_check
FROM pg_policies
WHERE tablename = 'funcoes';

-- 2. DESABILITAR RLS temporariamente para funcoes
ALTER TABLE funcoes DISABLE ROW LEVEL SECURITY;

-- 3. REMOVER todas as políticas antigas
DROP POLICY IF EXISTS "funcoes_insert" ON funcoes;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_select" ON funcoes;
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_update" ON funcoes;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_delete" ON funcoes;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes;

-- 4. REATIVAR RLS
ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR política SIMPLES de SELECT (sem recursão)
CREATE POLICY "funcoes_select_simple" ON funcoes
FOR SELECT
TO authenticated
USING (
  -- Usuário pode ver funções da sua empresa
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 6. CRIAR política SIMPLES de INSERT (sem recursão)
CREATE POLICY "funcoes_insert_simple" ON funcoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Admin da empresa pode criar funções
  empresa_id IN (
    SELECT e.id 
    FROM empresas e
    WHERE e.user_id = auth.uid()
  )
);

-- 7. CRIAR política SIMPLES de UPDATE (sem recursão)
CREATE POLICY "funcoes_update_simple" ON funcoes
FOR UPDATE
TO authenticated
USING (
  -- Pode atualizar funções da sua empresa
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

-- 8. CRIAR política SIMPLES de DELETE (sem recursão)
CREATE POLICY "funcoes_delete_simple" ON funcoes
FOR DELETE
TO authenticated
USING (
  -- Pode deletar funções da sua empresa
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
WHERE tablename = 'funcoes'
ORDER BY cmd, policyname;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Políticas RLS simples sem recursão
-- ✅ Admin da empresa pode criar funções
-- ✅ Erro "infinite recursion" não acontecerá mais
