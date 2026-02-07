-- =====================================================
-- 🔍 DIAGNÓSTICO COMPLETO - JENNIFER E PERMISSÕES DE OS
-- =====================================================

-- 1. VERIFICAR SE JENNIFER EXISTE NA TABELA FUNCIONARIOS
-- =====================================================
SELECT 
  '👤 JENNIFER - DADOS BÁSICOS' as secao,
  id,
  nome,
  email,
  user_id,
  empresa_id,
  funcao_id,
  tipo_admin,
  ativo,
  status,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  created_at
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%'
ORDER BY created_at DESC;

-- 2. VERIFICAR PERMISSÕES JSONB DE JENNIFER
-- =====================================================
SELECT 
  '📦 JENNIFER - PERMISSÕES JSONB' as secao,
  nome,
  permissoes,
  CASE 
    WHEN permissoes->>'ordens_servico' = 'true' THEN '✅ OS ATIVO'
    ELSE '❌ OS INATIVO'
  END as status_os,
  permissoes->>'vendas' as vendas,
  permissoes->>'produtos' as produtos,
  permissoes->>'clientes' as clientes
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%';

-- 3. VERIFICAR FUNÇÃO DE JENNIFER
-- =====================================================
SELECT 
  '🎭 JENNIFER - FUNÇÃO' as secao,
  f.nome as funcionario,
  func.id as funcao_id,
  func.nome as funcao_nome,
  func.descricao,
  func.nivel,
  func.empresa_id
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE LOWER(f.nome) LIKE '%jennifer%';

-- 4. VERIFICAR PERMISSÕES DA FUNÇÃO DE JENNIFER
-- =====================================================
SELECT 
  '🔑 JENNIFER - PERMISSÕES DA FUNÇÃO' as secao,
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao,
  p.modulo
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
WHERE LOWER(f.nome) LIKE '%jennifer%'
  AND (p.recurso = 'ordens_servico' OR p.modulo = 'ordens_servico')
ORDER BY p.acao;

-- 5. VERIFICAR TODAS AS PERMISSÕES DE OS NO SISTEMA
-- =====================================================
SELECT 
  '📋 PERMISSÕES DE OS DISPONÍVEIS' as secao,
  id,
  recurso,
  acao,
  descricao,
  modulo
FROM permissoes
WHERE recurso = 'ordens_servico' OR modulo = 'ordens_servico'
ORDER BY acao;

-- 6. VERIFICAR EMPRESA DE JENNIFER
-- =====================================================
SELECT 
  '🏢 JENNIFER - EMPRESA' as secao,
  e.id,
  e.nome,
  e.email,
  e.user_id,
  COUNT(f.id) as total_funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
WHERE e.email = 'assistenciaallimport10@gmail.com'
GROUP BY e.id, e.nome, e.email, e.user_id;

-- 7. VERIFICAR USUÁRIO AUTH DE JENNIFER
-- =====================================================
SELECT 
  '🔐 JENNIFER - AUTH USER' as secao,
  f.nome as funcionario,
  f.user_id,
  au.email as auth_email,
  au.created_at as auth_criado_em,
  au.last_sign_in_at as ultimo_login
FROM funcionarios f
LEFT JOIN auth.users au ON f.user_id = au.id
WHERE LOWER(f.nome) LIKE '%jennifer%';

-- =====================================================
-- 💡 DIAGNÓSTICO ESPERADO:
-- =====================================================
-- 
-- Se Jennifer NÃO aparece no login:
-- ❌ usuario_ativo = false ou NULL
-- ❌ senha_definida = false ou NULL
-- ❌ status != 'ativo'
-- 
-- Se OS não aparece no menu de Jennifer:
-- ❌ permissoes->>'ordens_servico' != 'true'
-- ❌ funcao_id sem permissões de OS
-- ❌ funcao_permissoes não tem ordens_servico:read
-- 
-- =====================================================
