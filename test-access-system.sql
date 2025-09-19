-- Script de Teste Completo do Sistema de Acesso
-- Execute no SQL Editor do Supabase para verificar se tudo está funcionando

-- 1. VERIFICAR ESTRUTURA DAS TABELAS
SELECT 'Verificando estrutura das tabelas...' as status;

-- Verificar se todas as tabelas existem
SELECT 
  schemaname, 
  tablename, 
  tableowner 
FROM pg_tables 
WHERE tablename IN ('empresas', 'funcionarios', 'funcoes', 'permissoes', 'funcionario_funcoes', 'funcao_permissoes')
ORDER BY tablename;

-- 2. VERIFICAR USUÁRIOS AUTENTICADOS
SELECT 'Verificando usuários autenticados...' as status;

SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.tipo_admin,
  f.status,
  e.nome as empresa_nome
FROM auth.users u
LEFT JOIN funcionarios f ON u.id = f.user_id
LEFT JOIN empresas e ON f.empresa_id = e.id
ORDER BY u.created_at DESC;

-- 3. VERIFICAR ESTRUTURA DE PERMISSÕES
SELECT 'Verificando permissões base...' as status;

SELECT 
  modulo,
  acao,
  descricao
FROM permissoes
ORDER BY modulo, acao;

-- 4. VERIFICAR FUNÇÕES E SUAS PERMISSÕES
SELECT 'Verificando funções configuradas...' as status;

SELECT 
  e.nome as empresa,
  f.nome as funcao,
  f.descricao,
  f.is_system,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcoes f
JOIN empresas e ON f.empresa_id = e.id
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY e.nome, f.nome, f.descricao, f.is_system
ORDER BY e.nome, f.nome;

-- 5. VERIFICAR FUNCIONÁRIOS E SUAS FUNÇÕES
SELECT 'Verificando funcionários e funções...' as status;

SELECT 
  f.nome as funcionario,
  f.email,
  f.tipo_admin,
  f.status,
  e.nome as empresa,
  fn.nome as funcao,
  COUNT(fp.permissao_id) as permissoes_na_funcao
FROM funcionarios f
JOIN empresas e ON f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
LEFT JOIN funcoes fn ON ff.funcao_id = fn.id
LEFT JOIN funcao_permissoes fp ON fn.id = fp.funcao_id
GROUP BY f.nome, f.email, f.tipo_admin, f.status, e.nome, fn.nome
ORDER BY f.nome;

-- 6. TESTE DE PERMISSÕES POR USUÁRIO
SELECT 'Testando permissões por usuário...' as status;

SELECT 
  u.email as usuario_email,
  f.nome as funcionario_nome,
  f.tipo_admin,
  p.modulo,
  p.acao,
  p.descricao as permissao_descricao
FROM auth.users u
JOIN funcionarios f ON u.id = f.user_id
LEFT JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
LEFT JOIN funcao_permissoes fp ON ff.funcao_id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.status = 'ativo'
ORDER BY u.email, p.modulo, p.acao;

-- 7. VERIFICAR ADMIN_EMPRESA
SELECT 'Verificando usuários admin_empresa...' as status;

SELECT 
  u.email,
  f.nome,
  f.tipo_admin,
  f.status,
  e.nome as empresa,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '✅ É admin da empresa'
    WHEN f.tipo_admin = 'super_admin' THEN '✅ É super admin'
    ELSE '❌ Não é admin'
  END as status_admin
FROM auth.users u
JOIN funcionarios f ON u.id = f.user_id
JOIN empresas e ON f.empresa_id = e.id
ORDER BY f.tipo_admin DESC, u.email;

-- 8. VERIFICAR INTEGRIDADE DOS DADOS
SELECT 'Verificando integridade dos dados...' as status;

-- Usuários sem funcionário
SELECT 
  'Usuários sem funcionário' as tipo_problema,
  COUNT(*) as quantidade
FROM auth.users u
LEFT JOIN funcionarios f ON u.id = f.user_id
WHERE f.id IS NULL;

-- Funcionários sem função
SELECT 
  'Funcionários sem função' as tipo_problema,
  COUNT(*) as quantidade
FROM funcionarios f
LEFT JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
WHERE ff.funcionario_id IS NULL AND f.status = 'ativo';

-- Funções sem permissões
SELECT 
  'Funções sem permissões' as tipo_problema,
  COUNT(*) as quantidade
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
WHERE fp.funcao_id IS NULL;

-- 9. RESULTADO FINAL
SELECT 'RESULTADO FINAL - Status do Sistema' as status;

SELECT 
  CASE 
    WHEN (
      SELECT COUNT(*) FROM empresas
    ) = 0 THEN '❌ Nenhuma empresa cadastrada'
    WHEN (
      SELECT COUNT(*) 
      FROM auth.users u
      JOIN funcionarios f ON u.id = f.user_id
      WHERE f.tipo_admin IN ('admin_empresa', 'super_admin')
    ) = 0 THEN '❌ Nenhum administrador configurado'
    WHEN (
      SELECT COUNT(*)
      FROM funcoes f
      JOIN funcao_permissoes fp ON f.id = fp.funcao_id
      WHERE f.nome = 'Administrador'
    ) = 0 THEN '❌ Função Administrador não configurada'
    ELSE '✅ Sistema configurado corretamente'
  END as status_geral;

-- 10. SUGESTÕES DE CORREÇÃO
SELECT 'Sugestões de correção...' as status;

SELECT 
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM empresas) THEN 
      'Execute: INSERT INTO empresas (nome, cnpj, telefone, email) VALUES (''Allimport'', ''00.000.000/0001-00'', ''(00) 0000-0000'', ''admin@allimport.com'');'
    WHEN EXISTS (
      SELECT 1 FROM auth.users u
      LEFT JOIN funcionarios f ON u.id = f.user_id
      WHERE f.id IS NULL
    ) THEN 
      'Existem usuários sem registro de funcionário. Use o AccessFixer no frontend.'
    WHEN EXISTS (
      SELECT 1 FROM funcionarios f
      WHERE f.tipo_admin = 'funcionario' AND f.status = 'ativo'
      AND NOT EXISTS (
        SELECT 1 FROM funcionario_funcoes ff
        JOIN funcoes fn ON ff.funcao_id = fn.id
        WHERE ff.funcionario_id = f.id AND fn.nome = 'Administrador'
      )
    ) THEN
      'Existem funcionários que deveriam ser admin. Use o AccessFixer no frontend.'
    ELSE
      'Sistema parece estar funcionando corretamente!'
  END as sugestao;