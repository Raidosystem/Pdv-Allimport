-- =========================================
-- ATRIBUIR PERMISSÕES DETALHADAS DE CONFIGURAÇÕES
-- =========================================

DO $$
DECLARE
  v_empresa RECORD;
  v_admin_id UUID;
  v_gerente_id UUID;
  v_vendedor_id UUID;
  v_caixa_id UUID;
  v_tecnico_id UUID;
BEGIN
  FOR v_empresa IN SELECT id FROM empresas LOOP
    RAISE NOTICE 'Processando empresa: %', v_empresa.id;
    
    -- Buscar IDs das funções
    SELECT id INTO v_admin_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Administrador';
    SELECT id INTO v_gerente_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Gerente';
    SELECT id INTO v_vendedor_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Vendedor';
    SELECT id INTO v_caixa_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Caixa';
    SELECT id INTO v_tecnico_id FROM funcoes WHERE empresa_id = v_empresa.id AND nome = 'Técnico';
    
    -- ========================================
    -- ADMINISTRADOR: TODAS as permissões de configurações
    -- ========================================
    IF v_admin_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_admin_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'configuracoes'
        AND p.recurso IN (
          'configuracoes.dashboard',
          'configuracoes.empresa',
          'configuracoes.aparencia', 
          'configuracoes.impressao',
          'configuracoes.visibilidade',
          'configuracoes.assinatura'
        )
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- ========================================
    -- GERENTE: Todas exceto Assinatura e Visibilidade
    -- ========================================
    IF v_gerente_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_gerente_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'configuracoes'
        AND p.recurso IN (
          'configuracoes.dashboard',
          'configuracoes.empresa',
          'configuracoes.aparencia',
          'configuracoes.impressao'
        )
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- ========================================
    -- VENDEDOR: Apenas Aparência (read)
    -- ========================================
    IF v_vendedor_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_vendedor_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'configuracoes'
        AND p.recurso = 'configuracoes.aparencia'
        AND p.acao = 'read'
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- ========================================
    -- CAIXA: Aparência e Impressão (read e update)
    -- ========================================
    IF v_caixa_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_caixa_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'configuracoes'
        AND p.recurso IN ('configuracoes.aparencia', 'configuracoes.impressao')
      ON CONFLICT DO NOTHING;
    END IF;
    
    -- ========================================
    -- TÉCNICO: Apenas Aparência (read)
    -- ========================================
    IF v_tecnico_id IS NOT NULL THEN
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_tecnico_id, p.id, v_empresa.id
      FROM permissoes p
      WHERE p.categoria = 'configuracoes'
        AND p.recurso = 'configuracoes.aparencia'
        AND p.acao = 'read'
      ON CONFLICT DO NOTHING;
    END IF;
    
  END LOOP;
  
  RAISE NOTICE 'Permissões de configurações atribuídas com sucesso!';
END $$;

-- Verificar atribuições
SELECT 
  e.nome as empresa,
  f.nome as funcao,
  COUNT(DISTINCT CASE WHEN p.categoria = 'configuracoes' THEN fp.permissao_id END) as total_config
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
GROUP BY e.nome, f.nome
ORDER BY e.nome, f.nome;

-- Ver detalhes de quais permissões de configurações cada função tem
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND e.nome = 'Assistência All-Import'
ORDER BY f.nome, p.recurso, p.acao;
