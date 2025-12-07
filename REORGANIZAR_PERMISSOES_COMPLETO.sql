-- =====================================================
-- REORGANIZAR PERMISSÕES DO SISTEMA PDV ALLIMPORT
-- Remove duplicatas e organiza por seções lógicas
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- Data: 2025-12-07
-- =====================================================

BEGIN;

-- Desabilitar RLS temporariamente para reorganizar
ALTER TABLE permissoes DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- PASSO 1: BACKUP DAS PERMISSÕES ATUAIS
-- =====================================================
CREATE TEMP TABLE permissoes_backup AS
SELECT * FROM permissoes;

-- =====================================================
-- PASSO 2: LIMPAR TODAS AS PERMISSÕES
-- =====================================================
DELETE FROM funcao_permissoes;
DELETE FROM permissoes;

-- =====================================================
-- PASSO 3: NOTA SOBRE IDs
-- =====================================================
-- A tabela permissoes usa UUID (gen_random_uuid())
-- Não há necessidade de resetar sequência

-- =====================================================
-- 📊 SEÇÃO: DASHBOARD
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('dashboard', 'view', 'Visualizar dashboard principal', 'dashboard'),
('dashboard', 'metrics', 'Visualizar métricas', 'dashboard'),
('dashboard', 'charts', 'Visualizar gráficos', 'dashboard');

-- =====================================================
-- 🛒 SEÇÃO: VENDAS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('vendas', 'create', 'Criar nova venda', 'vendas'),
('vendas', 'read', 'Visualizar vendas', 'vendas'),
('vendas', 'update', 'Editar vendas', 'vendas'),
('vendas', 'delete', 'Excluir vendas', 'vendas'),
('vendas', 'cancel', 'Cancelar vendas', 'vendas'),
('vendas', 'discount', 'Aplicar descontos', 'vendas'),
('vendas', 'print', 'Imprimir cupom', 'vendas'),
('vendas', 'refund', 'Fazer estorno', 'vendas');

-- =====================================================
-- 📦 SEÇÃO: PRODUTOS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('produtos', 'create', 'Cadastrar novos produtos', 'produtos'),
('produtos', 'read', 'Visualizar produtos', 'produtos'),
('produtos', 'update', 'Editar produtos', 'produtos'),
('produtos', 'delete', 'Excluir produtos', 'produtos'),
('produtos', 'import', 'Importar produtos', 'produtos'),
('produtos', 'export', 'Exportar produtos', 'produtos'),
('produtos', 'manage_stock', 'Gerenciar estoque', 'produtos'),
('produtos', 'adjust_price', 'Alterar preços', 'produtos'),
('produtos', 'manage_categories', 'Gerenciar categorias', 'produtos');

-- =====================================================
-- 👥 SEÇÃO: CLIENTES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('clientes', 'create', 'Cadastrar novos clientes', 'clientes'),
('clientes', 'read', 'Visualizar clientes', 'clientes'),
('clientes', 'update', 'Editar clientes', 'clientes'),
('clientes', 'delete', 'Excluir clientes', 'clientes'),
('clientes', 'export', 'Exportar clientes', 'clientes'),
('clientes', 'import', 'Importar clientes', 'clientes'),
('clientes', 'view_history', 'Ver histórico de compras', 'clientes'),
('clientes', 'manage_debt', 'Gerenciar crédito/débito', 'clientes');

-- =====================================================
-- 💰 SEÇÃO: FINANCEIRO
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
-- Caixa
('caixa', 'open', 'Abrir caixa', 'financeiro'),
('caixa', 'close', 'Fechar caixa', 'financeiro'),
('caixa', 'view', 'Visualizar caixa', 'financeiro'),
('caixa', 'view_history', 'Ver histórico de caixa', 'financeiro'),
('caixa', 'sangria', 'Fazer sangria', 'financeiro'),
('caixa', 'suprimento', 'Fazer suprimento', 'financeiro'),
-- Financeiro Geral
('financeiro', 'read', 'Visualizar informações financeiras', 'financeiro'),
('financeiro', 'create', 'Criar movimentações financeiras', 'financeiro'),
('financeiro', 'update', 'Editar movimentações', 'financeiro'),
('financeiro', 'delete', 'Excluir movimentações', 'financeiro'),
('financeiro', 'manage_payments', 'Gerenciar formas de pagamento', 'financeiro'),
('financeiro', 'view_reports', 'Ver relatórios financeiros', 'financeiro');

