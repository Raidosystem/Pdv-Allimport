-- =====================================================
-- LIMPAR POLÍTICAS DUPLICADAS - funcao_permissoes
-- =====================================================
-- Há 12 políticas duplicadas (3 para cada operação)
-- Vamos remover TODAS e criar apenas 4 (1 por operação)
-- =====================================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE (para limpar)
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "funcao_permissoes_delete" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_valid" ON funcao_permissoes;

DROP POLICY IF EXISTS "funcao_permissoes_insert" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_valid" ON funcao_permissoes;

DROP POLICY IF EXISTS "funcao_permissoes_select" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select_all" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;

DROP POLICY IF EXISTS "funcao_permissoes_update" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_valid" ON funcao_permissoes;

-- Remover qualquer outra política antiga
DROP POLICY IF EXISTS "Usuários podem ver permissões de suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem criar permissões para suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem atualizar permissões de suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem deletar permissões de suas funções" ON funcao_permissoes;

-- 3. REABILITAR RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. CRIAR POLÍTICAS LIMPAS (APENAS 4)
-- =====================================================

-- SELECT: Admin_empresa pode ver permissões de suas funções
CREATE POLICY "funcao_permissoes_select_final" ON funcao_permissoes
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcao_permissoes.funcao_id
    AND e.user_id = auth.uid()
  )
);

-- INSERT: Admin_empresa pode criar permissões para suas funções
CREATE POLICY "funcao_permissoes_insert_final" ON funcao_permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcao_permissoes.funcao_id
    AND e.user_id = auth.uid()
  )
);

-- UPDATE: Admin_empresa pode atualizar permissões de suas funções
CREATE POLICY "funcao_permissoes_update_final" ON funcao_permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcao_permissoes.funcao_id
    AND e.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcao_permissoes.funcao_id
    AND e.user_id = auth.uid()
  )
);

-- DELETE: Admin_empresa pode deletar permissões de suas funções
CREATE POLICY "funcao_permissoes_delete_final" ON funcao_permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcao_permissoes.funcao_id
    AND e.user_id = auth.uid()
  )
);

-- =====================================================
-- 5. VERIFICAÇÃO FINAL
-- =====================================================

-- Contar políticas (deve ser exatamente 4)
SELECT 
  COUNT(*) as total_politicas,
  CASE 
    WHEN COUNT(*) = 4 THEN '✅ PERFEITO! Exatamente 4 políticas'
    WHEN COUNT(*) < 4 THEN '❌ MENOS de 4 políticas'
    ELSE '⚠️ MAIS de 4 políticas (ainda há duplicatas)'
  END as status
FROM pg_policies
WHERE tablename = 'funcao_permissoes';

-- Listar políticas finais
SELECT 
  policyname,
  cmd,
  CASE cmd
    WHEN 'SELECT' THEN '📖 Leitura'
    WHEN 'INSERT' THEN '➕ Criação'
    WHEN 'UPDATE' THEN '✏️ Atualização'
    WHEN 'DELETE' THEN '🗑️ Exclusão'
  END as operacao,
  '✅ Ativa' as status
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd;

-- =====================================================
-- 6. TESTE DE INSERÇÃO
-- =====================================================
DO $$
DECLARE
  v_funcao_id uuid;
  v_permissao_id uuid;
BEGIN
  -- Pegar primeira função do admin atual
  SELECT f.id INTO v_funcao_id
  FROM funcoes f
  JOIN empresas e ON e.id = f.empresa_id
  WHERE e.user_id = auth.uid()
  ORDER BY f.created_at DESC
  LIMIT 1;
  
  -- Pegar primeira permissão
  SELECT id INTO v_permissao_id
  FROM permissoes
  LIMIT 1;
  
  IF v_funcao_id IS NOT NULL AND v_permissao_id IS NOT NULL THEN
    -- Tentar inserir (depois vamos deletar)
    BEGIN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id)
      VALUES (v_funcao_id, v_permissao_id)
      ON CONFLICT DO NOTHING;
      
      RAISE NOTICE '✅ INSERT permitido! Políticas funcionando corretamente';
      
      -- Deletar o teste
      DELETE FROM funcao_permissoes 
      WHERE funcao_id = v_funcao_id AND permissao_id = v_permissao_id;
      
      RAISE NOTICE '🧹 Teste removido';
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ INSERT bloqueado: %', SQLERRM;
    END;
  ELSE
    RAISE NOTICE '⚠️ Não foi possível testar (sem função ou permissão)';
  END IF;
END $$;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ Total: 4 políticas (exatamente)
-- ✅ SELECT, INSERT, UPDATE, DELETE (1 de cada)
-- ✅ INSERT permitido
-- ✅ Sistema pronto para uso
-- =====================================================
