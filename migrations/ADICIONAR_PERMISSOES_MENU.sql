-- =========================================
-- ADICIONAR PERMISSÕES DE VISIBILIDADE DE MENU
-- =========================================

-- Inserir novas permissões de visibilidade
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
  ('menu.dashboard', 'view', 'Visualizar Dashboard no menu', 'menu'),
  ('menu.vendas', 'view', 'Visualizar Vendas no menu', 'menu'),
  ('menu.produtos', 'view', 'Visualizar Produtos no menu', 'menu'),
  ('menu.clientes', 'view', 'Visualizar Clientes no menu', 'menu'),
  ('menu.caixa', 'view', 'Visualizar Caixa no menu', 'menu'),
  ('menu.ordens_servico', 'view', 'Visualizar Ordens de Serviço no menu', 'menu'),
  ('menu.relatorios', 'view', 'Visualizar Relatórios no menu', 'menu'),
  ('menu.configuracoes', 'view', 'Visualizar Configurações no menu', 'menu'),
  ('menu.funcionarios', 'view', 'Visualizar Gerenciar Funcionários no menu', 'menu'),
  ('menu.fornecedores', 'view', 'Visualizar Fornecedores no menu', 'menu')
ON CONFLICT (recurso, acao) DO NOTHING;

-- Verificar permissões criadas
SELECT * FROM permissoes WHERE categoria = 'menu' ORDER BY recurso;
