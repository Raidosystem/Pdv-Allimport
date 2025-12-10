-- =====================================================
-- ATIVAR PERMISSÕES PADRÃO POR FUNÇÃO - CORRIGIDO
-- =====================================================
-- ⚠️ IMPORTANTE: Execute primeiro o DIAGNOSTICO_PERMISSOES_PADRAO.sql
-- para verificar se as funções e permissões existem!
-- =====================================================

BEGIN;

-- =====================================================
-- PASSO 1: Criar funções padrão se não existirem
-- =====================================================
DO $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Buscar primeira empresa cadastrada
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ ERRO: Nenhuma empresa encontrada! Crie uma empresa primeiro.';
  END IF;
  
  -- Administrador
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome = 'Administrador') THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Administrador', 'Acesso total ao sistema', v_empresa_id);
    RAISE NOTICE '✅ Função Administrador criada';
  END IF;

  -- Gerente
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome = 'Gerente') THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Gerente', 'Gerenciamento geral exceto administração', v_empresa_id);
    RAISE NOTICE '✅ Função Gerente criada';
  END IF;

  -- Vendedor
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome = 'Vendedor') THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Vendedor', 'Realiza vendas e gerencia clientes', v_empresa_id);
    RAISE NOTICE '✅ Função Vendedor criada';
  END IF;

  -- Operador de Caixa
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome IN ('Operador de Caixa', 'Caixa')) THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Operador de Caixa', 'Opera o caixa e realiza vendas básicas', v_empresa_id);
    RAISE NOTICE '✅ Função Operador de Caixa criada';
  END IF;

  -- Estoquista
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome = 'Estoquista') THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Estoquista', 'Gerencia produtos e estoque', v_empresa_id);
    RAISE NOTICE '✅ Função Estoquista criada';
  END IF;

  -- Técnico
  IF NOT EXISTS (SELECT 1 FROM funcoes WHERE nome IN ('Técnico', 'Atendente')) THEN
    INSERT INTO funcoes (nome, descricao, empresa_id)
    VALUES ('Técnico', 'Gerencia ordens de serviço', v_empresa_id);
    RAISE NOTICE '✅ Função Técnico criada';
  END IF;
END $$;

-- =====================================================
-- PASSO 2: Verificar se empresa_id existe na tabela
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'funcao_permissoes' 
    AND column_name = 'empresa_id'
  ) THEN
    RAISE EXCEPTION '❌ ERRO: Coluna empresa_id não existe em funcao_permissoes! Execute primeiro: ADICIONAR_EMPRESA_ID_FUNCAO_PERMISSOES.sql';
  ELSE
    RAISE NOTICE '✅ Coluna empresa_id existe em funcao_permissoes';
  END IF;
END $$;

-- =====================================================
-- PASSO 3: Buscar uma empresa para usar como padrão
-- (Necessário para RLS não bloquear)
-- =====================================================
DO $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Buscar primeira empresa cadastrada
  SELECT id INTO v_empresa_id
  FROM empresas
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ ERRO: Nenhuma empresa encontrada! Crie uma empresa primeiro.';
  ELSE
    RAISE NOTICE '✅ Usando empresa_id: %', v_empresa_id;
  END IF;
END $$;

-- =====================================================
-- PASSO 4: DESABILITAR RLS TEMPORARIAMENTE
-- (Para permitir inserção sem autenticação)
-- =====================================================
DO $$
BEGIN
  ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;
  RAISE NOTICE '⚠️ RLS DESABILITADO TEMPORARIAMENTE';
END $$;

-- =====================================================
-- PASSO 5: ATIVAR PERMISSÕES POR FUNÇÃO
-- =====================================================

-- 1. ADMINISTRADOR - TODAS AS PERMISSÕES
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  -- Buscar empresa
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  -- Buscar função
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Administrador'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Limpar permissões antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Adicionar TODAS as permissões (incluindo administracao e configuracoes detalhadas)
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id 
    FROM permissoes;
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Administrador: % permissões (TODAS)', v_count;
  ELSE
    RAISE NOTICE '❌ Função Administrador não encontrada';
  END IF;
