-- =====================================================
-- ATIVAR PERMISSÕES PADRÃO POR FUNÇÃO
-- =====================================================

BEGIN;

-- =====================================================
-- 1. FUNÇÃO: ADMINISTRADOR
-- Permissão: TODAS (acesso total)
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Administrador
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Administrador'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar TODAS as permissões
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id FROM permissoes
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Administrador: % permissões', v_count;
  ELSE
    RAISE NOTICE '❌ Função Administrador não encontrada';
  END IF;
END $$;

-- =====================================================
-- 2. FUNÇÃO: GERENTE
-- Permissão: Tudo exceto administração
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Gerente
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Gerente'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar permissões (exceto administração)
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id 
    FROM permissoes
    WHERE categoria != 'administracao'
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Gerente: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Gerente não encontrada';
  END IF;
END $$;

-- =====================================================
-- 3. FUNÇÃO: VENDEDOR
-- Permissão: Vendas, Clientes, Produtos (leitura), Caixa
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Vendedor
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Vendedor'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar permissões de vendedor
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id 
    FROM permissoes
    WHERE 
      -- Vendas: todas
      (categoria = 'vendas')
      -- Clientes: criar, ler, atualizar
      OR (categoria = 'clientes' AND acao IN ('create', 'read', 'update'))
      -- Produtos: apenas leitura
      OR (categoria = 'produtos' AND acao = 'read')
      -- Caixa: abrir, fechar, visualizar
      OR (recurso = 'caixa' AND acao IN ('open', 'close', 'view'))
      -- Relatórios: apenas vendas
      OR (recurso = 'relatorios' AND acao = 'sales')
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Vendedor: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Vendedor não encontrada';
  END IF;
END $$;

-- =====================================================
-- 4. FUNÇÃO: OPERADOR DE CAIXA
-- Permissão: Apenas caixa e vendas básicas
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Operador de Caixa / Caixa
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome IN ('Operador de Caixa', 'Caixa', 'Operador')
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar permissões de caixa
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id 
    FROM permissoes
    WHERE 
      -- Vendas: criar e visualizar
      (categoria = 'vendas' AND acao IN ('create', 'read'))
      -- Caixa: todas as operações
      OR (recurso = 'caixa')
      -- Clientes: apenas visualizar
      OR (categoria = 'clientes' AND acao = 'read')
      -- Produtos: apenas visualizar
      OR (categoria = 'produtos' AND acao = 'read')
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Operador de Caixa: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Operador de Caixa não encontrada';
  END IF;
END $$;

-- =====================================================
-- 5. FUNÇÃO: ESTOQUISTA
-- Permissão: Produtos e estoque
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Estoquista
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Estoquista'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar permissões de estoquista
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id 
    FROM permissoes
    WHERE 
      -- Produtos: todas
      (categoria = 'produtos')
      -- Relatórios: produtos e estoque
      OR (recurso = 'relatorios' AND acao IN ('products', 'inventory'))
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Estoquista: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Estoquista não encontrada';
  END IF;
END $$;

-- =====================================================
-- 6. FUNÇÃO: TÉCNICO / ATENDENTE
-- Permissão: Ordens de serviço
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar função Técnico ou Atendente
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome IN ('Técnico', 'Atendente', 'Técnico de Manutenção')
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar permissões de técnico
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    SELECT v_funcao_id, id 
    FROM permissoes
    WHERE 
      -- Ordens: todas
      (categoria = 'ordens')
      -- Clientes: criar, ler, atualizar
      OR (categoria = 'clientes' AND acao IN ('create', 'read', 'update'))
      -- Produtos: apenas leitura
      OR (categoria = 'produtos' AND acao = 'read')
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Técnico/Atendente: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Técnico/Atendente não encontrada';
  END IF;
END $$;

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  f.nome as "Função",
  COUNT(fp.permissao_id) as "Permissões Atribuídas"
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY f.id, f.nome
ORDER BY f.nome;

-- Detalhe por função
SELECT 
  f.nome as "Função",
  p.categoria as "Categoria",
  COUNT(*) as "Qtd"
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
GROUP BY f.nome, p.categoria
ORDER BY f.nome, p.categoria;
