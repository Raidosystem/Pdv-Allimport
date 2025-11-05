-- 🔧 RESTAURAR SISTEMA DE FUNÇÕES E PERMISSÕES COMPLETO
-- Este script recria todo o sistema de funções e permissões que sumiu

-- ====================================
-- 1. VERIFICAR E CRIAR TABELAS SE NÃO EXISTIREM
-- ====================================
-- Tabela de funções
CREATE TABLE IF NOT EXISTS funcoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(empresa_id, nome)
);

-- Tabela de permissões
CREATE TABLE IF NOT EXISTS permissoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome TEXT NOT NULL UNIQUE,
  modulo TEXT NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de relacionamento função-permissão
CREATE TABLE IF NOT EXISTS funcao_permissoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  funcao_id UUID NOT NULL REFERENCES funcoes(id) ON DELETE CASCADE,
  permissao_id UUID NOT NULL REFERENCES permissoes(id) ON DELETE CASCADE,
  empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(funcao_id, permissao_id)
);

-- Tabela de relacionamento funcionário-função
CREATE TABLE IF NOT EXISTS funcionario_funcoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  funcionario_id UUID NOT NULL REFERENCES funcionarios(id) ON DELETE CASCADE,
  funcao_id UUID NOT NULL REFERENCES funcoes(id) ON DELETE CASCADE,
  empresa_id UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(funcionario_id, funcao_id)
);

-- ====================================
-- 2. CRIAR PERMISSÕES PADRÃO
-- ====================================
-- Limpar permissões existentes e recriar
TRUNCATE permissoes CASCADE;

INSERT INTO permissoes (nome, modulo, descricao) VALUES
-- Módulo Dashboard
('dashboard.visualizar', 'Dashboard', 'Visualizar dashboard principal'),
('dashboard.relatorios', 'Dashboard', 'Visualizar relatórios no dashboard'),

-- Módulo Vendas
('vendas.visualizar', 'Vendas', 'Visualizar vendas'),
('vendas.criar', 'Vendas', 'Criar novas vendas'),
('vendas.editar', 'Vendas', 'Editar vendas existentes'),
('vendas.cancelar', 'Vendas', 'Cancelar vendas'),
('vendas.relatorios', 'Vendas', 'Gerar relatórios de vendas'),

-- Módulo Produtos
('produtos.visualizar', 'Produtos', 'Visualizar produtos'),
('produtos.criar', 'Produtos', 'Cadastrar novos produtos'),
('produtos.editar', 'Produtos', 'Editar produtos existentes'),
('produtos.excluir', 'Produtos', 'Excluir produtos'),
('produtos.estoque', 'Produtos', 'Gerenciar estoque'),

-- Módulo Clientes
('clientes.visualizar', 'Clientes', 'Visualizar clientes'),
('clientes.criar', 'Clientes', 'Cadastrar novos clientes'),
('clientes.editar', 'Clientes', 'Editar clientes existentes'),
('clientes.excluir', 'Clientes', 'Excluir clientes'),

-- Módulo Caixa
('caixa.visualizar', 'Caixa', 'Visualizar informações do caixa'),
('caixa.abrir', 'Caixa', 'Abrir caixa'),
('caixa.fechar', 'Caixa', 'Fechar caixa'),
('caixa.sangria', 'Caixa', 'Realizar sangria'),
('caixa.relatorios', 'Caixa', 'Gerar relatórios de caixa'),

-- Módulo Ordens de Serviço
('ordens.visualizar', 'Ordens de Serviço', 'Visualizar ordens de serviço'),
('ordens.criar', 'Ordens de Serviço', 'Criar novas ordens de serviço'),
('ordens.editar', 'Ordens de Serviço', 'Editar ordens de serviço'),
('ordens.finalizar', 'Ordens de Serviço', 'Finalizar ordens de serviço'),

-- Módulo Relatórios
('relatorios.vendas', 'Relatórios', 'Relatórios de vendas'),
('relatorios.financeiro', 'Relatórios', 'Relatórios financeiros'),
('relatorios.produtos', 'Relatórios', 'Relatórios de produtos'),
('relatorios.clientes', 'Relatórios', 'Relatórios de clientes'),

-- Módulo Configurações
('configuracoes.visualizar', 'Configurações', 'Visualizar configurações'),
('configuracoes.editar', 'Configurações', 'Editar configurações'),
('configuracoes.backup', 'Configurações', 'Realizar backup'),

-- Módulo Administração
('admin.usuarios', 'Administração', 'Gerenciar usuários'),
('admin.funcoes', 'Administração', 'Gerenciar funções e permissões'),
('admin.empresa', 'Administração', 'Gerenciar dados da empresa');

-- ====================================
-- 3. CRIAR FUNÇÕES PARA CADA EMPRESA
-- ====================================
DO $$
DECLARE
  v_empresa RECORD;
  v_admin_funcao_id UUID;
  v_gerente_funcao_id UUID;
  v_vendedor_funcao_id UUID;
  v_tecnico_funcao_id UUID;
  v_permissao RECORD;
