-- =====================================================
-- ?? REFATORAÇÃO PERMISSÕES - VERSÃO FINAL CORRETA
-- =====================================================
-- ? Sintaxe SQL 100% correta
-- ? Ordem correta (colunas ? dados)
-- ? Todos os RAISE dentro de blocos DO $$
-- =====================================================

BEGIN;

-- =====================================================
-- 1?? ADICIONAR COLUNAS (SE NÃO EXISTIREM)
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'permissoes' AND column_name = 'modulo_pai'
  ) THEN
    ALTER TABLE permissoes ADD COLUMN modulo_pai VARCHAR(100);
    RAISE NOTICE '? Coluna modulo_pai adicionada';
  ELSE
    RAISE NOTICE '?? Coluna modulo_pai já existe';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'permissoes' AND column_name = 'ordem'
  ) THEN
    ALTER TABLE permissoes ADD COLUMN ordem INTEGER DEFAULT 0;
    RAISE NOTICE '? Coluna ordem adicionada';
  ELSE
    RAISE NOTICE '?? Coluna ordem já existe';
  END IF;
END $$;

-- =====================================================
-- 2?? LIMPAR PERMISSÕES ANTIGAS
-- =====================================================
DO $$
BEGIN
  DELETE FROM funcao_permissoes;
  DELETE FROM permissoes;
  RAISE NOTICE '??? Permissões antigas removidas';
END $$;

-- =====================================================
-- 3?? CRIAR ESTRUTURA DE PERMISSÕES
-- =====================================================

-- ?? SEÇÃO: DASHBOARD
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('dashboard', 'view', 'Visualizar dashboard', 'dashboard', NULL, 1),
('dashboard.metricas', 'view', 'Ver métricas gerais', 'dashboard', 'dashboard', 2),
('dashboard.graficos', 'view', 'Ver gráficos', 'dashboard', 'dashboard', 3);

-- ?? SEÇÃO: VENDAS
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('vendas', 'read', 'Ver vendas', 'vendas', NULL, 10),
('vendas', 'create', 'Criar venda', 'vendas', NULL, 11),
('vendas', 'update', 'Editar venda', 'vendas', NULL, 12),
('vendas', 'delete', 'Excluir venda', 'vendas', NULL, 13),
('vendas', 'cancel', 'Cancelar venda', 'vendas', 'vendas', 14),
('vendas', 'refund', 'Fazer estorno', 'vendas', 'vendas', 15),
('vendas', 'discount', 'Aplicar desconto', 'vendas', 'vendas', 16),
('vendas', 'print', 'Imprimir cupom', 'vendas', 'vendas', 17);

-- ?? SEÇÃO: PRODUTOS
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('produtos', 'read', 'Ver produtos', 'produtos', NULL, 20),
('produtos', 'create', 'Cadastrar produto', 'produtos', NULL, 21),
('produtos', 'update', 'Editar produto', 'produtos', NULL, 22),
('produtos', 'delete', 'Excluir produto', 'produtos', NULL, 23),
('produtos', 'manage_stock', 'Gerenciar estoque', 'produtos', 'produtos', 24),
('produtos', 'adjust_price', 'Ajustar preços', 'produtos', 'produtos', 25),
('produtos', 'manage_categories', 'Gerenciar categorias', 'produtos', 'produtos', 26),
('produtos', 'import', 'Importar produtos', 'produtos', 'produtos', 27),
('produtos', 'export', 'Exportar produtos', 'produtos', 'produtos', 28);

-- ?? SEÇÃO: CLIENTES
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('clientes', 'read', 'Ver clientes', 'clientes', NULL, 30),
('clientes', 'create', 'Cadastrar cliente', 'clientes', NULL, 31),
('clientes', 'update', 'Editar cliente', 'clientes', NULL, 32),
('clientes', 'delete', 'Excluir cliente', 'clientes', NULL, 33),
('clientes', 'view_history', 'Ver histórico', 'clientes', 'clientes', 34),
('clientes', 'manage_debt', 'Gerenciar crédito/débito', 'clientes', 'clientes', 35),
('clientes', 'import', 'Importar clientes', 'clientes', 'clientes', 36),
('clientes', 'export', 'Exportar clientes', 'clientes', 'clientes', 37);

