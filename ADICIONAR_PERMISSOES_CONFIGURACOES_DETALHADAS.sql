-- =========================================
-- ADICIONAR PERMISSÕES DETALHADAS DE CONFIGURAÇÕES
-- =========================================

-- Inserir permissões para cada aba de configurações
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
  ('configuracoes.dashboard', 'read', 'Visualizar Dashboard de Configurações', 'configuracoes'),
  ('configuracoes.empresa', 'read', 'Visualizar Configurações da Empresa', 'configuracoes'),
  ('configuracoes.empresa', 'update', 'Editar Configurações da Empresa', 'configuracoes'),
  ('configuracoes.aparencia', 'read', 'Visualizar Configurações de Aparência', 'configuracoes'),
  ('configuracoes.aparencia', 'update', 'Editar Configurações de Aparência', 'configuracoes'),
  ('configuracoes.impressao', 'read', 'Visualizar Configurações de Impressão', 'configuracoes'),
  ('configuracoes.impressao', 'update', 'Editar Configurações de Impressão', 'configuracoes'),
  ('configuracoes.visibilidade', 'read', 'Visualizar Configurações de Visibilidade', 'configuracoes'),
  ('configuracoes.visibilidade', 'update', 'Editar Configurações de Visibilidade', 'configuracoes'),
  ('configuracoes.assinatura', 'read', 'Visualizar Configurações de Assinatura', 'configuracoes'),
  ('configuracoes.assinatura', 'update', 'Gerenciar Assinatura', 'configuracoes')
ON CONFLICT (recurso, acao) DO NOTHING;

-- Verificar permissões de configurações criadas
SELECT * FROM permissoes 
WHERE categoria = 'configuracoes' 
ORDER BY recurso, acao;
