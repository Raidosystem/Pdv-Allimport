-- =====================================================
-- LIMPAR FUNÇÕES DUPLICADAS E ANTIGAS
-- =====================================================
-- Mantém apenas as 5 funções padrão mais recentes (nível 4-10)
-- Remove todas as funções antigas e duplicadas (nível 1)
-- =====================================================

DO $$ 
DECLARE
  v_empresa_id UUID;
  v_deleted_count INTEGER;
BEGIN
  -- Pegar a primeira empresa
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Nenhuma empresa encontrada!';
  END IF;
  
  RAISE NOTICE '✅ Limpando funções da empresa: %', v_empresa_id;
  
  -- =====================================================
  -- PASSO 1: Deletar permissões das funções antigas
  -- =====================================================
  DELETE FROM funcao_permissoes 
  WHERE funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id = v_empresa_id
    AND nivel = 1  -- Funções antigas com nível 1
  );
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE '🧹 Removidas % permissões de funções antigas', v_deleted_count;
  
  -- =====================================================
  -- PASSO 2: Deletar funções antigas (nível 1)
  -- =====================================================
  DELETE FROM funcoes 
  WHERE empresa_id = v_empresa_id
  AND nivel = 1;  -- Remove todas com nível 1 (antigas)
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE '🗑️  Removidas % funções antigas/duplicadas', v_deleted_count;
  
  -- =====================================================
  -- PASSO 3: Deletar funções duplicadas de outras empresas
  -- =====================================================
  DELETE FROM funcao_permissoes 
  WHERE funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id != v_empresa_id
    AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
  );
  
  DELETE FROM funcoes 
  WHERE empresa_id != v_empresa_id
  AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico');
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE '🧼 Removidas % funções de outras empresas', v_deleted_count;
  
  RAISE NOTICE '✨ Limpeza concluída!';
END $$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '🎉 FUNÇÕES MANTIDAS (APENAS AS 5 NOVAS)' as status;

SELECT 
  id,
  nome,
  descricao,
  nivel,
  created_at
FROM funcoes
ORDER BY nivel DESC;

-- Contar total
SELECT 
  COUNT(*) as total_funcoes,
  '✅ Devem ser exatamente 5 funções' as observacao
FROM funcoes;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ Apenas 5 funções restantes:
-- 1. Administrador (nível 10)
-- 2. Gerente (nível 8)
-- 3. Técnico (nível 6)
-- 4. Vendedor (nível 5)
-- 5. Caixa (nível 4)
--
-- ✅ Todas as duplicadas removidas
-- ✅ Todas as antigas (nível 1) removidas
-- ✅ Sistema limpo e organizado!
-- =====================================================
