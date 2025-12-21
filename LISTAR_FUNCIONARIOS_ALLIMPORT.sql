-- ============================================
-- LISTAR TODOS OS FUNCIONÁRIOS DA ALLIMPORT
-- ============================================
-- Execute este SQL PRIMEIRO antes de fazer qualquer alteração

-- PASSO 1: Encontrar a empresa Allimport
SELECT 
  '🏢 EMPRESA ALLIMPORT' as info,
  id as empresa_id,
  nome,
  email,
  created_at
FROM empresas
WHERE LOWER(email) LIKE '%allimport%' OR LOWER(nome) LIKE '%allimport%';

-- PASSO 2: Listar TODOS os funcionários da Allimport
SELECT 
  '👥 FUNCIONÁRIOS DA ALLIMPORT' as info,
  f.id,
  f.nome,
  f.email,
  f.user_id,
  f.ativo,
  f.status,
  f.usuario_ativo,
  f.senha_definida,
  func.nome as funcao,
  ua.user_role as role_em_approvals,
  ua.status as status_approval,
  CASE 
    WHEN ua.user_role = 'owner' THEN '👑 OWNER (Permissões Totais)'
    WHEN ua.user_role = 'employee' THEN '👤 EMPLOYEE (Permissões da Função)'
    WHEN ua.user_role IS NULL THEN '⚠️ SEM REGISTRO EM user_approvals'
    ELSE ua.user_role
  END as tipo_acesso,
  f.created_at
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN user_approvals ua ON ua.user_id = f.user_id
WHERE f.empresa_id IN (
  SELECT id FROM empresas 
  WHERE LOWER(email) LIKE '%allimport%' OR LOWER(nome) LIKE '%allimport%'
)
ORDER BY f.created_at DESC;

-- PASSO 3: Ver quantos estão marcados incorretamente como OWNER
SELECT 
  '🚨 FUNCIONÁRIOS MARCADOS COMO OWNER (DEVE SER EMPLOYEE)' as alerta,
  COUNT(*) as total
FROM funcionarios f
INNER JOIN user_approvals ua ON ua.user_id = f.user_id
WHERE f.empresa_id IN (
  SELECT id FROM empresas 
  WHERE LOWER(email) LIKE '%allimport%' OR LOWER(nome) LIKE '%allimport%'
)
AND ua.user_role = 'owner';

-- PASSO 4: Ver quem realmente DEVERIA ser owner (dono da empresa)
SELECT 
  '👑 VERDADEIRO DONO DA EMPRESA' as info,
  e.nome as empresa,
  e.email as email_empresa,
  au.email as email_auth,
  au.id as user_id,
  ua.user_role as role_atual,
  CASE 
    WHEN e.user_id = au.id THEN '✅ É O DONO'
    ELSE '❌ NÃO É O DONO'
  END as verificacao
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
LEFT JOIN user_approvals ua ON ua.user_id = e.user_id
WHERE LOWER(e.email) LIKE '%allimport%' OR LOWER(e.nome) LIKE '%allimport%';

-- RESULTADO ESPERADO:
-- 1. Ver todos os funcionários da Allimport
-- 2. Identificar quem está como 'owner' mas é funcionário
-- 3. Identificar quem é o verdadeiro dono
-- 4. ME MOSTRE OS RESULTADOS ANTES DE CORRIGIR QUALQUER COISA
