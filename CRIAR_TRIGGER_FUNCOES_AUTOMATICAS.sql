-- =====================================================
-- CRIAR TRIGGER AUTOMÁTICO: FUNÇÕES E PERMISSÕES PADRÃO
-- =====================================================
-- Este script cria um trigger que AUTOMATICAMENTE gera
-- as 6 funções padrão com permissões quando uma nova
-- empresa for criada (quando alguém comprar o sistema)
-- =====================================================

BEGIN;

-- =====================================================
-- FUNÇÃO PRINCIPAL: Criar todas as funções padrão
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcoes_permissoes_padrao_empresa(p_empresa_id UUID)
RETURNS TABLE(
  funcao_nome TEXT,
  funcao_id UUID,
  total_permissoes BIGINT
) AS $$
DECLARE
  v_admin_id UUID;
  v_gerente_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_estoquista_id UUID;
  v_tecnico_id UUID;
  v_count INTEGER;
BEGIN
  RAISE NOTICE '🚀 Criando funções padrão para empresa: %', p_empresa_id;

  -- ===================================================
  -- 1. ADMINISTRADOR - TODAS AS PERMISSÕES
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Administrador', 'Acesso total ao sistema')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_admin_id;
  
  IF v_admin_id IS NULL THEN
    SELECT id INTO v_admin_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Administrador';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_admin_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_admin_id, id, p_empresa_id FROM permissoes;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Administrador: % permissões', v_count;

  -- ===================================================
  -- 2. GERENTE - TUDO EXCETO ADMINISTRAÇÃO
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Gerente', 'Gerenciamento geral exceto administração')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_gerente_id;
  
  IF v_gerente_id IS NULL THEN
    SELECT id INTO v_gerente_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Gerente';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_gerente_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_gerente_id, id, p_empresa_id
  FROM permissoes
  WHERE categoria NOT LIKE 'administracao%' AND recurso NOT LIKE 'administracao%';
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Gerente: % permissões', v_count;

  -- ===================================================
  -- 3. VENDEDOR - VENDAS + CLIENTES + PRODUTOS (LEITURA)
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Vendedor', 'Realiza vendas e gerencia clientes')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_vendedor_id;
  
  IF v_vendedor_id IS NULL THEN
    SELECT id INTO v_vendedor_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Vendedor';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_vendedor_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_vendedor_id, id, p_empresa_id
  FROM permissoes
  WHERE 
    (categoria = 'vendas')
    OR (categoria = 'clientes' AND acao IN ('create', 'read', 'update'))
    OR (categoria = 'produtos' AND acao = 'read')
    OR (recurso = 'caixa' AND acao IN ('open', 'close', 'view'))
    OR (recurso = 'relatorios' AND acao = 'sales')
    OR (recurso = 'appearance')
    OR (recurso = 'print_settings');
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Vendedor: % permissões', v_count;

  -- ===================================================
  -- 4. OPERADOR DE CAIXA - CAIXA + VENDAS BÁSICAS
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Operador de Caixa', 'Opera o caixa e realiza vendas básicas')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_caixa_id;
  
  IF v_caixa_id IS NULL THEN
    SELECT id INTO v_caixa_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Operador de Caixa';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_caixa_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_caixa_id, id, p_empresa_id
  FROM permissoes
  WHERE 
    (categoria = 'vendas' AND acao IN ('create', 'read'))
    OR (recurso = 'caixa')
    OR (categoria = 'clientes' AND acao = 'read')
    OR (categoria = 'produtos' AND acao = 'read')
    OR (recurso = 'print_settings');
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Operador de Caixa: % permissões', v_count;

  -- ===================================================
  -- 5. ESTOQUISTA - PRODUTOS + RELATÓRIOS
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Estoquista', 'Gerencia produtos e estoque')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_estoquista_id;
  
  IF v_estoquista_id IS NULL THEN
    SELECT id INTO v_estoquista_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Estoquista';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_estoquista_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_estoquista_id, id, p_empresa_id
  FROM permissoes
  WHERE 
    (categoria = 'produtos')
    OR (recurso = 'relatorios' AND acao IN ('products', 'inventory'))
    OR (recurso = 'configuracoes' AND acao = 'read');
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Estoquista: % permissões', v_count;

  -- ===================================================
  -- 6. TÉCNICO - ORDENS DE SERVIÇO + CLIENTES
  -- ===================================================
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (p_empresa_id, 'Técnico', 'Gerencia ordens de serviço')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_tecnico_id;
  
  IF v_tecnico_id IS NULL THEN
    SELECT id INTO v_tecnico_id FROM funcoes 
    WHERE empresa_id = p_empresa_id AND nome = 'Técnico';
  END IF;
  
  DELETE FROM funcao_permissoes fp WHERE fp.funcao_id = v_tecnico_id;
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_tecnico_id, id, p_empresa_id
  FROM permissoes
  WHERE 
    (categoria = 'ordens')
    OR (categoria = 'clientes' AND acao IN ('create', 'read', 'update'))
    OR (categoria = 'produtos' AND acao = 'read')
    OR (recurso = 'print_settings');
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE '  ✅ Técnico: % permissões', v_count;

  -- Retornar resumo
  RETURN QUERY
  SELECT 
    f.nome::TEXT as funcao_nome,
    f.id as funcao_id,
    COUNT(fp.permissao_id) as total_permissoes
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.id IN (v_admin_id, v_gerente_id, v_vendedor_id, v_caixa_id, v_estoquista_id, v_tecnico_id)
  GROUP BY f.id, f.nome
  ORDER BY 
    CASE f.nome
      WHEN 'Administrador' THEN 1
      WHEN 'Gerente' THEN 2
      WHEN 'Vendedor' THEN 3
      WHEN 'Operador de Caixa' THEN 4
      WHEN 'Estoquista' THEN 5
      WHEN 'Técnico' THEN 6
    END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER: Criar funções automaticamente
