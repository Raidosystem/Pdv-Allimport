-- =========================================
-- VERIFICAR E CORRIGIR PERMISSÕES DE CONFIGURAÇÕES
-- =========================================

-- Passo 1: Ver TODAS as permissões de configurações disponíveis
SELECT 
  id,
  categoria,
  recurso,
  acao,
  descricao
FROM permissoes
WHERE categoria = 'configuracoes'
ORDER BY recurso, acao;

-- Passo 2: Ver quais permissões cada função TEM
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
ORDER BY f.nome, p.recurso, p.acao;

-- Passo 3: Contagem por função
SELECT 
  f.nome as funcao,
  COUNT(*) as total_permissoes_config
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome
ORDER BY f.nome;

-- Passo 4: Ver especificamente o que o TÉCNICO tem
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND f.nome = 'Técnico'
ORDER BY p.recurso, p.acao;

-- Passo 5: LIMPAR permissões de configurações do Técnico
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT id FROM funcoes WHERE nome = 'Técnico'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE categoria = 'configuracoes'
);

-- Passo 6: Atribuir APENAS aparencia.read ao Técnico
DO $$
DECLARE
  v_empresa RECORD;
  v_tecnico_id UUID;
  v_perm_id UUID;
BEGIN
  FOR v_empresa IN SELECT id FROM empresas LOOP
    RAISE NOTICE 'Processando empresa: %', v_empresa.id;
    
    -- Buscar ID da função Técnico
    SELECT id INTO v_tecnico_id 
    FROM funcoes 
    WHERE empresa_id = v_empresa.id 
      AND nome = 'Técnico';
    
    IF v_tecnico_id IS NOT NULL THEN
      RAISE NOTICE '  ✅ Técnico ID: %', v_tecnico_id;
      
      -- Buscar ID da permissão configuracoes.aparencia read
      SELECT id INTO v_perm_id
      FROM permissoes
      WHERE recurso = 'configuracoes.aparencia'
        AND acao = 'read';
      
      IF v_perm_id IS NOT NULL THEN
        -- Inserir APENAS aparencia read
        INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
        VALUES (v_tecnico_id, v_perm_id, v_empresa.id)
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE '  ✅ Permissão aparencia.read atribuída';
      ELSE
        RAISE NOTICE '  ⚠️ Permissão configuracoes.aparencia:read não encontrada';
      END IF;
    ELSE
      RAISE NOTICE '  ⚠️ Função Técnico não encontrada para esta empresa';
    END IF;
  END LOOP;
  
  RAISE NOTICE '✅ CONCLUÍDO: Permissões do Técnico corrigidas';
END $$;

-- Passo 7: Verificar resultado - Técnico deve ter APENAS 1 permissão de config
SELECT 
  f.nome as funcao,
  COUNT(*) as total_permissoes_config,
  STRING_AGG(p.recurso || ':' || p.acao, ', ') as permissoes
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND f.nome = 'Técnico'
GROUP BY f.nome;

-- Passo 8: Ver TODAS as funções e suas permissões de config (resumo final)
SELECT 
  f.nome as funcao,
  COUNT(*) as total_config
FROM funcoes f
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome
ORDER BY 
  CASE f.nome
    WHEN 'Administrador' THEN 1
    WHEN 'Gerente' THEN 2
    WHEN 'Caixa' THEN 3
    WHEN 'Vendedor' THEN 4
    WHEN 'Técnico' THEN 5
  END;
