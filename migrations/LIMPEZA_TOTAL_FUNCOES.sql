-- =====================================================
-- LIMPEZA TOTAL - MANTER APENAS AS 5 FUNÇÕES NOVAS
-- =====================================================
-- Remove TODAS as funções antigas
-- Mantém APENAS as 5 com níveis 4, 5, 6, 8, 10
-- =====================================================

DO $$ 
DECLARE
  v_empresa_id UUID;
  v_deleted_count INTEGER;
  v_funcoes_novas UUID[];
BEGIN
  -- Pegar a primeira empresa
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Nenhuma empresa encontrada!';
  END IF;
  
  RAISE NOTICE '✅ Iniciando limpeza total...';
  
  -- =====================================================
  -- IDENTIFICAR AS 5 FUNÇÕES NOVAS PARA MANTER
  -- =====================================================
  SELECT ARRAY_AGG(id) INTO v_funcoes_novas
  FROM (
    SELECT id
    FROM funcoes 
    WHERE empresa_id = v_empresa_id
    AND nivel IN (4, 5, 6, 8, 10)  -- Caixa, Vendedor, Técnico, Gerente, Administrador
    ORDER BY created_at DESC
    LIMIT 5
  ) AS funcoes_recentes;
  
  RAISE NOTICE '✅ Identificadas % funções para manter', ARRAY_LENGTH(v_funcoes_novas, 1);
  
  -- =====================================================
  -- DELETAR PERMISSÕES DAS FUNÇÕES QUE SERÃO REMOVIDAS
  -- =====================================================
  DELETE FROM funcao_permissoes 
  WHERE funcao_id NOT IN (SELECT UNNEST(v_funcoes_novas));
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE '🧹 Removidas % permissões antigas', v_deleted_count;
  
  -- =====================================================
  -- DELETAR TODAS AS FUNÇÕES EXCETO AS 5 NOVAS
  -- =====================================================
  DELETE FROM funcoes 
  WHERE id NOT IN (SELECT UNNEST(v_funcoes_novas));
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  RAISE NOTICE '🗑️  Removidas % funções antigas', v_deleted_count;
  
  RAISE NOTICE '✨ Limpeza total concluída!';
END $$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '🎉 RESULTADO DA LIMPEZA' as titulo;

SELECT 
  id,
  nome,
  nivel,
  created_at,
  CASE 
    WHEN nivel = 10 THEN '👑 Administrador'
    WHEN nivel = 8 THEN '📊 Gerente'
    WHEN nivel = 6 THEN '🔧 Técnico'
    WHEN nivel = 5 THEN '🛒 Vendedor'
    WHEN nivel = 4 THEN '💰 Caixa'
    ELSE '❓ Outro'
  END as funcao
FROM funcoes
ORDER BY nivel DESC;

-- Contar total
SELECT 
  COUNT(*) as total_funcoes,
  CASE 
    WHEN COUNT(*) = 5 THEN '✅ PERFEITO! Exatamente 5 funções'
    WHEN COUNT(*) < 5 THEN '⚠️ MENOS de 5 funções'
    ELSE '❌ MAIS de 5 funções'
  END as status
FROM funcoes;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ Total: 5 funções
-- ✅ Níveis: 4, 5, 6, 8, 10
-- ✅ Nomes: Caixa, Vendedor, Técnico, Gerente, Administrador
-- ✅ Sistema limpo e organizado!
-- =====================================================
