-- =====================================================
-- APLICAR SISTEMA DE PERMISSÕES COMPLETO
-- =====================================================
-- Este script:
-- 1. Cria as funções com permissões corretas (incluindo configurações)
-- 2. Limpa funções duplicadas e incorretas
-- 3. Aplica permissões para todas as empresas
-- =====================================================

-- =====================================================
-- PASSO 1: CRIAR FUNÇÕES DE PERMISSÕES
-- =====================================================

-- 1. ADMINISTRADOR - TODAS AS PERMISSÕES
CREATE OR REPLACE FUNCTION criar_funcao_admin_padrao(p_empresa_id UUID)
RETURNS UUID AS $$
DECLARE
  v_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = p_empresa_id AND nome = 'Administrador';
  
  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
  ELSE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      p_empresa_id,
      'Administrador',
      'Acesso total ao sistema - Gerencia todas as funcionalidades'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- TODAS as permissões (incluindo configurações)
  FOR v_permissao IN (SELECT id FROM permissoes)
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- 2. GERENTE - TODAS AS PERMISSÕES
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

  -- TODAS as permissões (incluindo configurações)
  FOR v_permissao IN (SELECT id FROM permissoes)
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RETURN v_funcao_id;
END;
$$ LANGUAGE plpgsql;

-- 3. VENDEDOR
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
      'Realizar vendas, gerenciar clientes e produtos'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- vendas (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'vendas'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- clientes (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'clientes'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- produtos (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'produtos'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- ordens_servico (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'ordens_servico'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- relatorios (somente read)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'relatorios' AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- caixa (somente read)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'caixa' AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- configuracoes.impressora (read, update)
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

  -- configuracoes.aparencia (read, update)
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

-- 4. CAIXA
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
      'Gerenciar caixa, vendas e movimentações financeiras'
    )
    RETURNING id INTO v_funcao_id;
  END IF;

  -- vendas (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'vendas'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- clientes (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'clientes'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- produtos (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'produtos'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- ordens_servico (create, read, update, delete)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'ordens_servico'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- relatorios (somente read)
  FOR v_permissao IN (
    SELECT id FROM permissoes 
    WHERE recurso = 'relatorios' AND acao = 'read'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- caixa (TODAS - com sangria/suprimento)
  FOR v_permissao IN (
    SELECT id FROM permissoes WHERE recurso = 'caixa'
  )
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao.id, p_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- configuracoes.impressora (read, update)
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

  -- configuracoes.aparencia (read, update)
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

-- 5. TÉCNICO
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
      'Gerenciar ordens de serviço e reparos'
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

  -- configuracoes.aparencia (read, update)
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
-- PASSO 2: APLICAR PARA TODAS AS EMPRESAS
-- =====================================================
DO $$
DECLARE
  v_empresa RECORD;
  v_admin_id UUID;
  v_gerente_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_tecnico_id UUID;
BEGIN
  -- Processar cada empresa
  FOR v_empresa IN (SELECT id, nome FROM empresas ORDER BY created_at)
  LOOP
    RAISE NOTICE '🏢 Processando empresa: % (ID: %)', v_empresa.nome, v_empresa.id;
    
    -- Deletar função "Funcionário" se existir
    DELETE FROM funcao_permissoes 
    WHERE funcao_id IN (
      SELECT id FROM funcoes 
      WHERE empresa_id = v_empresa.id 
      AND nome = 'Funcionário'
    );
    
    DELETE FROM funcoes 
    WHERE empresa_id = v_empresa.id 
    AND nome = 'Funcionário';
    
    -- Criar/Atualizar as 5 funções corretas
    v_admin_id := criar_funcao_admin_padrao(v_empresa.id);
    v_gerente_id := criar_funcao_gerente_padrao(v_empresa.id);
    v_vendedor_id := criar_funcao_vendedor_padrao(v_empresa.id);
    v_caixa_id := criar_funcao_caixa_padrao(v_empresa.id);
    v_tecnico_id := criar_funcao_tecnico_padrao(v_empresa.id);
    
    RAISE NOTICE '  ✅ Administrador: % permissões', (
      SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = v_admin_id
    );
    RAISE NOTICE '  ✅ Gerente: % permissões', (
      SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = v_gerente_id
    );
    RAISE NOTICE '  ✅ Vendedor: % permissões', (
      SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = v_vendedor_id
    );
    RAISE NOTICE '  ✅ Caixa: % permissões', (
      SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = v_caixa_id
    );
    RAISE NOTICE '  ✅ Técnico: % permissões', (
      SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = v_tecnico_id
    );
  END LOOP;
  
  RAISE NOTICE '🎉 Sistema de permissões aplicado com sucesso!';
END $$;

-- Verificação final
SELECT 
  '📊 RESUMO FINAL' as info,
  e.nome as empresa,
  f.nome as funcao,
  COUNT(fp.id) as total_permissoes
FROM empresas e
CROSS JOIN funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id AND fp.empresa_id = e.id
WHERE f.empresa_id = e.id
GROUP BY e.nome, f.nome, f.id
ORDER BY e.nome, 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Vendedor' THEN 3
    WHEN 'Caixa' THEN 4
    WHEN 'Técnico' THEN 5
    ELSE 6
  END;

-- Mostrar detalhes das permissões de configurações por função
SELECT 
  '🔧 PERMISSÕES DE CONFIGURAÇÕES' as info,
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.recurso LIKE 'configuracoes.%'
AND f.empresa_id = (SELECT id FROM empresas ORDER BY created_at LIMIT 1)
ORDER BY f.nome, p.recurso, p.acao;