-- =====================================================
-- 🔧 SEÇÃO: ORDENS DE SERVIÇO
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('ordens', 'create', 'Criar ordem de serviço', 'ordens'),
('ordens', 'read', 'Visualizar ordens', 'ordens'),
('ordens', 'update', 'Editar ordem', 'ordens'),
('ordens', 'delete', 'Excluir ordem', 'ordens'),
('ordens', 'change_status', 'Alterar status da ordem', 'ordens'),
('ordens', 'print', 'Imprimir ordem', 'ordens');

-- =====================================================
-- 📊 SEÇÃO: RELATÓRIOS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
('relatorios', 'read', 'Visualizar relatórios', 'relatorios'),
('relatorios', 'export', 'Exportar relatórios', 'relatorios'),
('relatorios', 'sales', 'Relatórios de vendas', 'relatorios'),
('relatorios', 'financial', 'Relatórios financeiros', 'relatorios'),
('relatorios', 'products', 'Relatórios de produtos', 'relatorios'),
('relatorios', 'customers', 'Relatórios de clientes', 'relatorios'),
('relatorios', 'inventory', 'Relatórios de estoque', 'relatorios');

-- =====================================================
-- ⚙️ SEÇÃO: CONFIGURAÇÕES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
-- Configurações Gerais
('configuracoes', 'read', 'Visualizar configurações', 'configuracoes'),
('configuracoes', 'update', 'Alterar configurações', 'configuracoes'),
-- Empresa
('configuracoes', 'company_info', 'Editar informações da empresa', 'configuracoes'),
-- Impressão
('configuracoes', 'print_settings', 'Configurar impressão', 'configuracoes'),
-- Aparência
('configuracoes', 'appearance', 'Configurar aparência', 'configuracoes'),
-- Integrações
('configuracoes', 'integrations', 'Gerenciar integrações', 'configuracoes'),
-- Backup
('configuracoes', 'backup', 'Fazer backup de dados', 'configuracoes');

-- =====================================================
-- 👑 SEÇÃO: ADMINISTRAÇÃO
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
-- Administração Geral
('administracao', 'read', 'Visualizar área administrativa', 'administracao'),
('administracao', 'full_access', 'Acesso total administrativo', 'administracao'),
-- Usuários
('administracao.usuarios', 'create', 'Cadastrar usuário', 'administracao'),
('administracao.usuarios', 'read', 'Visualizar usuários', 'administracao'),
('administracao.usuarios', 'update', 'Editar usuário', 'administracao'),
('administracao.usuarios', 'delete', 'Excluir usuário', 'administracao'),
-- Funções
('administracao.funcoes', 'create', 'Criar novas funções', 'administracao'),
('administracao.funcoes', 'read', 'Visualizar funções', 'administracao'),
('administracao.funcoes', 'update', 'Editar funções', 'administracao'),
('administracao.funcoes', 'delete', 'Excluir funções', 'administracao'),
-- Permissões
('administracao.permissoes', 'read', 'Visualizar permissões', 'administracao'),
('administracao.permissoes', 'update', 'Gerenciar permissões', 'administracao'),
-- Logs
('administracao.logs', 'read', 'Visualizar logs do sistema', 'administracao'),
-- Assinatura
('administracao.assinatura', 'read', 'Ver assinatura', 'administracao'),
('administracao.assinatura', 'update', 'Gerenciar assinatura', 'administracao');

