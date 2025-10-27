-- =========================================
-- ATRIBUIR PERMISSÕES DE MENU ÀS FUNÇÕES
-- =========================================

DO $$
DECLARE
  v_empresa RECORD;
  v_funcao RECORD;
  v_permissao RECORD;
  v_admin_id UUID;
  v_gerente_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_tecnico_id UUID;
BEGIN
  -- Para cada empresa
  FOR v_empresa IN SELECT id FROM empresas LOOP
    RAISE NOTICE 'Processando empresa: %', v_empresa.id;
    
    -- Buscar IDs das funções
    SELECT id INTO v_admin_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Administrador';
    SELECT id INTO v_gerente_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Gerente';
    SELECT id INTO v_vendedor_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Vendedor';
    SELECT id INTO v_caixa_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Caixa';
    SELECT id INTO v_tecnico_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Técnico';
    
    -- Administrador e Gerente: TODAS as permissões de menu
    FOR v_permissao IN SELECT id FROM permissoes WHERE categoria = 'menu' LOOP
      IF v_admin_id IS NOT NULL THEN
        INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
        VALUES (v_admin_id, v_permissao.id, v_empresa.id)
        ON CONFLICT DO NOTHING;
      END IF;
      
      IF v_gerente_id IS NOT NULL THEN
        INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
        VALUES (v_gerente_id, v_permissao.id, v_empresa.id)
        ON CONFLICT DO NOTHING;
      END IF;
    END LOOP;
    
    -- Vendedor: Dashboard, Vendas, Produtos, Clientes, OS
    IF v_vendedor_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_vendedor_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'menu' 
        AND p.recurso IN ('menu.dashboard', 'menu.vendas', 'menu.produtos', 'menu.clientes', 'menu.ordens_servico')
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- Caixa: Dashboard, Vendas, Produtos, Clientes, Caixa, OS
    IF v_caixa_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_caixa_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'menu' 
        AND p.recurso IN ('menu.dashboard', 'menu.vendas', 'menu.produtos', 'menu.clientes', 'menu.caixa', 'menu.ordens_servico')
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- Técnico: Dashboard, OS
    IF v_tecnico_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_tecnico_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'menu' 
        AND p.recurso IN ('menu.dashboard', 'menu.ordens_servico')
      ON CONFLICT DO NOTHING;
    END IF;
    
  END LOOP;
  
  RAISE NOTICE 'Permissões de menu atribuídas com sucesso!';
END $$;

-- Verificar atribuições
SELECT 
  e.nome as empresa,
  f.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes_menu
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id AND p.categoria = 'menu'
GROUP BY e.nome, f.nome
ORDER BY e.nome, f.nome;
