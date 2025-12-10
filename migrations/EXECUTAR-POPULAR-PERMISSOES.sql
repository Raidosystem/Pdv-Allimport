-- =====================================================
-- POPULAR PERMISSÕES DO SISTEMA PDV ALLIMPORT
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Desabilitar RLS temporariamente para inserir
ALTER TABLE permissoes DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- PASSO 1: REMOVER DUPLICATAS
-- =====================================================
-- Manter apenas o registro mais recente de cada (recurso, acao)
DELETE FROM permissoes a
USING permissoes b
WHERE a.id < b.id
  AND a.recurso = b.recurso
  AND a.acao = b.acao;

-- =====================================================
-- PASSO 2: CRIAR CONSTRAINT UNIQUE
-- =====================================================
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'permissoes_recurso_acao_key'
  ) THEN
    ALTER TABLE permissoes 
    ADD CONSTRAINT permissoes_recurso_acao_key 
    UNIQUE (recurso, acao);
  END IF;
END $$;

-- =====================================================
-- MÓDULO: VENDAS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('vendas', 'create', 'Criar nova venda'),
('vendas', 'read', 'Visualizar vendas'),
('vendas', 'update', 'Editar vendas'),
('vendas', 'delete', 'Excluir vendas'),
('vendas', 'cancel', 'Cancelar vendas'),
('vendas', 'discount', 'Aplicar descontos em vendas')
ON CONFLICT (recurso, acao) DO NOTHING;

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
('produtos', 'manage_stock', 'Gerenciar estoque')
ON CONFLICT (recurso, acao) DO NOTHING;

-- =====================================================
-- MÓDULO: CLIENTES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('clientes', 'create', 'Cadastrar novos clientes'),
('clientes', 'read', 'Visualizar clientes'),
('clientes', 'update', 'Editar clientes'),
('clientes', 'delete', 'Excluir clientes'),
('clientes', 'export', 'Exportar clientes'),
('clientes', 'view_history', 'Ver histórico de compras')
ON CONFLICT (recurso, acao) DO NOTHING;

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
('financeiro', 'manage_payments', 'Gerenciar formas de pagamento')
ON CONFLICT (recurso, acao) DO NOTHING;

-- =====================================================
-- MÓDULO: RELATÓRIOS
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('relatorios', 'read', 'Visualizar relatórios'),
('relatorios', 'export', 'Exportar relatórios'),
('relatorios', 'sales', 'Relatórios de vendas'),
('relatorios', 'financial', 'Relatórios financeiros'),
('relatorios', 'products', 'Relatórios de produtos'),
('relatorios', 'customers', 'Relatórios de clientes')
ON CONFLICT (recurso, acao) DO NOTHING;

-- =====================================================
-- MÓDULO: CONFIGURAÇÕES
-- =====================================================
INSERT INTO permissoes (recurso, acao, descricao) VALUES
('configuracoes', 'read', 'Visualizar configurações'),
('configuracoes', 'update', 'Alterar configurações'),
('configuracoes', 'print_settings', 'Configurar impressão'),
('configuracoes', 'company_info', 'Editar informações da empresa'),
('configuracoes', 'integrations', 'Gerenciar integrações'),
('configuracoes', 'backup', 'Fazer backup de dados')
ON CONFLICT (recurso, acao) DO NOTHING;

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
('administracao', 'full_access', 'Acesso total administrativo'),
('administracao.funcoes', 'create', 'Criar novas funções'),
('administracao.funcoes', 'read', 'Visualizar funções'),
('administracao.funcoes', 'update', 'Editar funções'),
('administracao.funcoes', 'delete', 'Excluir funções')
ON CONFLICT (recurso, acao) DO NOTHING;

-- Reabilitar RLS
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CRIAR POLÍTICAS RLS CORRETAS
-- =====================================================

-- Permitir leitura pública de permissões (necessário para montar menus)
DROP POLICY IF EXISTS "Permitir leitura de permissoes" ON permissoes;
CREATE POLICY "Permitir leitura de permissoes"
  ON permissoes FOR SELECT
  USING (true);

-- Apenas admins podem inserir/atualizar/deletar
DROP POLICY IF EXISTS "Apenas admins gerenciam permissoes" ON permissoes;
CREATE POLICY "Apenas admins gerenciam permissoes"
  ON permissoes FOR ALL
  USING (
    auth.uid() IN (
      SELECT f.user_id 
      FROM funcionarios f
      JOIN funcao_permissoes fp ON f.funcao_id = fp.funcao_id
      JOIN permissoes p ON fp.permissao_id = p.id
      WHERE p.recurso = 'administracao' 
        AND p.acao = 'full_access'
    )
  );

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
SELECT 
  recurso as "Módulo",
  COUNT(*) as "Qtd Permissões"
FROM permissoes
GROUP BY recurso
ORDER BY recurso;

SELECT COUNT(*) as "Total de Permissões" FROM permissoes;
