-- =====================================================
-- POPULAR PERMISSÕES DO SISTEMA PDV ALLIMPORT
-- =====================================================
-- Este script insere todas as permissões necessárias
-- para o sistema de gestão de funções e permissões
-- =====================================================

-- Limpar permissões existentes (opcional - descomente se quiser resetar)
-- DELETE FROM permissoes;

-- =====================================================
-- MÓDULO: VENDAS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('vendas', 'create', 'Criar nova venda'),
('vendas', 'read', 'Visualizar vendas'),
('vendas', 'update', 'Editar vendas'),
('vendas', 'delete', 'Excluir vendas'),
('vendas', 'cancel', 'Cancelar vendas'),
('vendas', 'discount', 'Aplicar descontos em vendas');

-- =====================================================
-- MÓDULO: PRODUTOS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('produtos', 'create', 'Cadastrar novos produtos'),
('produtos', 'read', 'Visualizar produtos'),
('produtos', 'update', 'Editar produtos'),
('produtos', 'delete', 'Excluir produtos'),
('produtos', 'import', 'Importar produtos'),
('produtos', 'export', 'Exportar produtos'),
('produtos', 'manage_stock', 'Gerenciar estoque');

-- =====================================================
-- MÓDULO: CLIENTES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('clientes', 'create', 'Cadastrar novos clientes'),
('clientes', 'read', 'Visualizar clientes'),
('clientes', 'update', 'Editar clientes'),
('clientes', 'delete', 'Excluir clientes'),
('clientes', 'export', 'Exportar clientes'),
('clientes', 'view_history', 'Ver histórico de compras');

-- =====================================================
-- MÓDULO: FINANCEIRO
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('financeiro', 'read', 'Visualizar informações financeiras'),
('financeiro', 'create', 'Criar movimentações financeiras'),
('financeiro', 'update', 'Editar movimentações'),
('financeiro', 'delete', 'Excluir movimentações'),
('financeiro', 'open_cashier', 'Abrir caixa'),
('financeiro', 'close_cashier', 'Fechar caixa'),
('financeiro', 'manage_payments', 'Gerenciar formas de pagamento');

-- =====================================================
-- MÓDULO: RELATÓRIOS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('relatorios', 'read', 'Visualizar relatórios'),
('relatorios', 'export', 'Exportar relatórios'),
('relatorios', 'sales', 'Relatórios de vendas'),
('relatorios', 'financial', 'Relatórios financeiros'),
('relatorios', 'products', 'Relatórios de produtos'),
('relatorios', 'customers', 'Relatórios de clientes');

-- =====================================================
-- MÓDULO: CONFIGURAÇÕES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('configuracoes', 'read', 'Visualizar configurações'),
('configuracoes', 'update', 'Alterar configurações'),
('configuracoes', 'print_settings', 'Configurar impressão'),
('configuracoes', 'company_info', 'Editar informações da empresa'),
('configuracoes', 'integrations', 'Gerenciar integrações'),
('configuracoes', 'backup', 'Fazer backup de dados');

-- =====================================================
-- MÓDULO: ADMINISTRAÇÃO
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('administracao', 'read', 'Visualizar área administrativa'),
('administracao', 'users', 'Gerenciar usuários'),
('administracao', 'funcoes', 'Gerenciar funções'),
('administracao', 'permissoes', 'Gerenciar permissões'),
('administracao', 'logs', 'Visualizar logs do sistema'),
('administracao', 'subscription', 'Gerenciar assinatura'),
('administracao', 'full_access', 'Acesso total administrativo');

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
-- Contar permissões inseridas
SELECT 
  recurso as "Módulo",
  COUNT(*) as "Qtd Permissões"
FROM permissoes
GROUP BY recurso
ORDER BY recurso;

-- Total geral
SELECT COUNT(*) as "Total de Permissões" FROM permissoes;

-- =====================================================
-- SUCESSO!
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- Depois recarregue a página de Funções e Permissões
-- =====================================================