-- ?? SEÇÃO: CAIXA
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('caixa', 'read', 'Ver caixa', 'caixa', NULL, 40),
('caixa', 'view', 'Visualizar movimentação', 'caixa', NULL, 41),
('caixa', 'open', 'Abrir caixa', 'caixa', 'caixa', 42),
('caixa', 'close', 'Fechar caixa', 'caixa', 'caixa', 43),
('caixa', 'sangria', 'Fazer sangria', 'caixa', 'caixa', 44),
('caixa', 'suprimento', 'Fazer suprimento', 'caixa', 'caixa', 45),
('caixa', 'view_history', 'Ver histórico', 'caixa', 'caixa', 46);

-- ?? SEÇÃO: ORDENS DE SERVIÇO
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('ordens', 'read', 'Ver ordens', 'ordens', NULL, 50),
('ordens', 'create', 'Criar ordem', 'ordens', NULL, 51),
('ordens', 'update', 'Editar ordem', 'ordens', NULL, 52),
('ordens', 'delete', 'Excluir ordem', 'ordens', NULL, 53),
('ordens', 'change_status', 'Alterar status', 'ordens', 'ordens', 54),
('ordens', 'print', 'Imprimir ordem', 'ordens', 'ordens', 55);

-- ?? SEÇÃO: RELATÓRIOS
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('relatorios', 'read', 'Ver relatórios', 'relatorios', NULL, 60),
('relatorios', 'sales', 'Relatórios de vendas', 'relatorios', 'relatorios', 61),
('relatorios', 'financial', 'Relatórios financeiros', 'relatorios', 'relatorios', 62),
('relatorios', 'products', 'Relatórios de produtos', 'relatorios', 'relatorios', 63),
('relatorios', 'customers', 'Relatórios de clientes', 'relatorios', 'relatorios', 64),
('relatorios', 'inventory', 'Relatórios de estoque', 'relatorios', 'relatorios', 65),
('relatorios', 'export', 'Exportar relatórios', 'relatorios', 'relatorios', 66);

-- ?? SEÇÃO: CONFIGURAÇÕES
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('configuracoes', 'read', 'Ver configurações', 'configuracoes', NULL, 70),
('configuracoes', 'update', 'Alterar configurações', 'configuracoes', NULL, 71),
('configuracoes.dashboard', 'read', 'Configurar dashboard', 'configuracoes', 'configuracoes', 72),
('configuracoes.dashboard', 'update', 'Salvar config. dashboard', 'configuracoes', 'configuracoes', 73),
('configuracoes.aparencia', 'read', 'Ver aparência', 'configuracoes', 'configuracoes', 74),
('configuracoes.aparencia', 'update', 'Alterar aparência', 'configuracoes', 'configuracoes', 75),
('configuracoes.impressao', 'read', 'Ver config. impressão', 'configuracoes', 'configuracoes', 76),
('configuracoes.impressao', 'update', 'Alterar impressão', 'configuracoes', 'configuracoes', 77),
('configuracoes', 'company_info', 'Editar info da empresa', 'configuracoes', 'configuracoes', 78),
('configuracoes', 'integrations', 'Gerenciar integrações', 'configuracoes', 'configuracoes', 79),
('configuracoes', 'backup', 'Fazer backup', 'configuracoes', 'configuracoes', 80);

-- ?? SEÇÃO: ADMINISTRAÇÃO
INSERT INTO permissoes (recurso, acao, descricao, categoria, modulo_pai, ordem) VALUES
('administracao', 'read', 'Ver administração', 'administracao', NULL, 90),
('administracao', 'full_access', 'Acesso total admin', 'administracao', NULL, 91),
('administracao.usuarios', 'read', 'Ver usuários', 'administracao', 'administracao', 92),
('administracao.usuarios', 'create', 'Criar usuário', 'administracao', 'administracao', 93),
('administracao.usuarios', 'update', 'Editar usuário', 'administracao', 'administracao', 94),
('administracao.usuarios', 'delete', 'Excluir usuário', 'administracao', 'administracao', 95),
('administracao.funcoes', 'read', 'Ver funções', 'administracao', 'administracao', 96),
('administracao.funcoes', 'create', 'Criar função', 'administracao', 'administracao', 97),
('administracao.funcoes', 'update', 'Editar função', 'administracao', 'administracao', 98),
('administracao.funcoes', 'delete', 'Excluir função', 'administracao', 'administracao', 99),
('administracao.permissoes', 'read', 'Ver permissões', 'administracao', 'administracao', 100),
('administracao.permissoes', 'update', 'Editar permissões', 'administracao', 'administracao', 101),
('administracao.sistema', 'read', 'Ver config. sistema', 'administracao', 'administracao', 102),
('administracao.sistema', 'update', 'Alterar config. sistema', 'administracao', 'administracao', 103),
('administracao.logs', 'read', 'Ver logs', 'administracao', 'administracao', 104),
('administracao.assinatura', 'read', 'Ver assinatura', 'administracao', 'administracao', 105),
('administracao.assinatura', 'update', 'Gerenciar assinatura', 'administracao', 'administracao', 106),
('administracao.backup', 'read', 'Ver backups', 'administracao', 'administracao', 107),
('administracao.backup', 'create', 'Criar backup', 'administracao', 'administracao', 108);

