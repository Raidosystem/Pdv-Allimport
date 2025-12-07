-- =====================================================
-- GERAR/VERIFICAR LOGIN PARA JENNIFER
-- =====================================================

-- 1️⃣ VERIFICAR SE JENNIFER TEM USER_ID (AUTH)
SELECT 
  '🔍 VERIFICAR AUTH' as info,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ SEM AUTH (não pode logar)'
    ELSE '✅ TEM AUTH (pode logar)'
  END as status_auth,
  au.email as auth_email,
  au.email_confirmed_at,
  au.last_sign_in_at
FROM funcionarios f
LEFT JOIN auth.users au ON f.user_id = au.id
WHERE f.email = 'jennifer_sousa@temp.local';

-- 2️⃣ VERIFICAR STATUS ATUAL
SELECT 
  '📊 STATUS ATUAL' as info,
  f.nome,
  f.email,
  f.status,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'jennifer_sousa@temp.local'
GROUP BY f.id, f.nome, f.email, f.status, f.tipo_admin, func.nome;

-- =====================================================
-- ⚠️ IMPORTANTE: CREDENCIAIS DE TESTE
-- =====================================================
-- Para testar a Jennifer, você precisa:
-- 
-- 1. FAZER LOGOUT da sua conta atual (assistenciaallimport10@gmail.com)
-- 2. LOGAR com: jennifer_sousa@temp.local / [senha que você definiu]
-- 
-- Se Jennifer não tem user_id (auth), ela NÃO pode fazer login ainda.
-- Você precisaria criar um usuário auth para ela no Supabase Dashboard.
-- =====================================================

-- 3️⃣ LISTAR TODOS OS FUNCIONÁRIOS COM STATUS AUTH
SELECT 
  '👥 TODOS FUNCIONÁRIOS' as info,
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ SEM LOGIN'
    ELSE '✅ PODE LOGAR'
  END as pode_logar,
  f.status
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE f.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'jennifer_sousa@temp.local' LIMIT 1
)
ORDER BY f.nome;

-- =====================================================
-- 📝 COMO CRIAR LOGIN PARA JENNIFER (se não tiver)
-- =====================================================
-- 
-- 1. Acesse o Supabase Dashboard
-- 2. Vá em Authentication > Users
-- 3. Clique em "Add User"
-- 4. Preencha:
--    - Email: jennifer_sousa@temp.local
--    - Password: [defina uma senha]
--    - Auto Confirm User: ✅ ATIVADO
-- 
-- 5. Após criar, copie o user_id e rode:
-- 
-- UPDATE funcionarios
-- SET user_id = '[user_id_copiado_do_supabase]'
-- WHERE email = 'jennifer_sousa@temp.local';
-- 
-- =====================================================
