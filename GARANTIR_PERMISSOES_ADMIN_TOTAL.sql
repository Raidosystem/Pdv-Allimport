-- =========================================
-- GARANTIR QUE ADMINISTRADOR TENHA TODAS AS PERMISSÕES
-- =========================================

-- Passo 1: Ver estado atual do Administrador
SELECT 
  f.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  COUNT(DISTINCT CASE WHEN p.categoria = 'geral' THEN fp.permissao_id END) as permissoes_gerais,
  COUNT(DISTINCT CASE WHEN p.categoria = 'menu' THEN fp.permissao_id END) as permissoes_menu,
  COUNT(DISTINCT CASE WHEN p.categoria = 'configuracoes' THEN fp.permissao_id END) as permissoes_config
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Administrador'
GROUP BY f.nome;

-- Passo 2: Ver total de permissões disponíveis no sistema
SELECT 
  categoria,
  COUNT(*) as total
FROM permissoes
GROUP BY categoria
ORDER BY categoria;

-- Passo 3: Limpar TODAS as permissões do Administrador primeiro
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT id FROM funcoes WHERE nome = 'Administrador'
);

-- Passo 4: Atribuir TODAS as permissões ao Administrador
DO $$
DECLARE
  v_empresa RECORD;
  v_admin_id UUID;
BEGIN
  FOR v_empresa IN SELECT id FROM empresas LOOP
    RAISE NOTICE 'Processando empresa: %', v_empresa.id;
    
    -- Buscar ID da função Administrador
    SELECT id INTO v_admin_id 
    FROM funcoes 
    WHERE empresa_id = v_empresa.id 
      AND nome = 'Administrador';
    
    IF v_admin_id IS NOT NULL THEN
      RAISE NOTICE '  ✅ Administrador ID: %', v_admin_id;
      
      -- Inserir TODAS as permissões
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_admin_id, p.id, v_empresa.id
      FROM permissoes p
      ON CONFLICT DO NOTHING;
      
      RAISE NOTICE '  ✅ Permissões atribuídas';
    ELSE
      RAISE NOTICE '  ⚠️ Função Administrador não encontrada para esta empresa';
    END IF;
  END LOOP;
  
  RAISE NOTICE '✅ CONCLUÍDO: Todas as permissões atribuídas ao Administrador';
END $$;

-- Passo 5: Verificar resultado final
SELECT 
  f.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  COUNT(DISTINCT CASE WHEN p.categoria = 'geral' THEN fp.permissao_id END) as permissoes_gerais,
  COUNT(DISTINCT CASE WHEN p.categoria = 'menu' THEN fp.permissao_id END) as permissoes_menu,
  COUNT(DISTINCT CASE WHEN p.categoria = 'configuracoes' THEN fp.permissao_id END) as permissoes_config
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Administrador'
GROUP BY f.nome;

-- Passo 6: Listar algumas permissões para confirmar
SELECT 
  f.nome as funcao,
  p.categoria,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Administrador'
ORDER BY p.categoria, p.recurso, p.acao
LIMIT 20;

-- Passo 7: Verificar se há algum funcionário com função Administrador
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  f.usuario_ativo,
  f.senha_definida,
  f.ativo,
  f.email
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
WHERE func.nome = 'Administrador';
