-- =====================================================
-- CRIAR FUNÇÕES PADRÃO DO SISTEMA PDV
-- =====================================================
-- Este script cria as 5 funções padrão que servem como
-- exemplo para o usuário entender o sistema de permissões.
-- O usuário pode ativar as permissões depois conforme necessário.
-- =====================================================

-- Limpar funções padrão antigas (se existirem)
DELETE FROM funcao_permissoes WHERE funcao_id IN (
  SELECT id FROM funcoes WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
);

DELETE FROM funcoes WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico');

-- =====================================================
-- 1. ADMINISTRADOR
-- =====================================================
INSERT INTO funcoes (
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  'Administrador',
  'Acesso total ao sistema. Pode gerenciar todas as funcionalidades, usuários, configurações e realizar qualquer operação.',
  10,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 2. GERENTE
-- =====================================================
INSERT INTO funcoes (
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  'Gerente',
  'Gerenciamento completo da loja. Pode visualizar relatórios, gerenciar estoque, produtos, clientes e supervisionar vendas.',
  8,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 3. VENDEDOR
-- =====================================================
INSERT INTO funcoes (
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  'Vendedor',
  'Responsável por vendas. Pode realizar vendas, consultar produtos, cadastrar clientes e emitir recibos.',
  5,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 4. CAIXA
-- =====================================================
INSERT INTO funcoes (
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  'Caixa',
  'Operação de caixa. Pode abrir/fechar caixa, processar vendas, receber pagamentos e gerar relatórios de caixa.',
  4,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 5. TÉCNICO
-- =====================================================
INSERT INTO funcoes (
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  'Técnico',
  'Gerenciamento de assistência técnica. Pode criar ordens de serviço, gerenciar equipamentos e atualizar status de reparos.',
  6,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
-- Mostrar as funções criadas
SELECT 
  id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at
FROM funcoes
WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
ORDER BY nivel DESC;

-- =====================================================
-- NOTAS IMPORTANTES:
-- =====================================================
-- 1. Todas as funções são marcadas como "sistema = true"
--    para indicar que são funções padrão do sistema.
--
-- 2. Todas estão ativas (ativo = true) por padrão.
--
-- 3. Os níveis definem a hierarquia:
--    - Administrador: 10 (máximo)
--    - Gerente: 8
--    - Técnico: 6
--    - Vendedor: 5
--    - Caixa: 4
--
-- 4. NENHUMA PERMISSÃO é atribuída automaticamente.
--    O usuário deve ATIVAR as permissões manualmente
--    através da interface AdminRolesPermissionsPageNew.
--
-- 5. O botão "Criar Nova Função" permanece disponível
--    para que o usuário possa criar funções customizadas.
--
-- 6. Estas funções servem como EXEMPLO para o usuário
--    entender como o sistema funciona.
-- =====================================================
