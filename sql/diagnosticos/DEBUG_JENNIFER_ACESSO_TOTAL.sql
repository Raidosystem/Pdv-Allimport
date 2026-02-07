-- ============================================
-- DEBUG JENNIFER - POR QUE TEM ACESSO TOTAL?
-- ============================================

-- PASSO 1: Verificar user_role de Jennifer
SELECT 
  '1️⃣ USER_ROLE DE JENNIFER' as passo,
  ua.email,
  ua.user_role,
  CASE 
    WHEN ua.user_role = 'owner' THEN '❌ PROBLEMA - É OWNER'
    WHEN ua.user_role = 'employee' THEN '✅ CORRETO - É EMPLOYEE'
    ELSE '⚠️ OUTRO VALOR'
  END as status
FROM user_approvals ua
WHERE ua.email = 'sousajenifer895@gmail.com';

-- PASSO 2: Verificar se Jennifer está em funcionarios
SELECT 
  '2️⃣ JENNIFER EM FUNCIONARIOS' as passo,
  f.id,
  f.nome,
  f.email,
  f.user_id,
  f.funcao_id,
  func.nome as funcao_nome,
  f.empresa_id
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- PASSO 3: Contar permissões da função Vendedor
SELECT 
  '3️⃣ TOTAL PERMISSÕES VENDEDOR' as passo,
  func.nome,
  COUNT(fp.id) as total_permissoes,
  CASE 
    WHEN COUNT(fp.id) <= 10 THEN '✅ Vendedor básico (correto)'
    WHEN COUNT(fp.id) > 30 THEN '❌ Muitas permissões (quase admin)'
    ELSE '⚠️ Verificar'
  END as status
FROM funcoes func
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE LOWER(func.nome) LIKE '%vendedor%'
  AND func.empresa_id IN (
    SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
  )
GROUP BY func.id, func.nome;

-- PASSO 4: Listar TODAS as permissões da função Vendedor
SELECT 
  '4️⃣ PERMISSÕES DETALHADAS' as passo,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes func
INNER JOIN funcao_permissoes fp ON fp.funcao_id = func.id
INNER JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(func.nome) LIKE '%vendedor%'
  AND func.empresa_id IN (
    SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
  )
ORDER BY p.recurso, p.acao;

-- PASSO 5: Verificar se há algum primeiro funcionário (is_admin_empresa)
SELECT 
  '5️⃣ VERIFICAR IS_ADMIN_EMPRESA' as passo,
  f.nome,
  f.email,
  CASE 
    WHEN f.created_at = (
      SELECT MIN(f2.created_at) 
      FROM funcionarios f2 
      WHERE f2.empresa_id = f.empresa_id
    ) THEN '👑 PRIMEIRO FUNCIONÁRIO (pode ter flag admin_empresa)'
    ELSE '👤 Funcionário normal'
  END as tipo
FROM funcionarios f
WHERE f.empresa_id IN (
  SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
)
ORDER BY f.created_at;
