-- ============================================
-- ATIVAR PERMISSÕES ADMIN PARA TODOS OS USUÁRIOS
-- ============================================
-- Este script configura permissões completas para TODOS os usuários
-- (existentes e futuros via trigger)

-- 1. GARANTIR ESTRUTURA DA TABELA PERMISSOES
DO $$ 
BEGIN
  -- Adicionar coluna categoria se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'permissoes' 
    AND column_name = 'categoria'
  ) THEN
    ALTER TABLE permissoes ADD COLUMN categoria text NOT NULL DEFAULT 'geral';
    RAISE NOTICE '✅ Coluna categoria adicionada à tabela permissoes';
  END IF;
END $$;

-- 2. GARANTIR QUE PERMISSÕES EXISTEM NO CATÁLOGO
INSERT INTO permissoes (recurso, acao, descricao, categoria) VALUES
  ('administracao.dashboard', 'read', 'Visualizar dashboard administrativo', 'administracao'),
  ('administracao.usuarios', 'create', 'Criar usuários', 'administracao'),
  ('administracao.usuarios', 'read', 'Visualizar usuários', 'administracao'),
  ('administracao.usuarios', 'update', 'Editar usuários', 'administracao'),
  ('administracao.usuarios', 'delete', 'Excluir usuários', 'administracao'),
  ('administracao.usuarios', 'invite', 'Convidar usuários', 'administracao'),
  ('administracao.funcoes', 'create', 'Criar funções', 'administracao'),
  ('administracao.funcoes', 'read', 'Visualizar funções', 'administracao'),
  ('administracao.funcoes', 'update', 'Editar funções', 'administracao'),
  ('administracao.funcoes', 'delete', 'Excluir funções', 'administracao'),
  ('administracao.permissoes', 'read', 'Visualizar permissões', 'administracao'),
  ('administracao.permissoes', 'update', 'Gerenciar permissões', 'administracao'),
  ('administracao.backups', 'read', 'Visualizar backups', 'administracao'),
  ('administracao.backups', 'create', 'Criar backups', 'administracao'),
  ('administracao.sistema', 'read', 'Visualizar configurações do sistema', 'administracao'),
  ('administracao.sistema', 'update', 'Editar configurações do sistema', 'administracao'),
  ('vendas', 'create', 'Criar vendas', 'vendas'),
  ('vendas', 'read', 'Visualizar vendas', 'vendas'),
  ('vendas', 'update', 'Editar vendas', 'vendas'),
  ('vendas', 'delete', 'Excluir vendas', 'vendas'),
  ('produtos', 'create', 'Criar produtos', 'produtos'),
  ('produtos', 'read', 'Visualizar produtos', 'produtos'),
  ('produtos', 'update', 'Editar produtos', 'produtos'),
  ('produtos', 'delete', 'Excluir produtos', 'produtos'),
  ('clientes', 'create', 'Criar clientes', 'clientes'),
  ('clientes', 'read', 'Visualizar clientes', 'clientes'),
  ('clientes', 'update', 'Editar clientes', 'clientes'),
  ('clientes', 'delete', 'Excluir clientes', 'clientes'),
  ('caixa', 'abrir', 'Abrir caixa', 'caixa'),
  ('caixa', 'fechar', 'Fechar caixa', 'caixa'),
  ('caixa', 'sangria', 'Fazer sangria', 'caixa'),
  ('caixa', 'suprimento', 'Fazer suprimento', 'caixa'),
  ('relatorios', 'vendas', 'Visualizar relatórios de vendas', 'relatorios'),
  ('relatorios', 'financeiro', 'Visualizar relatórios financeiros', 'relatorios'),
  ('relatorios', 'estoque', 'Visualizar relatórios de estoque', 'relatorios')
ON CONFLICT (recurso, acao) DO NOTHING;

-- 3. CRIAR FUNÇÃO PARA CONFIGURAR ADMIN AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION setup_admin_permissions_for_user(p_user_id uuid)
RETURNS void AS $$
DECLARE
  v_empresa_id uuid;
  v_funcao_admin_id uuid;
  v_funcionario_id uuid;
  v_permissao_id uuid;
  v_user_email text;
  v_count integer := 0;
