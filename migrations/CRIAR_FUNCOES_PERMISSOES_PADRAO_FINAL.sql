-- =====================================================
-- CRIAR FUNÇÕES E PERMISSÕES PADRÃO PARA NOVOS USUÁRIOS
-- =====================================================
-- Script atualizado com as permissões definidas pelo usuário
-- Será executado automaticamente quando um novo usuário comprar o sistema

-- =====================================================
-- 1. FUNÇÃO: ADMINISTRADOR (ACESSO TOTAL)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_admin_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Administrador';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id; -- Já existe, retorna o ID
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Administrador',
    'Acesso total ao sistema - Gerencia todas as funcionalidades'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir TODAS as permissões
  FOR v_permissao IN (SELECT id FROM permissoes)
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. FUNÇÃO: GERENTE (ACESSO TOTAL)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_gerente_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Gerente';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id;
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Gerente',
    'Acesso total - Gerencia operações, relatórios e equipe'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir TODAS as permissões
  FOR v_permissao IN (SELECT id FROM permissoes)
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. FUNÇÃO: FUNCIONÁRIO (CLIENTES + PRODUTOS + OS)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_funcionario_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao_nome TEXT;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Funcionário';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id;
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Funcionário',
    'Gerencia clientes, produtos e ordens de serviço'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir TODAS as permissões de: Clientes, Produtos e Ordem de Serviço
  FOR v_permissao_nome IN (
    SELECT recurso FROM permissoes 
    WHERE recurso LIKE 'vendas.clientes:%'
       OR recurso LIKE 'vendas.produtos:%'
       OR recurso LIKE 'estoque.produtos:%'
       OR recurso LIKE 'assistencia.ordens:%'
       OR recurso LIKE 'assistencia.equipamentos:%'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, p.id, p_empresa_id
    FROM permissoes p
    WHERE p.recurso = v_permissao_nome
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. FUNÇÃO: VENDEDOR
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_vendedor_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'vendas.vendas:read',
    'vendas.vendas:create',
    'vendas.vendas:update',
    'vendas.orcamentos:read',
    'vendas.orcamentos:create',
    'vendas.orcamentos:update',
    'vendas.produtos:read',
    'vendas.produtos:create',
    'vendas.produtos:update',
    'vendas.clientes:read',
    'vendas.clientes:create',
    'vendas.clientes:update',
    'estoque.produtos:read',
    'estoque.produtos:create',
    'estoque.produtos:update',
    'relatorios.financeiro:read',
    'financeiro.caixa:read',
    'pdv.caixa:read',
    'assistencia.ordens:read',
    'assistencia.ordens:create',
    'assistencia.ordens:update',
    'assistencia.equipamentos:read',
    'assistencia.equipamentos:create',
    'assistencia.equipamentos:update'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Vendedor';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id;
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Vendedor',
    'Realiza vendas, gerencia clientes, produtos e OS (sem sangria/suprimento)'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir permissões específicas
  FOREACH v_permissao_nome IN ARRAY v_permissoes
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, p.id, p_empresa_id
    FROM permissoes p
    WHERE p.recurso = v_permissao_nome
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. FUNÇÃO: CAIXA
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_caixa_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'vendas.vendas:read',
    'vendas.vendas:create',
    'vendas.vendas:update',
    'vendas.orcamentos:read',
    'vendas.orcamentos:create',
    'vendas.orcamentos:update',
    'vendas.produtos:read',
    'vendas.produtos:create',
    'vendas.produtos:update',
    'vendas.clientes:read',
    'vendas.clientes:create',
    'vendas.clientes:update',
    'estoque.produtos:read',
    'estoque.produtos:create',
    'estoque.produtos:update',
    'relatorios.financeiro:read',
    'financeiro.caixa:read',
    'financeiro.caixa:create',
    'financeiro.caixa:update',
    'financeiro.caixa:delete',
    'pdv.caixa:read',
    'pdv.caixa:create',
    'pdv.caixa:update',
    'pdv.caixa:delete',
    'pdv.sangria:create',
    'pdv.suprimento:create',
    'assistencia.ordens:read',
    'assistencia.ordens:create',
    'assistencia.ordens:update',
    'assistencia.equipamentos:read',
    'assistencia.equipamentos:create',
    'assistencia.equipamentos:update'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Caixa';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id;
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Caixa',
    'Opera PDV, realiza vendas, gerencia caixa com sangria/suprimento'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir permissões específicas
  FOREACH v_permissao_nome IN ARRAY v_permissoes
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, p.id, p_empresa_id
    FROM permissoes p
    WHERE p.recurso = v_permissao_nome
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. FUNÇÃO: TÉCNICO (SOMENTE OS)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_tecnico_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'assistencia.ordens:read',
    'assistencia.ordens:update',
    'assistencia.equipamentos:read',
    'assistencia.equipamentos:update'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Verificar se já existe
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Técnico';
  
  IF v_funcao_id IS NOT NULL THEN
    RETURN v_funcao_id;
  END IF;

  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Técnico',
    'Visualiza e edita ordens de serviço e equipamentos'
  )
  RETURNING id INTO v_funcao_id;

  -- Atribuir permissões específicas
  FOREACH v_permissao_nome IN ARRAY v_permissoes
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, p.id, p_empresa_id
    FROM permissoes p
    WHERE p.recurso = v_permissao_nome
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. FUNÇÃO PRINCIPAL: CRIAR TODAS AS FUNÇÕES PADRÃO
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
  v_funcionario_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_tecnico_id UUID;
