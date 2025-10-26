-- =====================================================
-- CRIAR PERMISSÕES DE CONFIGURAÇÕES
-- =====================================================
-- Este script cria as permissões de configurações que não existem no banco

DO $$
BEGIN
  -- configuracoes.impressora (read, update)
  INSERT INTO permissoes (recurso, acao, descricao, categoria)
  VALUES 
    ('configuracoes.impressora', 'read', 'Visualizar configurações de impressora', 'configuracoes'),
    ('configuracoes.impressora', 'update', 'Editar configurações de impressora', 'configuracoes')
  ON CONFLICT (recurso, acao) DO NOTHING;

  -- configuracoes.aparencia (read, update)
  INSERT INTO permissoes (recurso, acao, descricao, categoria)
  VALUES 
    ('configuracoes.aparencia', 'read', 'Visualizar configurações de aparência', 'configuracoes'),
    ('configuracoes.aparencia', 'update', 'Editar configurações de aparência (logo, cores)', 'configuracoes')
  ON CONFLICT (recurso, acao) DO NOTHING;

  -- configuracoes.sistema (todas as ações - só Admin/Gerente)
  INSERT INTO permissoes (recurso, acao, descricao, categoria)
  VALUES 
    ('configuracoes.sistema', 'read', 'Visualizar configurações do sistema', 'configuracoes'),
    ('configuracoes.sistema', 'update', 'Editar configurações do sistema', 'configuracoes'),
    ('configuracoes.sistema', 'create', 'Criar configurações do sistema', 'configuracoes'),
    ('configuracoes.sistema', 'delete', 'Deletar configurações do sistema', 'configuracoes')
  ON CONFLICT (recurso, acao) DO NOTHING;

  -- configuracoes.geral (backup, exportar, etc - só Admin/Gerente)
  INSERT INTO permissoes (recurso, acao, descricao, categoria)
  VALUES 
    ('configuracoes.geral', 'read', 'Visualizar configurações gerais', 'configuracoes'),
    ('configuracoes.geral', 'update', 'Editar configurações gerais', 'configuracoes')
  ON CONFLICT (recurso, acao) DO NOTHING;

  RAISE NOTICE '✅ Permissões de configurações criadas!';
END $$;

-- Verificar permissões criadas
SELECT 
  '📋 NOVAS PERMISSÕES DE CONFIGURAÇÕES' as info,
  recurso,
  acao,
  descricao
FROM permissoes
WHERE recurso LIKE 'configuracoes.%'
ORDER BY recurso, acao;