-- =====================================================
-- PASSO 4: CRIAR CONSTRAINT UNIQUE
-- =====================================================
DO $$
BEGIN
  -- Remover constraint antiga se existir
  ALTER TABLE permissoes DROP CONSTRAINT IF EXISTS permissoes_recurso_acao_key;
  
  -- Criar nova constraint
  ALTER TABLE permissoes
  ADD CONSTRAINT permissoes_recurso_acao_key
  UNIQUE (recurso, acao);
END $$;

-- =====================================================
-- PASSO 5: RECRIAR PERMISSÕES PARA FUNÇÃO ADMINISTRADOR
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_permissao_id UUID;
BEGIN
  -- Buscar ID da função Administrador
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Administrador'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Associar TODAS as permissões à função Administrador
    FOR v_permissao_id IN
      SELECT id FROM permissoes
    LOOP
      INSERT INTO funcao_permissoes (funcao_id, permissao_id)
      VALUES (v_funcao_id, v_permissao_id)
      ON CONFLICT DO NOTHING;
    END LOOP;

    RAISE NOTICE 'Permissões atribuídas à função Administrador';
  ELSE
    RAISE NOTICE 'Função Administrador não encontrada';
  END IF;
END $$;

-- =====================================================
-- PASSO 6: REABILITAR RLS
-- =====================================================
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PASSO 7: CRIAR/ATUALIZAR POLÍTICAS RLS
-- =====================================================

-- Permitir leitura pública de permissões (necessário para montar menus)
DROP POLICY IF EXISTS "Permitir leitura de permissoes" ON permissoes;
CREATE POLICY "Permitir leitura de permissoes"
  ON permissoes FOR SELECT
  USING (true);

-- Apenas admins podem gerenciar permissões
DROP POLICY IF EXISTS "Apenas admins gerenciam permissoes" ON permissoes;
CREATE POLICY "Apenas admins gerenciam permissoes"
  ON permissoes FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM funcionarios f
      JOIN funcoes func ON f.funcao_id = func.id
      WHERE f.user_id = auth.uid()
        AND func.nome = 'Administrador'
    )
  );

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT
  categoria as "Seção",
  recurso as "Recurso",
  acao as "Ação",
  descricao as "Descrição"
FROM permissoes
ORDER BY
  CASE categoria
    WHEN 'dashboard' THEN 1
    WHEN 'vendas' THEN 2
    WHEN 'produtos' THEN 3
    WHEN 'clientes' THEN 4
    WHEN 'financeiro' THEN 5
    WHEN 'ordens' THEN 6
    WHEN 'relatorios' THEN 7
    WHEN 'configuracoes' THEN 8
    WHEN 'administracao' THEN 9
    ELSE 10
  END,
  recurso,
  acao;

-- Contagem por categoria
SELECT
  categoria as "Categoria",
  COUNT(*) as "Total de Permissões"
FROM permissoes
GROUP BY categoria
ORDER BY
  CASE categoria
    WHEN 'dashboard' THEN 1
    WHEN 'vendas' THEN 2
    WHEN 'produtos' THEN 3
    WHEN 'clientes' THEN 4
    WHEN 'financeiro' THEN 5
    WHEN 'ordens' THEN 6
    WHEN 'relatorios' THEN 7
    WHEN 'configuracoes' THEN 8
    WHEN 'administracao' THEN 9
    ELSE 10
  END;

-- =====================================================
-- RESUMO DA REORGANIZAÇÃO
-- =====================================================
-- 📊 Dashboard: 3 permissões
-- 🛒 Vendas: 8 permissões
-- 📦 Produtos: 9 permissões
-- 👥 Clientes: 8 permissões
-- 💰 Financeiro: 12 permissões (incluindo caixa)
-- 🔧 Ordens de Serviço: 6 permissões
-- 📊 Relatórios: 7 permissões
-- ⚙️ Configurações: 7 permissões
-- 👑 Administração: 16 permissões (usuários, funções, permissões, logs, assinatura)
-- =====================================================
-- TOTAL: 76 permissões organizadas
-- =====================================================
