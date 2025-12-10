-- ============================================
-- DIAGNOSTICAR PERMISSÕES DO USUÁRIO LOGADO
-- ============================================

-- 1. Verificar usuário atual (substitua pelo email que você está usando)
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
OR email = 'cris-ramos30@hotmail.com';

-- 2. Verificar empresa do usuário
SELECT 
  e.id as empresa_id,
  e.nome as empresa_nome,
  e.user_id,
  u.email
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
OR u.email = 'cris-ramos30@hotmail.com';

-- 3. Verificar funcionário do usuário
SELECT 
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  f.empresa_id,
  f.status,
  f.tipo_admin,
  u.email as user_email
FROM funcionarios f
JOIN auth.users u ON u.id = f.user_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
OR u.email = 'cris-ramos30@hotmail.com';

-- 4. Verificar funções atribuídas ao funcionário
SELECT 
  u.email,
  f.nome as funcionario_nome,
  func.nome as funcao_nome,
  func.id as funcao_id
FROM auth.users u
JOIN funcionarios f ON f.user_id = u.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
OR u.email = 'cris-ramos30@hotmail.com';

-- 5. Verificar permissões da função
SELECT 
  u.email,
  func.nome as funcao,
  p.recurso,
  p.acao,
  fp.permissao as permissao_texto
FROM auth.users u
JOIN funcionarios f ON f.user_id = u.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
OR u.email = 'cris-ramos30@hotmail.com'
ORDER BY u.email, p.recurso, p.acao;

-- 6. TESTE DA QUERY QUE O HOOK USA (corrigida)
SELECT 
  f.id,
  f.empresa_id,
  f.nome,
  f.status,
  f.tipo_admin,
  f.lojas
FROM funcionarios f
JOIN auth.users u ON u.id = f.user_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
AND f.status = 'ativo';

-- 7. ESTRUTURA COMPLETA ESPERADA PELO HOOK
SELECT 
  f.id as funcionario_id,
  f.empresa_id,
  f.nome,
  f.status,
  f.tipo_admin,
  f.lojas,
  ff.funcao_id,
  func.nome as funcao_nome,
  fp.permissao_id,
  p.recurso,
  p.acao,
  fp.permissao as permissao_formatada
FROM funcionarios f
JOIN auth.users u ON u.id = f.user_id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE u.email = 'admin@pdv.com' -- MUDE PARA SEU EMAIL
AND f.status = 'ativo'
ORDER BY p.recurso, p.acao;
