-- =====================================================
-- CORRIGIR RLS - TABELA funcao_permissoes
-- =====================================================
-- Permite que admins_empresa possam inserir/deletar
-- permissões para suas funções
-- =====================================================

-- 1. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;

-- 2. Garantir que RLS está habilitado
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS NOVAS
-- =====================================================

-- SELECT: Admins podem ver todas as permissões de suas funções
CREATE POLICY "funcao_permissoes_select_policy" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcoes f
    WHERE f.id = funcao_permissoes.funcao_id
    AND f.empresa_id = auth.uid()
  )
);

-- INSERT: Admins podem inserir permissões em suas funções
CREATE POLICY "funcao_permissoes_insert_policy" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcoes f
    WHERE f.id = funcao_permissoes.funcao_id
    AND f.empresa_id = auth.uid()
  )
);

-- DELETE: Admins podem deletar permissões de suas funções
CREATE POLICY "funcao_permissoes_delete_policy" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcoes f
    WHERE f.id = funcao_permissoes.funcao_id
    AND f.empresa_id = auth.uid()
  )
);

-- UPDATE: Admins podem atualizar permissões de suas funções (se necessário)
CREATE POLICY "funcao_permissoes_update_policy" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcoes f
    WHERE f.id = funcao_permissoes.funcao_id
    AND f.empresa_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcoes f
    WHERE f.id = funcao_permissoes.funcao_id
    AND f.empresa_id = auth.uid()
  )
);

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
SELECT 
  '✅ Políticas RLS configuradas com sucesso!' as status;

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'funcao_permissoes'
ORDER BY policyname;

-- =====================================================
-- TESTE RÁPIDO
-- =====================================================
-- Tenta selecionar as funções do admin atual
SELECT 
  COUNT(*) as total_funcoes,
  '✅ Admin pode ver suas funções' as mensagem
FROM funcoes 
WHERE empresa_id = auth.uid();

-- Verifica se há permissões já cadastradas
SELECT 
  COUNT(*) as total_permissoes,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Há permissões cadastradas'
    ELSE '⚠️ Nenhuma permissão cadastrada ainda'
  END as mensagem
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
WHERE f.empresa_id = auth.uid();

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ 4 políticas criadas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Admin pode ver suas funções (5 funções)
-- ✅ Sistema pronto para inserir permissões
-- =====================================================