BEGIN
  -- Para cada empresa, criar as funções padrão
  FOR v_empresa IN (SELECT id, nome FROM empresas)
  LOOP
    RAISE NOTICE 'Criando funções para empresa: %', v_empresa.nome;
    
    -- 1. FUNÇÃO ADMINISTRADOR (ACESSO TOTAL)
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      v_empresa.id,
      'Administrador',
      'Acesso total ao sistema - Gerencia todas as funcionalidades'
    )
    ON CONFLICT (empresa_id, nome) DO UPDATE SET
      descricao = EXCLUDED.descricao
    RETURNING id INTO v_admin_funcao_id;
    
    -- Dar todas as permissões ao administrador
    FOR v_permissao IN (SELECT id FROM permissoes)
    LOOP
      INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
      VALUES (v_admin_funcao_id, v_permissao.id, v_empresa.id)
      ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    END LOOP;
    
    -- 2. FUNÇÃO GERENTE
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      v_empresa.id,
      'Gerente',
      'Gerencia vendas, produtos, clientes e relatórios'
    )
    ON CONFLICT (empresa_id, nome) DO UPDATE SET
      descricao = EXCLUDED.descricao
    RETURNING id INTO v_gerente_funcao_id;
    
    -- Permissões do gerente (quase tudo, menos administração)
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_gerente_funcao_id, id, v_empresa.id
    FROM permissoes
    WHERE modulo IN ('Dashboard', 'Vendas', 'Produtos', 'Clientes', 'Caixa', 'Ordens de Serviço', 'Relatórios', 'Configurações')
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    
    -- 3. FUNÇÃO VENDEDOR
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      v_empresa.id,
      'Vendedor',
      'Realiza vendas e atende clientes'
    )
    ON CONFLICT (empresa_id, nome) DO UPDATE SET
      descricao = EXCLUDED.descricao
    RETURNING id INTO v_vendedor_funcao_id;
    
    -- Permissões do vendedor
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_vendedor_funcao_id, id, v_empresa.id
    FROM permissoes
    WHERE nome IN (
      'dashboard.visualizar',
      'vendas.visualizar', 'vendas.criar',
      'produtos.visualizar',
      'clientes.visualizar', 'clientes.criar', 'clientes.editar'
    )
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    
    -- 4. FUNÇÃO TÉCNICO
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      v_empresa.id,
      'Técnico',
      'Gerencia ordens de serviço e atendimento técnico'
    )
    ON CONFLICT (empresa_id, nome) DO UPDATE SET
      descricao = EXCLUDED.descricao
    RETURNING id INTO v_tecnico_funcao_id;
    
    -- Permissões do técnico
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    SELECT v_tecnico_funcao_id, id, v_empresa.id
    FROM permissoes
    WHERE nome IN (
      'dashboard.visualizar',
      'ordens.visualizar', 'ordens.criar', 'ordens.editar', 'ordens.finalizar',
      'produtos.visualizar',
      'clientes.visualizar', 'clientes.criar', 'clientes.editar'
    )
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    
  END LOOP;
  
  RAISE NOTICE 'Funções e permissões criadas para todas as empresas!';
END $$;

-- ====================================
-- 4. CRIAR POLÍTICAS RLS
-- ====================================
-- Habilitar RLS
ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionario_funcoes ENABLE ROW LEVEL SECURITY;

-- Políticas para funcoes
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes;
CREATE POLICY "funcoes_select_policy" ON funcoes FOR SELECT USING (true);

DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;
CREATE POLICY "funcoes_insert_policy" ON funcoes FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes;
CREATE POLICY "funcoes_update_policy" ON funcoes FOR UPDATE USING (true);

DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes;
CREATE POLICY "funcoes_delete_policy" ON funcoes FOR DELETE USING (true);

-- Políticas para permissoes
DROP POLICY IF EXISTS "permissoes_select_policy" ON permissoes;
CREATE POLICY "permissoes_select_policy" ON permissoes FOR SELECT USING (true);

-- Políticas para funcao_permissoes
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
CREATE POLICY "funcao_permissoes_select_policy" ON funcao_permissoes FOR SELECT USING (true);

DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
CREATE POLICY "funcao_permissoes_insert_policy" ON funcao_permissoes FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;
CREATE POLICY "funcao_permissoes_delete_policy" ON funcao_permissoes FOR DELETE USING (true);

-- Políticas para funcionario_funcoes
DROP POLICY IF EXISTS "funcionario_funcoes_select_policy" ON funcionario_funcoes;
CREATE POLICY "funcionario_funcoes_select_policy" ON funcionario_funcoes FOR SELECT USING (true);

DROP POLICY IF EXISTS "funcionario_funcoes_insert_policy" ON funcionario_funcoes;
CREATE POLICY "funcionario_funcoes_insert_policy" ON funcionario_funcoes FOR INSERT WITH CHECK (true);

-- ====================================
-- 5. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ FUNÇÕES CRIADAS' as info,
  COUNT(*) as total_funcoes
FROM funcoes;

SELECT 
  '✅ PERMISSÕES CRIADAS' as info,
  COUNT(*) as total_permissoes
FROM permissoes;

SELECT 
  '✅ RELACIONAMENTOS CRIADOS' as info,
  COUNT(*) as total_funcao_permissoes
FROM funcao_permissoes;

-- Mostrar funções por empresa
SELECT 
  '📊 FUNÇÕES POR EMPRESA' as info,
  e.nome as empresa,
  f.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM empresas e
JOIN funcoes f ON e.id = f.empresa_id
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY e.nome, f.nome
ORDER BY e.nome, f.nome;

-- ====================================
-- 6. MENSAGEM FINAL
-- ====================================
SELECT 
  '🎉 SISTEMA DE FUNÇÕES E PERMISSÕES RESTAURADO!' as status,
  'Agora teste a interface administrativa em Funções & Permissões' as mensagem;