BEGIN
  -- Criar todas as funções
  v_admin_id := criar_funcao_admin_padrao(p_empresa_id);
  v_gerente_id := criar_funcao_gerente_padrao(p_empresa_id);
  v_funcionario_id := criar_funcao_funcionario_padrao(p_empresa_id);
  v_vendedor_id := criar_funcao_vendedor_padrao(p_empresa_id);
  v_caixa_id := criar_funcao_caixa_padrao(p_empresa_id);
  v_tecnico_id := criar_funcao_tecnico_padrao(p_empresa_id);

  -- Retornar resumo
  RETURN QUERY
  SELECT 
    f.nome::TEXT as funcao_nome,
    f.id as funcao_id,
    COUNT(fp.permissao_id) as total_permissoes
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.id IN (v_admin_id, v_gerente_id, v_funcionario_id, v_vendedor_id, v_caixa_id, v_tecnico_id)
  GROUP BY f.id, f.nome
  ORDER BY 
    CASE f.nome
      WHEN 'Administrador' THEN 1
      WHEN 'Gerente' THEN 2
      WHEN 'Funcionário' THEN 3
      WHEN 'Vendedor' THEN 4
      WHEN 'Caixa' THEN 5
      WHEN 'Técnico' THEN 6
    END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. TRIGGER: CRIAR FUNÇÕES AUTOMATICAMENTE
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

-- =====================================================
-- 9. APLICAR NAS EMPRESAS EXISTENTES
-- =====================================================
DO $$
DECLARE
  v_empresa RECORD;
  v_resultado RECORD;
BEGIN
  FOR v_empresa IN (SELECT id, nome FROM empresas)
  LOOP
    RAISE NOTICE '🏢 Criando funções para: %', v_empresa.nome;
    
    FOR v_resultado IN (
      SELECT * FROM criar_funcoes_permissoes_padrao_empresa(v_empresa.id)
    )
    LOOP
      RAISE NOTICE '  ✅ % - % permissões', 
        v_resultado.funcao_nome, 
        v_resultado.total_permissoes;
    END LOOP;
  END LOOP;
END;
$$;

-- =====================================================
-- 10. VERIFICAÇÃO
-- =====================================================
SELECT 
  e.nome as empresa,
  f.nome as funcao,
  f.descricao,
  COUNT(fp.permissao_id) as total_permissoes
FROM empresas e
LEFT JOIN funcoes f ON f.empresa_id = e.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY e.id, e.nome, f.id, f.nome, f.descricao
ORDER BY e.nome, 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Funcionário' THEN 3
    WHEN 'Vendedor' THEN 4
    WHEN 'Caixa' THEN 5
    WHEN 'Técnico' THEN 6
    ELSE 7
  END;

-- =====================================================
-- RESUMO DAS FUNÇÕES CRIADAS:
-- =====================================================
-- 
-- ✅ 1. ADMINISTRADOR - Todas as permissões
-- ✅ 2. GERENTE - Todas as permissões
-- ✅ 3. FUNCIONÁRIO - Clientes + Produtos + OS (ALL)
-- ✅ 4. VENDEDOR - Vendas, Produtos, Clientes, OS, Relatórios (sem sangria/suprimento)
-- ✅ 5. CAIXA - Vendas, Produtos, Clientes, Caixa (com sangria/suprimento), OS, Relatórios
-- ✅ 6. TÉCNICO - Apenas visualizar e editar OS
--
-- =====================================================
