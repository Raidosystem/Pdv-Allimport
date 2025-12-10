-- =====================================================
-- CORRIGIR PERMISSÕES DA FUNÇÃO "VENDEDOR"
-- =====================================================
-- Remove permissões extras e deixa apenas as corretas

BEGIN;

-- 1. IDENTIFICAR A FUNÇÃO VENDEDOR DA EMPRESA DA JENNIFER
DO $$
DECLARE
  v_empresa_id UUID;
  v_funcao_vendedor_id UUID;
  v_permissoes_removidas INTEGER;
  v_permissoes_corretas INTEGER;
BEGIN
  -- Buscar empresa da Jennifer
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE nome = 'Jennifer'
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não encontrada no banco de dados';
  END IF;
  
  -- Buscar função Vendedor desta empresa
  SELECT id INTO v_funcao_vendedor_id
  FROM funcoes
  WHERE nome = 'Vendedor'
  AND empresa_id = v_empresa_id;
  
  IF v_funcao_vendedor_id IS NULL THEN
    RAISE EXCEPTION 'Função Vendedor não encontrada para a empresa da Jennifer';
  END IF;
  
  RAISE NOTICE '?? Empresa ID: %', v_empresa_id;
  RAISE NOTICE '?? Função Vendedor ID: %', v_funcao_vendedor_id;
  
  -- PASSO 1: REMOVER TODAS AS PERMISSÕES ATUAIS
  DELETE FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  GET DIAGNOSTICS v_permissoes_removidas = ROW_COUNT;
  RAISE NOTICE '??? Permissões removidas: %', v_permissoes_removidas;
  
  -- PASSO 2: ADICIONAR APENAS AS PERMISSÕES CORRETAS
  
  -- Vendas (create, read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'vendas' 
  AND p.acao IN ('create', 'read', 'update')
  ON CONFLICT DO NOTHING;
  
  -- Clientes (create, read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'clientes' 
  AND p.acao IN ('create', 'read', 'update')
  ON CONFLICT DO NOTHING;
  
  -- Produtos (create, read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'produtos' 
  AND p.acao IN ('create', 'read', 'update')
  ON CONFLICT DO NOTHING;
  
  -- Ordens de Serviço (create, read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'ordens' 
  AND p.acao IN ('create', 'read', 'update')
  ON CONFLICT DO NOTHING;
  
  -- Relatórios (somente read)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'relatorios' 
  AND p.acao = 'read'
  ON CONFLICT DO NOTHING;
  
  -- Caixa (somente read - SEM sangria/suprimento)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'caixa' 
  AND p.acao = 'read'
  ON CONFLICT DO NOTHING;
  
  -- Configurações - Impressora (read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'configuracoes' 
  AND p.acao IN ('print_settings')
  ON CONFLICT DO NOTHING;
  
  -- Configurações - Aparência (read, update)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'configuracoes' 
  AND p.acao IN ('appearance')
  ON CONFLICT DO NOTHING;
  
  -- Contar permissões adicionadas
  SELECT COUNT(*) INTO v_permissoes_corretas
  FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '? Permissões corretas adicionadas: %', v_permissoes_corretas;
  RAISE NOTICE '';
  RAISE NOTICE '?? CORREÇÃO CONCLUÍDA!';
  RAISE NOTICE '   Antes: % permissões', v_permissoes_removidas;
  RAISE NOTICE '   Depois: % permissões', v_permissoes_corretas;
  
END $$;

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Ver permissões da função Vendedor
SELECT 
  '?? PERMISSÕES DA FUNÇÃO VENDEDOR (APÓS CORREÇÃO)' as info,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.nome = 'Vendedor'
AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1)
ORDER BY p.recurso, p.acao;

-- Resumo
SELECT 
  '?? RESUMO FINAL' as info,
  COUNT(*) as total_permissoes,
  STRING_AGG(DISTINCT p.recurso, ', ' ORDER BY p.recurso) as recursos
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.nome = 'Vendedor'
AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1);

-- =====================================================
-- INSTRUÇÕES
-- =====================================================
-- 
-- ? APÓS EXECUTAR ESTE SCRIPT:
-- 
-- 1. Volte ao sistema e faça LOGOUT da Jennifer
-- 2. Faça LOGIN novamente
-- 3. O sistema irá recarregar as permissões automaticamente
-- 4. Agora a Jennifer terá apenas as permissões corretas:
--    - Vendas (criar, visualizar, editar)
--    - Clientes (criar, visualizar, editar)
--    - Produtos (criar, visualizar, editar)
--    - OS (criar, visualizar, editar)
--    - Relatórios (apenas visualizar)
--    - Caixa (apenas visualizar - SEM sangria/suprimento)
--    - Configurações de impressora
--    - Configurações de aparência
--
-- ? Total esperado: 21 permissões
-- 
-- =====================================================