-- =====================================================
CREATE OR REPLACE FUNCTION trigger_criar_funcoes_padrao_nova_empresa()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM criar_funcoes_permissoes_padrao_empresa(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS after_insert_empresa_criar_funcoes ON empresas;

CREATE TRIGGER after_insert_empresa_criar_funcoes
  AFTER INSERT ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION trigger_criar_funcoes_padrao_nova_empresa();

COMMIT;

DO $$
BEGIN
  RAISE NOTICE '✅ Trigger automático criado com sucesso!';
  RAISE NOTICE '🎯 Agora toda nova empresa terá as 6 funções criadas automaticamente!';
END $$;

-- =====================================================
-- APLICAR NAS EMPRESAS EXISTENTES
-- =====================================================
DO $$
DECLARE
  v_empresa RECORD;
  v_resultado RECORD;
BEGIN
  RAISE NOTICE '🏢 Aplicando funções padrão em empresas existentes...';
  
  FOR v_empresa IN (SELECT id, nome FROM empresas ORDER BY created_at)
  LOOP
    RAISE NOTICE '';
    RAISE NOTICE '📍 Empresa: %', v_empresa.nome;
    
    FOR v_resultado IN (
      SELECT * FROM criar_funcoes_permissoes_padrao_empresa(v_empresa.id)
    )
    LOOP
      -- Os notices já são exibidos pela função
    END LOOP;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ CONCLUÍDO! Funções criadas para todas as empresas.';
END;
$$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '📊 RESUMO POR EMPRESA' as info,
  e.nome as empresa,
  f.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM empresas e
LEFT JOIN funcoes f ON f.empresa_id = e.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
WHERE f.nome IN ('Administrador', 'Gerente', 'Vendedor', 'Operador de Caixa', 'Estoquista', 'Técnico')
GROUP BY e.id, e.nome, f.id, f.nome
ORDER BY e.nome, 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Vendedor' THEN 3
    WHEN 'Operador de Caixa' THEN 4
    WHEN 'Estoquista' THEN 5
    WHEN 'Técnico' THEN 6
  END;

-- =====================================================
-- ✅ PRONTO! SISTEMA AUTOMÁTICO ATIVADO!
-- =====================================================
-- 
-- 🎯 O QUE FOI CONFIGURADO:
-- 
-- 1. ✅ Função criar_funcoes_permissoes_padrao_empresa()
--    Cria as 6 funções padrão com permissões para uma empresa
-- 
-- 2. ✅ Trigger after_insert_empresa_criar_funcoes
--    Dispara AUTOMATICAMENTE quando nova empresa é criada
-- 
-- 3. ✅ Aplicado em todas as empresas existentes
--    Todas as empresas atuais já têm as 6 funções
-- 
-- 🚀 FUNCIONAMENTO AUTOMÁTICO:
-- 
-- Quando alguém comprar o sistema:
-- 1. Novo usuário se cadastra
-- 2. Sistema cria registro em 'empresas'
-- 3. TRIGGER dispara AUTOMATICAMENTE
-- 4. 6 funções são criadas com permissões
-- 5. Cliente já pode usar o sistema completo!
-- 
-- 📋 FUNÇÕES CRIADAS AUTOMATICAMENTE:
-- 1. Administrador (72 permissões) - Acesso total
-- 2. Gerente (57 permissões) - Tudo exceto admin
-- 3. Vendedor (16 permissões) - Vendas e clientes
-- 4. Operador de Caixa (10 permissões) - Caixa e vendas básicas
-- 5. Estoquista (12 permissões) - Produtos e estoque
-- 6. Técnico (10 permissões) - Ordens de serviço
-- 
-- =====================================================
