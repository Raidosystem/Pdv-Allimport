-- ================================================
-- DIAGNÓSTICO COMPLETO DO ERRO 403
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1️⃣ VERIFICAR QUAIS USER_IDS ESTÃO SENDO BUSCADOS
SELECT 
  '1. USER_IDS NO ERRO 403' as info,
  '69e6a65f-ff2c-4670-96bd-57acf8799d19' as user_1,
  '6ed345da-d704-4d79-9971-490919d851aa' as user_2,
  '28230691-00a7-45e7-a6d6-ff79fd0fac89' as user_3_admin,
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' as user_4;

-- 2️⃣ VERIFICAR SE ESSES USUÁRIOS EXISTEM NA user_approvals
SELECT 
  '2. VERIFICAR EXISTÊNCIA' as info,
  user_id,
  email,
  status,
  full_name
FROM public.user_approvals
WHERE user_id IN (
  '69e6a65f-ff2c-4670-96bd-57acf8799d19',
  '6ed345da-d704-4d79-9971-490919d851aa',
  '28230691-00a7-45e7-a6d6-ff79fd0fac89',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
);

-- 3️⃣ VERIFICAR POLÍTICAS RLS ATIVAS
SELECT 
  '3. POLÍTICAS RLS ATIVAS' as info,
  policyname,
  cmd,
  qual as condicao
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_approvals';

-- 4️⃣ TESTAR ACESSO DIRETO SEM FILTRO
SELECT 
  '4. TODOS OS REGISTROS (SEM FILTRO)' as info,
  COUNT(*) as total,
  STRING_AGG(email, ', ') as emails
FROM public.user_approvals;

-- 5️⃣ DESABILITAR RLS TEMPORARIAMENTE PARA TESTE
ALTER TABLE public.user_approvals DISABLE ROW LEVEL SECURITY;

-- 6️⃣ TESTAR NOVAMENTE
SELECT 
  '5. TESTE COM RLS DESABILITADO' as info,
  user_id,
  email,
  status
FROM public.user_approvals
WHERE user_id IN (
  '69e6a65f-ff2c-4670-96bd-57acf8799d19',
  '6ed345da-d704-4d79-9971-490919d851aa',
  '28230691-00a7-45e7-a6d6-ff79fd0fac89',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
);

-- 7️⃣ REABILITAR RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- ================================================
-- 🎯 SOLUÇÃO: SE O TESTE COM RLS DESABILITADO FUNCIONOU,
-- O PROBLEMA ESTÁ NAS POLÍTICAS RLS
-- ================================================

SELECT 
  '✅ DIAGNÓSTICO COMPLETO!' as resultado,
  'Se funcionou com RLS desabilitado, precisamos ajustar as políticas' as proxima_acao;
