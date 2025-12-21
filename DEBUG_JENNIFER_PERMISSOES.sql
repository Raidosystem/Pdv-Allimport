-- ============================================
-- CORRIGIR CRISTIANO DE NOVO + INVESTIGAR JENNIFER
-- ============================================

-- PASSO 1: Corrigir Cristiano de volta para employee
UPDATE user_approvals
SET 
  user_role = 'employee',
  updated_at = NOW()
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'; -- Cristiano

-- PASSO 2: Verificar correção
SELECT 
  '✅ VERIFICAÇÃO' as info,
  f.nome,
  f.email,
  ua.user_role,
  func.nome as funcao
FROM user_approvals ua
LEFT JOIN funcionarios f ON f.user_id = ua.user_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE ua.user_id IN (
  '23be9919-4f06-48bc-8fb6-fbb46fac8280', -- Victor
  '06b9519a-9516-4044-adf8-bdcb5d089191', -- Jennifer
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'  -- Cristiano
)
ORDER BY f.nome;

-- PASSO 3: Verificar se Jennifer tem funcao_id e permissões
SELECT 
  '🔍 JENNIFER - DEBUG' as info,
  f.id as funcionario_id,
  f.nome,
  f.funcao_id,
  func.nome as nome_funcao,
  (SELECT COUNT(*) FROM funcao_permissoes fp WHERE fp.funcao_id = f.funcao_id) as total_permissoes_funcao
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

-- PASSO 4: Ver as permissões da função Vendedor
SELECT 
  '📋 PERMISSÕES DA FUNÇÃO VENDEDOR' as info,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes func
INNER JOIN funcao_permissoes fp ON fp.funcao_id = func.id
INNER JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(func.nome) LIKE '%vendedor%'
  AND func.empresa_id IN (
    SELECT id FROM empresas WHERE email LIKE '%allimport%'
  )
ORDER BY p.recurso, p.acao;
