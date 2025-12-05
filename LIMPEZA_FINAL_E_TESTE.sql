-- ================================================
-- LIMPEZA FINAL E TESTE COMPLETO
-- ================================================

-- 1️⃣ REMOVER USUÁRIOS DELETADOS DE USER_APPROVALS
DELETE FROM public.user_approvals
WHERE email LIKE 'DELETED_%@deleted.invalid';

-- 2️⃣ VERIFICAR CONTAGENS FINAIS
SELECT 
  '2. CONTAGEM FINAL' as etapa,
  (SELECT COUNT(*) FROM public.subscriptions WHERE email NOT LIKE 'DELETED_%') as total_subscriptions,
  (SELECT COUNT(*) FROM public.user_approvals WHERE email NOT LIKE 'DELETED_%') as total_approvals;

-- 3️⃣ LISTAR TODAS AS ASSINATURAS FINAIS (ADMIN DEVE VER TODAS)
SELECT 
  '3. ASSINATURAS FINAIS' as etapa,
  s.email,
  s.status,
  s.plan_type,
  TO_CHAR(s.created_at, 'DD/MM/YYYY HH24:MI') as cadastro,
  CASE 
    WHEN s.created_at::date = CURRENT_DATE THEN '🆕 HOJE'
    ELSE '📅 ' || (CURRENT_DATE - s.created_at::date) || ' dias'
  END as quando
FROM public.subscriptions s
WHERE s.email NOT LIKE 'DELETED_%'
ORDER BY s.created_at DESC;

-- 4️⃣ LISTAR TODOS OS USER_APPROVALS (ADMIN DEVE VER TODOS)
SELECT 
  '4. USER_APPROVALS FINAIS' as etapa,
  ua.email,
  ua.status,
  ua.user_role,
  ua.full_name,
  ua.company_name
FROM public.user_approvals ua
WHERE ua.email NOT LIKE 'DELETED_%'
ORDER BY ua.created_at DESC;

-- 5️⃣ VERIFICAR POLÍTICAS FINAIS
SELECT 
  '5. POLÍTICAS SUBSCRIPTIONS' as etapa,
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'subscriptions'
ORDER BY policyname;

SELECT 
  '5. POLÍTICAS USER_APPROVALS' as etapa,
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'user_approvals'
ORDER BY policyname;

-- ================================================
-- ✅ RESULTADO ESPERADO:
-- - 6 subscriptions ativas
-- - 6 user_approvals (sem deletados)
-- - Admin vê TODAS as linhas
-- - 2 políticas por tabela (admin + users)
-- ================================================