-- =====================================================
-- 4?? APLICAR PERMISSÕES ÀS FUNÇÕES
-- =====================================================
DO $$
DECLARE
  v_funcao_admin_id UUID;
  v_funcao_vendedor_id UUID;
  v_count_admin INT;
  v_count_vendedor INT;
BEGIN
  -- ADMINISTRADOR
  SELECT id INTO v_funcao_admin_id FROM funcoes WHERE nome = 'Administrador' LIMIT 1;
  
  IF v_funcao_admin_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_admin_id, p.id, NULL FROM permissoes p
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count_admin FROM funcao_permissoes WHERE funcao_id = v_funcao_admin_id;
    RAISE NOTICE '? Administrador: % permissões', v_count_admin;
  ELSE
    RAISE NOTICE '?? Função Administrador não encontrada';
  END IF;
  
  -- VENDEDOR
  SELECT id INTO v_funcao_vendedor_id FROM funcoes WHERE nome = 'Vendedor' LIMIT 1;
  
  IF v_funcao_vendedor_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_funcao_vendedor_id, p.id, NULL
    FROM permissoes p
    WHERE 
      (p.recurso = 'vendas' AND p.acao IN ('read', 'create', 'update', 'print'))
      OR (p.recurso = 'clientes' AND p.acao IN ('read', 'create', 'update', 'view_history'))
      OR (p.recurso = 'produtos' AND p.acao IN ('read'))
    ON CONFLICT DO NOTHING;
    
    SELECT COUNT(*) INTO v_count_vendedor FROM funcao_permissoes WHERE funcao_id = v_funcao_vendedor_id;
    RAISE NOTICE '? Vendedor: % permissões', v_count_vendedor;
  ELSE
    RAISE NOTICE '?? Função Vendedor não encontrada';
  END IF;
END $$;

-- =====================================================
-- 5?? CRIAR VIEW DE HIERARQUIA
-- =====================================================
CREATE OR REPLACE VIEW v_permissoes_hierarquia AS
SELECT 
  p.id,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria,
  p.modulo_pai,
  p.ordem,
  CASE 
    WHEN p.modulo_pai IS NULL THEN 'Módulo Principal'
    ELSE 'Subseção'
  END as tipo,
  pai.descricao as descricao_pai
FROM permissoes p
LEFT JOIN permissoes pai ON p.modulo_pai = pai.recurso
ORDER BY p.categoria, p.ordem;

-- =====================================================
-- 6?? VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  categoria as "Seção",
  COUNT(*) as "Total"
FROM permissoes
GROUP BY categoria
ORDER BY 
  CASE categoria
    WHEN 'dashboard' THEN 1
    WHEN 'vendas' THEN 2
    WHEN 'produtos' THEN 3
    WHEN 'clientes' THEN 4
    WHEN 'caixa' THEN 5
    WHEN 'ordens' THEN 6
    WHEN 'relatorios' THEN 7
    WHEN 'configuracoes' THEN 8
    WHEN 'administracao' THEN 9
  END;

SELECT 
  f.nome as "Função",
  COUNT(fp.permissao_id) as "Permissões"
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY f.nome
ORDER BY f.nome;

COMMIT;

-- =====================================================
-- ? CONCLUÍDO!
-- =====================================================
-- Total: 78 permissões criadas
-- Administrador: ~78 permissões
-- Vendedor: ~9 permissões
-- View de hierarquia: criada
-- =====================================================
