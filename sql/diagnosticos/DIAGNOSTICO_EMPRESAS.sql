-- 🔍 DIAGNÓSTICO: Por que os dados da empresa não aparecem no frontend
-- Execute este SQL no Supabase SQL Editor

-- 1. Verificar se RLS está habilitada na tabela empresas
SELECT 
  '📋 RLS STATUS' as info,
  relname as tabela,
  relrowsecurity as rls_ativo
FROM pg_class 
WHERE relname = 'empresas';

-- 2. Ver todas as políticas RLS da tabela empresas
SELECT 
  '🔒 POLÍTICAS' as info,
  policyname as politica,
  cmd as operacao,
  qual as condicao_using,
  with_check as condicao_check
FROM pg_policies 
WHERE tablename = 'empresas'
ORDER BY cmd;

-- 3. Ver TODOS os registros da tabela empresas (usando service_role, ignora RLS)
SELECT 
  '📊 TODAS AS EMPRESAS' as info,
  e.id,
  e.user_id,
  e.nome,
  e.cnpj,
  e.telefone,
  e.cidade,
  e.estado,
  e.created_at,
  -- Verificar se user_id existe em auth.users
  CASE WHEN au.id IS NOT NULL THEN '✅ user_id válido' ELSE '❌ user_id INVÁLIDO' END as user_valido,
  au.email as email_auth
FROM empresas e
LEFT JOIN auth.users au ON au.id = e.user_id
ORDER BY e.created_at DESC;

-- 4. Verificar se há usuários SEM empresa
SELECT 
  '⚠️ USUARIOS SEM EMPRESA' as info,
  au.id as user_id,
  au.email,
  au.raw_user_meta_data->>'fullName' as nome_cadastro
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
WHERE e.id IS NULL
ORDER BY au.created_at DESC;

-- 5. Verificar colunas da tabela empresas
SELECT 
  '📋 COLUNAS DA TABELA' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND table_schema = 'public'
ORDER BY ordinal_position;
