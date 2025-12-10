-- =====================================================
-- 🚨 DIAGNÓSTICO PROFUNDO - POR QUE RLS NÃO FUNCIONA?
-- =====================================================
-- Maxecell ainda aparece mesmo com política restritiva
-- =====================================================

-- 1️⃣ VERIFICAR EXATAMENTE QUEM SOU EU
SELECT 
  'QUEM_SOU_EU' as teste,
  auth.uid() as meu_user_id,
  current_user as db_user,
  session_user as session_user;

-- 2️⃣ VERIFICAR SE TENHO BYPASS NO RLS (SUPER USER?)
SELECT 
  'BYPASS_CHECK' as teste,
  rolname,
  rolsuper,
  rolbypassrls
FROM pg_roles 
WHERE oid = (SELECT current_setting('request.jwt.claims')::json->>'role')::oid;

-- 3️⃣ VERIFICAR MINHAS EMPRESAS
SELECT 
  'MINHAS_EMPRESAS' as teste,
  e.id,
  e.nome,
  e.user_id
FROM empresas e
WHERE e.user_id = auth.uid();

-- 4️⃣ VERIFICAR SE A POLÍTICA ESTÁ REALMENTE ATIVA
SELECT 
  'STATUS_RLS' as teste,
  schemaname,
  tablename,
  rowsecurity as rls_ativado
FROM pg_tables 
WHERE tablename = 'fornecedores';

-- 5️⃣ VERIFICAR POLÍTICAS ATUAIS
SELECT 
  'POLITICAS_ATIVAS' as teste,
  policyname,
  permissive,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'fornecedores';

-- 6️⃣ TESTAR A LÓGICA DA POLÍTICA MANUALMENTE
SELECT 
  'TESTE_LOGICA' as teste,
  f.nome,
  f.empresa_id as fornecedor_empresa,
  (SELECT id FROM empresas WHERE user_id = auth.uid()) as minha_empresa,
  f.empresa_id = (SELECT id FROM empresas WHERE user_id = auth.uid()) as deveria_ver
FROM fornecedores f;

-- 7️⃣ VERIFICAR SE HÁ CONFLITO DE USUÁRIOS
SELECT 
  'CONFLITO_USUARIOS' as teste,
  COUNT(*) as total_empresas_minhas
FROM empresas 
WHERE user_id = auth.uid();

-- 8️⃣ TESTE EXTREMO: DESABILITAR RLS E VER DIFERENÇA
-- (CUIDADO: Isso pode mostrar tudo)
ALTER TABLE fornecedores DISABLE ROW LEVEL SECURITY;

SELECT 
  'SEM_RLS' as teste,
  COUNT(*) as total_sem_rls
FROM fornecedores;

-- REABILITAR IMEDIATAMENTE
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

SELECT 
  'COM_RLS' as teste,
  COUNT(*) as total_com_rls
FROM fornecedores;

-- 9️⃣ VERIFICAR SE AUTH.UID() ESTÁ FUNCIONANDO
SELECT 
  'AUTH_TEST' as teste,
  auth.uid() as current_auth_uid,
  CASE 
    WHEN auth.uid() IS NULL THEN 'PROBLEMA_AUTH'
    ELSE 'AUTH_OK'
  END as auth_status;

-- 🔟 VERIFICAR ROLE ESPECÍFICA
SELECT 
  'ROLE_INFO' as teste,
  current_setting('request.jwt.claims', true) as jwt_claims;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ meu_user_id deve ter valor válido
-- ✅ rolbypassrls deve ser FALSE
-- ✅ deveria_ver deve ser FALSE para Maxecell
-- ✅ total_com_rls deve ser diferente de total_sem_rls
-- =====================================================