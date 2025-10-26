-- =====================================================
-- CRIAR FUNÇÕES COM PERMISSÕES CORRETAS
-- Usando os recursos reais do banco de dados
-- =====================================================

-- =====================================================
-- 1. ADMINISTRADOR - TODAS AS PERMISSÕES
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
-- 2. GERENTE - TODAS AS PERMISSÕES
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

  -- TODAS as permissões
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
-- Permissões: vendas, clientes, produtos, ordens_servico, relatorios (só leitura em caixa)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_vendedor_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
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
      'Vendas, clientes, produtos e OS (sem sangria/suprimento em caixa)'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- Permissões: vendas (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'vendas' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: clientes (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'clientes' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: produtos (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'produtos' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: ordens_servico (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'ordens_servico' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: relatórios (somente read)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'relatorios' 
    AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: caixa (somente read - SEM sangria/suprimento)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'caixa' 
    AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: configuracoes.impressora (read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'configuracoes.impressora' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: configuracoes.aparencia (read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'configuracoes.aparencia' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. CAIXA
-- Igual a Vendedor MAS com todas as permissões de caixa (incluindo sangria/suprimento)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_caixa_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
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
      'Vendas, caixa completo (com sangria/suprimento), produtos, clientes e OS'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- vendas (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'vendas' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- clientes (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'clientes' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- produtos (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'produtos' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- ordens_servico (create, read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'ordens_servico' 
    AND acao IN ('create', 'read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- relatórios (read)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'relatorios' 
    AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- caixa (TODAS - create, read, update, delete) - COM sangria/suprimento
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'caixa'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: configuracoes.impressora (read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'configuracoes.impressora' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: configuracoes.aparencia (read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'configuracoes.aparencia' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. TÉCNICO
-- Somente ordens_servico (read e update)
-- =====================================================
CREATE OR REPLACE FUNCTION criar_funcao_tecnico_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Técnico';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Técnico',
      'Visualiza e edita ordens de serviço'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- ordens_servico (somente read e update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'ordens_servico' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Permissões: configuracoes.aparencia (somente read, update)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'configuracoes.aparencia' 
    AND acao IN ('read', 'update')
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PRINCIPAL - CRIAR TODAS AS 5 FUNÇÕES
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
  -- Criar as 5 funções
  v_admin_id := criar_funcao_admin_padrao(p_empresa_id);
  v_gerente_id := criar_funcao_gerente_padrao(p_empresa_id);
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
-- LIMPAR E RECRIAR AGORA
-- =====================================================

-- 1. Remover função "Funcionário" (não foi pedida)
DELETE FROM funcao_permissoes WHERE funcao_id IN (SELECT id FROM funcoes WHERE nome = 'Funcionário');
DELETE FROM funcoes WHERE nome = 'Funcionário';

-- 2. Aplicar para todas as empresas
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
  '📊 RESUMO FINAL' as info,
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

-- Ver detalhes das permissões de cada função
SELECT 
  '🔍 DETALHES DAS PERMISSÕES' as info,
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome IN ('Vendedor', 'Caixa', 'Técnico')
ORDER BY f.nome, p.recurso, p.acao;