BEGIN
  -- Pegar email do usuário para logs
  SELECT email INTO v_user_email FROM auth.users WHERE id = p_user_id;

  -- Pegar empresa do usuário
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = p_user_id;

  IF v_empresa_id IS NULL THEN
    RAISE NOTICE 'Usuário % não tem empresa cadastrada ainda', v_user_email;
    RETURN;
  END IF;

  -- Criar funcionário se não existir
  INSERT INTO funcionarios (
    empresa_id,
    user_id,
    nome,
    email,
    telefone,
    status
  )
  SELECT
    v_empresa_id,
    u.id,
    COALESCE(u.raw_user_meta_data->>'full_name', 'Administrador'),
    u.email,
    COALESCE(u.phone, '(00) 00000-0000'),
    'ativo'
  FROM auth.users u
  WHERE u.id = p_user_id
  ON CONFLICT (empresa_id, user_id) DO UPDATE
  SET status = 'ativo';

  -- Pegar ID do funcionário
  SELECT id INTO v_funcionario_id
  FROM funcionarios
  WHERE empresa_id = v_empresa_id
    AND user_id = p_user_id;

  -- Verificar se existe função Administrador para esta empresa
  SELECT id INTO v_funcao_admin_id
  FROM funcoes
  WHERE empresa_id = v_empresa_id
    AND nome = 'Administrador';

  -- Se não existir, criar função Administrador
  IF v_funcao_admin_id IS NULL THEN
    INSERT INTO funcoes (
      empresa_id,
      nome,
      descricao
    ) VALUES (
      v_empresa_id,
      'Administrador',
      'Acesso total ao sistema'
    ) RETURNING id INTO v_funcao_admin_id;

    RAISE NOTICE 'Função Administrador criada para empresa: %', v_empresa_id;
  END IF;

  -- Atribuir função ao funcionário
  INSERT INTO funcionario_funcoes (
    funcionario_id,
    funcao_id,
    empresa_id
  ) VALUES (
    v_funcionario_id,
    v_funcao_admin_id,
    v_empresa_id
  )
  ON CONFLICT (funcionario_id, funcao_id) DO NOTHING;

  -- Adicionar TODAS as permissões do catálogo à função
  FOR v_permissao_id IN 
    SELECT id FROM permissoes
  LOOP
    INSERT INTO funcao_permissoes (
      funcao_id,
      permissao_id,
      empresa_id
    ) VALUES (
      v_funcao_admin_id,
      v_permissao_id,
      v_empresa_id
    )
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    
    v_count := v_count + 1;
  END LOOP;

  RAISE NOTICE '✅ Permissões configuradas para usuário: % (empresa: %, % permissões)', v_user_email, v_empresa_id, v_count;
END;
$$ LANGUAGE plpgsql;

-- 4. CRIAR TRIGGER PARA NOVOS USUÁRIOS
CREATE OR REPLACE FUNCTION auto_setup_admin_on_empresa_created()
RETURNS TRIGGER AS $$
BEGIN
  -- Aguardar 1 segundo para garantir que empresa foi criada
  PERFORM pg_sleep(1);
  
  -- Configurar permissões automaticamente
  PERFORM setup_admin_permissions_for_user(NEW.user_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger se já existir
DROP TRIGGER IF EXISTS trigger_auto_setup_admin ON empresas;

-- Criar trigger que dispara quando uma empresa é criada
CREATE TRIGGER trigger_auto_setup_admin
  AFTER INSERT ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION auto_setup_admin_on_empresa_created();

-- 5. APLICAR PARA TODOS OS USUÁRIOS EXISTENTES
DO $$
DECLARE
  v_user RECORD;
  v_total_users INT := 0;
  v_success_count INT := 0;
BEGIN
  RAISE NOTICE '🚀 Iniciando configuração de permissões para todos os usuários...';
  
  FOR v_user IN 
    SELECT u.id, u.email
    FROM auth.users u
    JOIN empresas e ON e.user_id = u.id
    ORDER BY u.created_at
  LOOP
    BEGIN
      PERFORM setup_admin_permissions_for_user(v_user.id);
      v_success_count := v_success_count + 1;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro ao configurar usuário %: %', v_user.email, SQLERRM;
    END;
    
    v_total_users := v_total_users + 1;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Configuração concluída!';
  RAISE NOTICE '   Total de usuários processados: %', v_total_users;
  RAISE NOTICE '   Configurados com sucesso: %', v_success_count;
  RAISE NOTICE '   Falhas: %', v_total_users - v_success_count;
END $$;

-- 6. VERIFICAR RESULTADO - TODOS OS USUÁRIOS
SELECT 
  u.email as usuario_email,
  e.nome as empresa,
  f.nome as funcionario_nome,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  CASE 
    WHEN COUNT(DISTINCT fp.permissao_id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(DISTINCT fp.permissao_id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY u.id, u.email, e.nome, f.nome, func.nome
ORDER BY u.created_at DESC;

-- 7. RESUMO GERAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT f.id) as total_funcionarios,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT p.id) as total_permissoes_catalogo,
  COUNT(DISTINCT fp.funcao_id) as funcoes_com_permissoes
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
CROSS JOIN permissoes p;

-- 8. LISTAR PERMISSÕES DE CADA USUÁRIO
SELECT 
  u.email,
  p.recurso,
  p.acao,
  p.categoria,
  p.descricao
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
ORDER BY u.email, p.categoria, p.recurso, p.acao;

-- 7. RESUMO GERAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT f.id) as total_funcionarios,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT p.id) as total_permissoes_catalogo,
  COUNT(DISTINCT fp.funcao_id) as funcoes_com_permissoes
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
CROSS JOIN permissoes p;

-- 8. LISTAR PERMISSÕES DE CADA USUÁRIO
SELECT 
  u.email,
  p.recurso,
  p.acao,
  p.categoria,
  p.descricao
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
ORDER BY u.email, p.categoria, p.recurso, p.acao;
