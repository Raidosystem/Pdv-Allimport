-- ============================================
-- ATIVAR PERMISSÕES PARA ADMIN - USUÁRIOS, CONVITES E FUNÇÕES
-- ============================================
-- Execute este script para dar permissões completas ao admin

-- 1. Verificar seu user_id atual
SELECT 
  id as user_id,
  email,
  raw_user_meta_data->>'full_name' as nome
FROM auth.users
WHERE email = 'cris-ramos30@hotmail.com';

-- 2. Verificar se você tem funcionário cadastrado
SELECT 
  f.id as funcionario_id,
  f.empresa_id,
  f.user_id,
  f.nome,
  f.status,
  e.nome as nome_empresa
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com');

-- 3. Se não existir funcionário, criar um para você
INSERT INTO funcionarios (
  empresa_id,
  user_id,
  nome,
  email,
  telefone,
  status
)
SELECT
  e.id as empresa_id,
  u.id as user_id,
  COALESCE(u.raw_user_meta_data->>'full_name', 'Administrador'),
  u.email,
  '(00) 00000-0000',
  'ativo'
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
WHERE u.email = 'cris-ramos30@hotmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM funcionarios f WHERE f.user_id = u.id
  );

-- 4. Buscar ou criar a função "Administrador"
DO $$
DECLARE
  v_empresa_id uuid;
  v_funcao_admin_id uuid;
  v_funcionario_id uuid;
BEGIN
  -- Pegar empresa do usuário
  SELECT e.id INTO v_empresa_id
  FROM empresas e
  JOIN auth.users u ON u.id = e.user_id
  WHERE u.email = 'cris-ramos30@hotmail.com';

  -- Verificar se existe função Administrador
  SELECT id INTO v_funcao_admin_id
  FROM funcoes
  WHERE empresa_id = v_empresa_id
    AND nome = 'Administrador';

  -- Se não existir, criar função Administrador
  IF v_funcao_admin_id IS NULL THEN
    INSERT INTO funcoes (
      empresa_id,
      nome,
      descricao,
      nivel,
      ativo
    ) VALUES (
      v_empresa_id,
      'Administrador',
      'Acesso total ao sistema',
      1,
      true
    ) RETURNING id INTO v_funcao_admin_id;

    RAISE NOTICE 'Função Administrador criada: %', v_funcao_admin_id;
  END IF;

  -- Pegar ID do funcionário
  SELECT f.id INTO v_funcionario_id
  FROM funcionarios f
  WHERE f.empresa_id = v_empresa_id
    AND f.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com');

  -- Atribuir função ao funcionário
  INSERT INTO funcionario_funcoes (
    funcionario_id,
    funcao_id
  ) VALUES (
    v_funcionario_id,
    v_funcao_admin_id
  )
  ON CONFLICT (funcionario_id, funcao_id) DO NOTHING;

  RAISE NOTICE 'Função Administrador atribuída ao funcionário: %', v_funcionario_id;
END $$;

-- 5. Criar permissões necessárias para a função Administrador
DO $$
DECLARE
  v_empresa_id uuid;
  v_funcao_admin_id uuid;
  v_permissoes text[] := ARRAY[
    'administracao.dashboard:read',
    'administracao.usuarios:create',
    'administracao.usuarios:read',
    'administracao.usuarios:update',
    'administracao.usuarios:delete',
    'administracao.usuarios:invite',
    'administracao.funcoes:create',
    'administracao.funcoes:read',
    'administracao.funcoes:update',
    'administracao.funcoes:delete',
    'administracao.permissoes:read',
    'administracao.permissoes:update',
    'administracao.backups:read',
    'administracao.backups:create',
    'administracao.sistema:read',
    'administracao.sistema:update',
    'vendas:create',
    'vendas:read',
    'vendas:update',
    'vendas:delete',
    'produtos:create',
    'produtos:read',
    'produtos:update',
    'produtos:delete',
    'clientes:create',
    'clientes:read',
    'clientes:update',
    'clientes:delete',
    'caixa:abrir',
    'caixa:fechar',
    'caixa:sangria',
    'caixa:suprimento',
    'relatorios:vendas',
    'relatorios:financeiro',
    'relatorios:estoque'
  ];
  v_permissao text;
BEGIN
  -- Pegar empresa e função
  SELECT e.id INTO v_empresa_id
  FROM empresas e
  JOIN auth.users u ON u.id = e.user_id
  WHERE u.email = 'cris-ramos30@hotmail.com';

  SELECT id INTO v_funcao_admin_id
  FROM funcoes
  WHERE empresa_id = v_empresa_id
    AND nome = 'Administrador';

  -- Criar cada permissão
  FOREACH v_permissao IN ARRAY v_permissoes
  LOOP
    INSERT INTO funcao_permissoes (
      funcao_id,
      recurso,
      acao,
      escopo
    ) VALUES (
      v_funcao_admin_id,
      split_part(v_permissao, ':', 1),
      split_part(v_permissao, ':', 2),
      'empresa'
    )
    ON CONFLICT (funcao_id, recurso, acao) DO UPDATE
    SET escopo = 'empresa';
  END LOOP;

  RAISE NOTICE 'Permissões criadas para função Administrador';
END $$;

-- 6. VERIFICAR RESULTADO FINAL
SELECT 
  f.nome as funcionario_nome,
  f.email,
  f.status,
  func.nome as funcao,
  func.nivel,
  COUNT(fp.id) as total_permissoes
FROM funcionarios f
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com')
GROUP BY f.id, f.nome, f.email, f.status, func.nome, func.nivel;

-- 7. LISTAR TODAS AS PERMISSÕES DO ADMIN
SELECT 
  fp.recurso,
  fp.acao,
  fp.escopo,
  func.nome as funcao
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN funcionario_funcoes ff ON ff.funcao_id = func.id
JOIN funcionarios f ON f.id = ff.funcionario_id
WHERE f.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com')
ORDER BY fp.recurso, fp.acao;
