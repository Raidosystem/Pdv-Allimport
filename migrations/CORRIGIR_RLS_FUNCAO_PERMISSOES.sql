-- ============================================
-- CORRIGIR POLÍTICAS RLS - funcao_permissoes
-- ============================================
-- Problema: Políticas comparam empresa_id com auth.uid() (que é user_id)
-- Solução: Usar a função jwt_empresa_id() ou verificar através de funcionarios

-- 1. REMOVER POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Usuários podem ver permissões de suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem criar permissões para suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem atualizar permissões de suas funções" ON funcao_permissoes;
DROP POLICY IF EXISTS "Usuários podem deletar permissões de suas funções" ON funcao_permissoes;

-- 2. CRIAR NOVAS POLÍTICAS CORRETAS

-- SELECT: Permitir visualizar permissões das funções da própria empresa
CREATE POLICY "funcao_permissoes_select" ON funcao_permissoes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- INSERT: Permitir inserir permissões nas funções da própria empresa
CREATE POLICY "funcao_permissoes_insert" ON funcao_permissoes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 
      FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- UPDATE: Permitir atualizar permissões das funções da própria empresa
CREATE POLICY "funcao_permissoes_update" ON funcao_permissoes
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 
      FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- DELETE: Permitir deletar permissões das funções da própria empresa
CREATE POLICY "funcao_permissoes_delete" ON funcao_permissoes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 
      FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- 3. VERIFICAR NOVAS POLÍTICAS
SELECT 
  policyname,
  cmd,
  CASE cmd
    WHEN 'SELECT' THEN 'Leitura'
    WHEN 'INSERT' THEN 'Criação'
    WHEN 'UPDATE' THEN 'Atualização'
    WHEN 'DELETE' THEN 'Exclusão'
  END as operacao,
  '✅ Corrigida' as status
FROM pg_policies
WHERE tablename = 'funcao_permissoes'
ORDER BY cmd;

-- 4. TESTAR INSERT NOVAMENTE
DO $$
DECLARE
  v_funcao_id uuid;
  v_permissao_id uuid;
  v_count_before int;
  v_count_after int;
BEGIN
  SELECT COUNT(*) INTO v_count_before FROM funcao_permissoes;
  
  RAISE NOTICE '📊 Permissões antes: %', v_count_before;
  
  -- Pegar primeira função
  SELECT id INTO v_funcao_id 
  FROM funcoes 
  WHERE nome = 'Administrador' 
  LIMIT 1;
  
  -- Pegar primeira permissão não atribuída
  SELECT p.id INTO v_permissao_id 
  FROM permissoes p
  WHERE NOT EXISTS (
    SELECT 1 FROM funcao_permissoes fp 
    WHERE fp.funcao_id = v_funcao_id AND fp.permissao_id = p.id
  )
  LIMIT 1;
  
  IF v_permissao_id IS NOT NULL THEN
    BEGIN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id)
      VALUES (v_funcao_id, v_permissao_id);
      
      SELECT COUNT(*) INTO v_count_after FROM funcao_permissoes;
      
      RAISE NOTICE '✅ INSERT bem sucedido!';
      RAISE NOTICE '📊 Permissões depois: %', v_count_after;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro no INSERT: %', SQLERRM;
    END;
  ELSE
    RAISE NOTICE '⚠️  Todas as permissões já estão atribuídas';
  END IF;
END $$;

-- 5. MENSAGEM FINAL
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Políticas RLS corrigidas!';
  RAISE NOTICE '📝 Agora execute CRIAR_FUNCOES_PERMISSOES_DIRETO.sql novamente';
  RAISE NOTICE '   (especificamente a parte 6 - ATRIBUIR PERMISSÕES)';
END $$;
