-- =====================================================
-- LIMPAR DUPLICATAS E RECRIAR FUNÇÕES CORRETAS
-- =====================================================

-- 1. REMOVER FUNÇÕES DUPLICADAS E VAZIAS
DELETE FROM funcao_permissoes 
WHERE funcao_id IN (
  SELECT f.id 
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.nome IN ('Administrador', 'Gerente', 'Funcionário', 'Vendedor', 'Caixa')
  GROUP BY f.id, f.nome, f.created_at
  HAVING COUNT(fp.id) = 0 OR f.created_at > (
    SELECT MIN(f2.created_at) 
    FROM funcoes f2 
    WHERE f2.nome = f.nome AND f2.empresa_id = f.empresa_id
  )
);

DELETE FROM funcoes
WHERE id IN (
  SELECT f.id 
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.nome IN ('Administrador', 'Gerente', 'Funcionário', 'Vendedor', 'Caixa')
  GROUP BY f.id, f.nome, f.created_at
  HAVING COUNT(fp.id) = 0 OR f.created_at > (
    SELECT MIN(f2.created_at) 
    FROM funcoes f2 
    WHERE f2.nome = f.nome AND f2.empresa_id = f.empresa_id
  )
);

-- 2. REMOVER A FUNÇÃO "FUNCIONÁRIO" (NÃO FOI PEDIDA)
DELETE FROM funcao_permissoes WHERE funcao_id IN (SELECT id FROM funcoes WHERE nome = 'Funcionário');
DELETE FROM funcoes WHERE nome = 'Funcionário';

-- =====================================================
-- RECRIAR AS 5 FUNÇÕES CORRETAS
-- =====================================================

-- =====================================================
-- 1. ADMINISTRADOR (TODAS AS PERMISSÕES)
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
    -- Limpar permissões existentes
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    -- Criar nova função
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Administrador',
      'Acesso total ao sistema - Gerencia todas as funcionalidades'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

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
-- 2. GERENTE (TODAS AS PERMISSÕES)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_gerente_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Gerente';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Gerente',
      'Acesso total - Gerencia operações, relatórios e equipe'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

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
-- 3. VENDEDOR
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
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Vendedor';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Vendedor',
      'Realiza vendas, gerencia clientes, produtos e OS (sem sangria/suprimento)'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

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
-- 4. CAIXA
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
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Caixa';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Caixa',
      'Opera PDV, realiza vendas, gerencia caixa com sangria/suprimento'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

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
-- 5. TÉCNICO
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
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Técnico';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Atualizar descrição se necessário
    UPDATE funcoes 
    SET descricao = 'Visualiza e edita ordens de serviço e equipamentos'
    WHERE id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Técnico',
      'Visualiza e edita ordens de serviço e equipamentos'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

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
-- FUNÇÃO PRINCIPAL (SOMENTE 5 FUNÇÕES)
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
  v_tecnico_id UUID;
BEGIN
  v_admin_id := criar_funcao_admin_padrao(p_empresa_id);
  v_gerente_id := criar_funcao_gerente_padrao(p_empresa_id);
  v_vendedor_id := criar_funcao_vendedor_padrao(p_empresa_id);
  v_caixa_id := criar_funcao_caixa_padrao(p_empresa_id);
  v_tecnico_id := criar_funcao_tecnico_padrao(p_empresa_id);

  RETURN QUERY
  SELECT 
    f.nome::TEXT as funcao_nome,
    f.id as funcao_id,
    COUNT(fp.permissao_id) as total_permissoes
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.id IN (v_admin_id, v_gerente_id, v_vendedor_id, v_caixa_id, v_tecnico_id)
  GROUP BY f.id, f.nome
  ORDER BY 
    CASE f.nome
      WHEN 'Administrador' THEN 1
      WHEN 'Gerente' THEN 2
      WHEN 'Vendedor' THEN 3
      WHEN 'Caixa' THEN 4
      WHEN 'Técnico' THEN 5
    END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER ATUALIZADO
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
-- APLICAR AGORA
-- =====================================================
DO $$
DECLARE
  v_empresa RECORD;
  v_resultado RECORD;
BEGIN
  FOR v_empresa IN (SELECT id, nome FROM empresas)
  LOOP
    RAISE NOTICE '🏢 Recriando funções para: %', v_empresa.nome;
    
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
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  e.nome as empresa,
  f.nome as funcao,
  f.descricao,
  COUNT(fp.permissao_id) as total_permissoes
FROM empresas e
LEFT JOIN funcoes f ON f.empresa_id = e.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
WHERE f.nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
GROUP BY e.id, e.nome, f.id, f.nome, f.descricao
ORDER BY e.nome, 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Vendedor' THEN 3
    WHEN 'Caixa' THEN 4
    WHEN 'Técnico' THEN 5
  END;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- 
-- ✅ Assistência All-Import | Administrador | 40 permissões
-- ✅ Assistência All-Import | Gerente       | 40 permissões
-- ✅ Assistência All-Import | Vendedor      | 24 permissões
-- ✅ Assistência All-Import | Caixa         | 32 permissões
-- ✅ Assistência All-Import | Técnico       | 4 permissões
--
-- SEM DUPLICATAS! SEM FUNÇÕES COM 0 PERMISSÕES!
-- =====================================================
