-- ============================================================================
-- BUSCAR TODOS OS EMAILS CADASTRADOS NO SISTEMA
-- ============================================================================
-- Verificar auth.users vs user_approvals para encontrar quem está faltando
-- ============================================================================

-- 1. TODOS os usuários em auth.users (tabela de autenticação)
SELECT 
  id as user_id,
  email,
  email_confirmed_at,
  created_at,
  'auth.users' as origem
FROM auth.users
ORDER BY created_at DESC;

-- 2. TODOS os usuários em user_approvals
SELECT 
  user_id,
  email,
  user_role,
  status,
  created_at,
  'user_approvals' as origem
FROM user_approvals
ORDER BY created_at DESC;

-- 3. Comparar: Usuários em auth.users que NÃO estão em user_approvals
SELECT 
  au.id as user_id,
  au.email,
  au.created_at,
  'FALTA em user_approvals' as problema
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM user_approvals ua 
  WHERE ua.user_id = au.id
)
ORDER BY au.created_at DESC;

-- 4. Contar totais
SELECT 
  'auth.users (total de contas)' as tabela,
  COUNT(*) as total
FROM auth.users
UNION ALL
SELECT 
  'user_approvals (cadastrados)',
  COUNT(*)
FROM user_approvals
UNION ALL
SELECT 
  'Diferença (faltando)',
  (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM user_approvals);
