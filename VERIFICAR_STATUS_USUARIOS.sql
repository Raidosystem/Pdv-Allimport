-- ============================================
-- VERIFICAR SE TODOS OS USUÁRIOS TÊM EMPRESA E SUBSCRIPTION
-- ============================================

-- 1. VERIFICAR TODOS OS USUÁRIOS
SELECT 
  u.email as usuario_email,
  e.nome as empresa_nome,
  e.cnpj as cnpj,
  s.plan_type as plano,
  s.status as status_assinatura,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    WHEN s.id IS NULL THEN '❌ SEM SUBSCRIPTION'
    ELSE '✅ OK'
  END as status_geral
FROM auth.users u
LEFT JOIN public.empresas e ON e.user_id = u.id
LEFT JOIN public.subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC;

-- 2. VERIFICAR ESPECIFICAMENTE O SEU USUÁRIO (cris-ramos30@hotmail.com)
SELECT 
  e.id as empresa_id,
  e.nome as empresa_nome,
  e.cnpj,
  e.email as empresa_email,
  s.plan_type as plano,
  s.status,
  s.subscription_end_date as validade,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes
FROM auth.users u
JOIN public.empresas e ON e.user_id = u.id
JOIN public.subscriptions s ON s.user_id = u.id
WHERE u.email = 'cris-ramos30@hotmail.com';

-- 3. CONTAR TOTAL
SELECT 
  (SELECT COUNT(*) FROM auth.users) as total_usuarios,
  (SELECT COUNT(*) FROM public.empresas) as total_empresas,
  (SELECT COUNT(*) FROM public.subscriptions) as total_subscriptions;

-- 4. SE ALGUM USUÁRIO AINDA ESTIVER SEM EMPRESA, LISTAR
SELECT 
  u.id as user_id,
  u.email,
  'SEM EMPRESA' as problema
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.empresas e WHERE e.user_id = u.id
)
UNION ALL
SELECT 
  u.id as user_id,
  u.email,
  'SEM SUBSCRIPTION' as problema
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.subscriptions s WHERE s.user_id = u.id
);
