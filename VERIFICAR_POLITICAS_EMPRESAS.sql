-- 🔍 VERIFICAR POLÍTICAS RLS DA TABELA EMPRESAS

-- ====================================
-- 1. VER TODAS AS POLÍTICAS
-- ====================================
SELECT 
  '📋 POLÍTICAS ATUAIS' as titulo,
  schemaname,
  tablename,
  policyname,
  permissive as permissiva,
  roles,
  cmd as operacao,
  qual as tipo,
  CASE 
    WHEN qual = 'USING' THEN 'Condição de visualização'
    WHEN qual = 'WITH CHECK' THEN 'Condição de modificação'
    ELSE 'Ambas'
  END as descricao
FROM pg_policies
WHERE tablename = 'empresas'
ORDER BY cmd, policyname;

-- ====================================
-- 2. VER DEFINIÇÃO COMPLETA DAS POLÍTICAS
-- ====================================
SELECT 
  '🔧 DEFINIÇÕES COMPLETAS' as titulo,
  pol.polname as policyname,
  pol.polcmd::text as cmd,
  pg_get_expr(pol.polqual, pol.polrelid) as using_expression,
  pg_get_expr(pol.polwithcheck, pol.polrelid) as with_check_expression
FROM pg_policy pol
JOIN pg_class pc ON pol.polrelid = pc.oid
WHERE pc.relname = 'empresas'
ORDER BY pol.polcmd, pol.polname;

-- ====================================
-- 3. VERIFICAR SE HÁ POLICIES RESTRITIVAS
-- ====================================
SELECT 
  '⚠️ POLÍTICAS RESTRITIVAS' as alerta,
  COUNT(*) as total_restritivas
FROM pg_policy pol
JOIN pg_class pc ON pol.polrelid = pc.oid
WHERE pc.relname = 'empresas'
  AND pol.polpermissive = false;

-- ====================================
-- 4. TESTAR ACESSO ATUAL
-- ====================================
-- Tenta buscar empresa (vai falhar se RLS bloquear)
SELECT 
  '🧪 TESTE ACESSO' as teste,
  COUNT(*) as total_empresas_visiveis
FROM empresas;

-- ====================================
-- 5. VER auth.uid() ATUAL
-- ====================================
SELECT 
  '🔑 AUTH CONTEXT' as info,
  auth.uid() as user_id,
  auth.role() as user_role,
  current_user as pg_user;