END $$;

-- 2. GERENTE - TUDO EXCETO ADMINISTRAÇÃO
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  SELECT id INTO v_funcao_id FROM funcoes WHERE nome = 'Gerente' LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- TODAS as permissões EXCETO administracao (mas INCLUI configuracoes completas)
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id
    FROM permissoes
    WHERE 
      categoria NOT LIKE 'administracao%'
      AND recurso NOT LIKE 'administracao%';
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Gerente: % permissões (sem administração)', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Gerente não encontrada';
  END IF;
END $$;

-- 3. VENDEDOR
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  SELECT id INTO v_funcao_id FROM funcoes WHERE nome = 'Vendedor' LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id
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
      -- Configurações: apenas visualizar aparência e impressão
      OR (recurso = 'appearance')
      OR (recurso = 'print_settings');
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Vendedor: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Vendedor não encontrada';
  END IF;
END $$;

-- 4. OPERADOR DE CAIXA
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  SELECT id INTO v_funcao_id 
  FROM funcoes 
  WHERE nome IN ('Operador de Caixa', 'Caixa', 'Operador')
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id
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
      -- Configurações: apenas impressão
      OR (recurso = 'print_settings');
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Operador de Caixa: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Operador de Caixa não encontrada';
  END IF;
END $$;

-- 5. ESTOQUISTA
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  SELECT id INTO v_funcao_id FROM funcoes WHERE nome = 'Estoquista' LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id
    FROM permissoes
    WHERE 
      -- Produtos: todas as operações
      (categoria = 'produtos')
      -- Relatórios: produtos e estoque
      OR (recurso = 'relatorios' AND acao IN ('products', 'inventory'))
      -- Configurações: apenas visualizar
      OR (recurso = 'configuracoes' AND acao = 'read');
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Estoquista: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Estoquista não encontrada';
  END IF;
END $$;

-- 6. TÉCNICO
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  SELECT id INTO v_funcao_id 
  FROM funcoes 
  WHERE nome IN ('Técnico', 'Atendente', 'Técnico de Manutenção')
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_id, id, v_empresa_id
    FROM permissoes
    WHERE 
      -- Ordens de serviço: todas
      (categoria = 'ordens')
      -- Clientes: criar, ler, atualizar
      OR (categoria = 'clientes' AND acao IN ('create', 'read', 'update'))
      -- Produtos: apenas visualizar
      OR (categoria = 'produtos' AND acao = 'read')
      -- Configurações: apenas visualizar e impressão
      OR (recurso = 'print_settings');
    
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    RAISE NOTICE '✅ Técnico/Atendente: % permissões', v_count;
  ELSE
    RAISE NOTICE '⚠️ Função Técnico/Atendente não encontrada';
  END IF;
END $$;

-- =====================================================
-- PASSO 6: REABILITAR RLS
-- =====================================================
DO $$
BEGIN
  ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;
  RAISE NOTICE '✅ RLS REABILITADO';
END $$;

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '📊 RESUMO GERAL' as secao,
  f.nome as "Função",
  COUNT(fp.permissao_id) as "Permissões Atribuídas"
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY f.id, f.nome
ORDER BY f.nome;

-- Detalhe por categoria
SELECT 
  '🔍 DETALHE POR CATEGORIA' as secao,
  f.nome as "Função",
  p.categoria as "Categoria",
  COUNT(*) as "Qtd"
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
GROUP BY f.nome, p.categoria
ORDER BY f.nome, p.categoria;

-- =====================================================
-- ✅ PRONTO! PERMISSÕES PADRÃO ATIVADAS!
-- =====================================================
-- 
-- 🎯 PRÓXIMO PASSO:
-- Execute no SQL Editor do Supabase para verificar:
-- 
-- SELECT 
--   func.nome as funcionario,
--   f.nome as funcao,
--   COUNT(fp.id) as permissoes_disponiveis
-- FROM funcionarios func
-- JOIN funcoes f ON func.funcao_id = f.id
-- JOIN funcao_permissoes fp ON f.id = fp.funcao_id
-- GROUP BY func.nome, f.nome;
-- =====================================================
