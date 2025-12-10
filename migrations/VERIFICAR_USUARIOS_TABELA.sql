-- ================================================
-- VERIFICAR SE TODOS OS USUÁRIOS ESTÃO NA TABELA
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1️⃣ VERIFICAR QUANTOS USUÁRIOS EXISTEM NO auth.users
SELECT 
  '1. TOTAL DE USUÁRIOS NO AUTH.USERS' as info,
  COUNT(*) as total,
  STRING_AGG(email, ', ' ORDER BY created_at) as emails
FROM auth.users;

-- 2️⃣ VERIFICAR QUANTOS ESTÃO NA user_approvals
SELECT 
  '2. TOTAL NA USER_APPROVALS' as info,
  COUNT(*) as total,
  STRING_AGG(email, ', ' ORDER BY created_at) as emails
FROM public.user_approvals;

-- 3️⃣ ENCONTRAR USUÁRIOS QUE ESTÃO NO AUTH MAS NÃO NA APPROVALS
SELECT 
  '3. USUÁRIOS FALTANDO (auth.users → user_approvals)' as info,
  au.id,
  au.email,
  au.created_at,
  au.raw_user_meta_data->>'full_name' as full_name,
  au.raw_user_meta_data->>'company_name' as company_name
FROM auth.users au
LEFT JOIN public.user_approvals ua ON ua.user_id = au.id
WHERE ua.user_id IS NULL
ORDER BY au.created_at DESC;

-- 4️⃣ MOSTRAR TODOS OS CADASTROS POR STATUS
SELECT 
  '4. ESTATÍSTICAS POR STATUS' as info,
  status,
  COUNT(*) as quantidade,
  STRING_AGG(email, ', ' ORDER BY created_at) as usuarios
FROM public.user_approvals
GROUP BY status
ORDER BY status;

-- 5️⃣ MOSTRAR OS 10 CADASTROS MAIS RECENTES
SELECT 
  '5. ÚLTIMOS 10 CADASTROS' as info,
  email,
  full_name,
  company_name,
  status,
  created_at,
  CASE 
    WHEN created_at > NOW() - INTERVAL '1 hour' THEN '🆕 Recente'
    WHEN created_at > NOW() - INTERVAL '1 day' THEN '📅 Hoje'
    WHEN created_at > NOW() - INTERVAL '7 days' THEN '📆 Esta semana'
    ELSE '📜 Antigo'
  END as quando
FROM public.user_approvals
ORDER BY created_at DESC
LIMIT 10;

-- 6️⃣ SE HOUVER USUÁRIOS FALTANDO, POPULAR AUTOMATICAMENTE
INSERT INTO public.user_approvals (
  user_id, 
  email, 
  full_name, 
  company_name, 
  status, 
  approved_at, 
  created_at
)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Usuário'),
  COALESCE(au.raw_user_meta_data->>'company_name', 'Empresa'),
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN 'approved' 
    ELSE 'pending' 
  END as status,
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN NOW() 
    ELSE NULL 
  END as approved_at,
  au.created_at
FROM auth.users au
LEFT JOIN public.user_approvals ua ON ua.user_id = au.id
WHERE ua.user_id IS NULL;

-- 7️⃣ VERIFICAR RESULTADO FINAL
SELECT 
  '✅ VERIFICAÇÃO CONCLUÍDA!' as resultado,
  COUNT(*) as total_usuarios_cadastrados
FROM public.user_approvals;
