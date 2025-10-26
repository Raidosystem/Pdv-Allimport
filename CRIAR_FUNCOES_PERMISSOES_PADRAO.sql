-- =====================================================
-- CRIAR FUNÇÕES E PERMISSÕES PADRÃO PARA NOVOS USUÁRIOS
-- =====================================================
-- Este script será executado automaticamente quando um novo usuário comprar o sistema
-- Cria funções básicas (Admin, Vendedor, Caixa) com permissões apropriadas

-- =====================================================
-- 1. FUNÇÃO: ADMINISTRADOR (ACESSO TOTAL)
-- =====================================================
-- Essa função terá todas as permissões ativas
CREATE OR REPLACE FUNCTION criar_funcao_admin_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  -- Criar função Administrador
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
-- 2. FUNÇÃO: VENDEDOR (VENDAS + CLIENTES + PRODUTOS)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_vendedor_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'vendas.vendas:read',
    'vendas.vendas:create',
    'vendas.orcamentos:read',
    'vendas.orcamentos:create',
    'vendas.clientes:read',
    'vendas.clientes:create',
    'vendas.clientes:update',
    'vendas.produtos:read',
    'estoque.produtos:read',
    'pdv.vendas:read',
    'pdv.vendas:create'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Criar função Vendedor
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Vendedor',
    'Realiza vendas, gerencia clientes e consulta produtos'
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
-- 3. FUNÇÃO: CAIXA (PDV + VENDAS BÁSICAS)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_caixa_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'pdv.vendas:read',
    'pdv.vendas:create',
    'pdv.caixa:read',
    'vendas.vendas:read',
    'vendas.clientes:read',
    'vendas.produtos:read',
    'estoque.produtos:read'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Criar função Caixa
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Caixa',
    'Opera o PDV, realiza vendas e gerencia caixa'
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
-- 4. FUNÇÃO: GERENTE (ADMINISTRAÇÃO + RELATÓRIOS)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_gerente_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissoes TEXT[] := ARRAY[
    'vendas.vendas:read',
    'vendas.vendas:create',
    'vendas.vendas:update',
    'vendas.vendas:delete',
    'vendas.orcamentos:read',
    'vendas.orcamentos:create',
    'vendas.orcamentos:update',
    'vendas.clientes:read',
    'vendas.clientes:create',
    'vendas.clientes:update',
    'vendas.produtos:read',
    'vendas.produtos:create',
    'vendas.produtos:update',
    'estoque.produtos:read',
    'estoque.produtos:update',
    'estoque.movimentacoes:read',
    'financeiro.contas:read',
    'financeiro.caixa:read',
    'relatorios.vendas:read',
    'relatorios.financeiro:read',
    'relatorios.estoque:read',
    'pdv.vendas:read',
    'pdv.vendas:create',
    'pdv.caixa:read'
  ];
  v_permissao_nome TEXT;
BEGIN
  -- Criar função Gerente
  INSERT INTO funcoes (empresa_id, nome, descricao)
  VALUES (
    p_empresa_id,
    'Gerente',
    'Gerencia operações, relatórios e equipe'
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
-- 5. FUNÇÃO PRINCIPAL: CRIAR TODAS AS FUNÇÕES PADRÃO
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcoes_permissoes_padrao_empresa(p_empresa_id UUID)
RETURNS TABLE(
  funcao_nome TEXT,
  funcao_id UUID,
  total_permissoes BIGINT
) AS $$
DECLARE
  v_admin_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_gerente_id UUID;
BEGIN
  -- Criar Administrador
  v_admin_id := criar_funcao_admin_padrao(p_empresa_id);
  
  -- Criar Vendedor
  v_vendedor_id := criar_funcao_vendedor_padrao(p_empresa_id);
  
  -- Criar Caixa
  v_caixa_id := criar_funcao_caixa_padrao(p_empresa_id);
  
  -- Criar Gerente
  v_gerente_id := criar_funcao_gerente_padrao(p_empresa_id);

  -- Retornar resumo
  RETURN QUERY
  SELECT 
    f.nome::TEXT as funcao_nome,
    f.id as funcao_id,
    COUNT(fp.permissao_id) as total_permissoes
  FROM funcoes f
  LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
  WHERE f.id IN (v_admin_id, v_vendedor_id, v_caixa_id, v_gerente_id)
  GROUP BY f.id, f.nome
  ORDER BY 
    CASE f.nome
      WHEN 'Administrador' THEN 1
      WHEN 'Gerente' THEN 2
      WHEN 'Vendedor' THEN 3
      WHEN 'Caixa' THEN 4
    END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. TRIGGER: CRIAR FUNÇÕES AUTOMATICAMENTE
-- =====================================================
-- Quando uma nova empresa for criada, criar as funções padrão automaticamente
CREATE OR REPLACE FUNCTION trigger_criar_funcoes_padrao_nova_empresa()
RETURNS TRIGGER AS $$
BEGIN
  -- Criar funções padrão para a nova empresa
  PERFORM criar_funcoes_permissoes_padrao_empresa(NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger existente se houver
DROP TRIGGER IF EXISTS after_insert_empresa_criar_funcoes ON empresas;

-- Criar novo trigger
CREATE TRIGGER after_insert_empresa_criar_funcoes
  AFTER INSERT ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION trigger_criar_funcoes_padrao_nova_empresa();

-- =====================================================
-- 7. TESTE E APLICAÇÃO
-- =====================================================

-- Para aplicar nas empresas existentes (EXECUTAR AGORA):
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
-- 8. VERIFICAÇÃO
-- =====================================================

-- Ver todas as funções criadas por empresa
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
    WHEN 'Vendedor' THEN 3
    WHEN 'Caixa' THEN 4
    ELSE 5
  END;

-- =====================================================
-- RESUMO DO QUE FOI CRIADO:
-- =====================================================
-- 
-- ✅ FUNÇÕES PADRÃO:
-- 1. Administrador - Todas as permissões (35+)
-- 2. Gerente - Permissões administrativas e relatórios (24)
-- 3. Vendedor - Vendas, clientes e produtos (11)
-- 4. Caixa - PDV e vendas básicas (7)
--
-- ✅ TRIGGER AUTOMÁTICO:
-- Quando um novo usuário comprar o sistema e criar uma empresa,
-- as 4 funções padrão serão criadas automaticamente com suas permissões.
--
-- ✅ CUSTOMIZAÇÃO:
-- Após a criação, o usuário pode:
-- - Editar as funções existentes
-- - Criar novas funções
-- - Adicionar/remover permissões
-- - Deletar funções (exceto se estiverem em uso)
--
-- =====================================================
