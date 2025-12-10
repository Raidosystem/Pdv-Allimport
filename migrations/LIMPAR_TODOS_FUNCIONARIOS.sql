-- =====================================================
-- LIMPAR FUNCIONÁRIOS DA ASSISTÊNCIA ALL-IMPORT
-- =====================================================
-- Remove apenas os funcionários da Assistência All-Import
-- Mantém funcionários de outras empresas
-- Quando criar o primeiro funcionário na empresa, ele vira Admin automaticamente

DO $$
DECLARE
  v_count INT;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🗑️ Removendo funcionários da Assistência All-Import...';
  
  -- Buscar ID da empresa
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE nome = 'Assistência All-Import'
  ORDER BY created_at ASC
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE NOTICE '⚠️ Empresa Assistência All-Import não encontrada';
    RETURN;
  END IF;
  
  -- Contar funcionários antes
  SELECT COUNT(*) INTO v_count 
  FROM funcionarios 
  WHERE empresa_id = v_empresa_id;
  RAISE NOTICE '  📊 Funcionários da Assistência All-Import antes: %', v_count;
  
  -- Remover funcionários da Assistência All-Import
  DELETE FROM funcionarios
  WHERE empresa_id = v_empresa_id;
  
  -- Verificar depois
  SELECT COUNT(*) INTO v_count 
  FROM funcionarios 
  WHERE empresa_id = v_empresa_id;
  RAISE NOTICE '  📊 Funcionários da Assistência All-Import depois: %', v_count;
  
  -- Total geral
  SELECT COUNT(*) INTO v_count FROM funcionarios;
  RAISE NOTICE '  📊 Total geral de funcionários: %', v_count;
  
  RAISE NOTICE '✅ Funcionários da Assistência All-Import removidos!';
  RAISE NOTICE '🎯 Agora você pode fazer login normal e depois criar funcionários para testar o Admin automático';
END $$;

-- Verificar resultado
SELECT 
  '📊 RESUMO FINAL' as info,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcoes) as total_funcoes;

-- Verificar funções disponíveis por empresa
SELECT 
  '🎭 FUNÇÕES DISPONÍVEIS' as info,
  e.nome as empresa,
  f.nome as funcao,
  f.descricao
FROM empresas e
CROSS JOIN funcoes f
WHERE f.empresa_id = e.id
ORDER BY e.nome, 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Vendedor' THEN 3
    WHEN 'Caixa' THEN 4
    WHEN 'Técnico' THEN 5
  END;
