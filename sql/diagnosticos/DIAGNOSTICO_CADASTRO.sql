-- ============================================
-- 🔍 DIAGNÓSTICO COMPLETO DO PROBLEMA DE CADASTRO
-- Problema: Novos usuários entram como "Funcionário" ao invés de "Admin da Empresa"
-- ============================================

-- 1️⃣ VERIFICAR TRIGGERS ATIVOS NA TABELA auth.users
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing,
  action_orientation
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth'
ORDER BY trigger_name;

-- 2️⃣ VERIFICAR FUNÇÕES DE TRIGGER RELACIONADAS A SIGNUP
SELECT 
  routine_name,
  routine_type,
  routine_schema
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (
    routine_name LIKE '%new_user%'
    OR routine_name LIKE '%signup%'
    OR routine_name LIKE '%approval%'
  )
ORDER BY routine_name;

-- 3️⃣ VERIFICAR DADOS DE UM USUÁRIO TESTE
-- Substitua o email pelo do usuário que está tendo problema
SELECT 
  'Verificando usuário: silviobritoempreendedor@gmail.com' as etapa;

-- Dados do auth.users
SELECT 
  'auth.users' as tabela,
  id,
  email,
  email_confirmed_at,
  raw_user_meta_data->>'full_name' as nome,
  raw_user_meta_data->>'company_name' as empresa,
  raw_user_meta_data->>'role' as role_metadata,
  created_at
FROM auth.users
WHERE email = 'silviobritoempreendedor@gmail.com';

-- Dados do user_approvals
SELECT 
  'user_approvals' as tabela,
  id,
  user_id,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at,
  approved_at
FROM user_approvals
WHERE email = 'silviobritoempreendedor@gmail.com';

-- Dados da empresas
SELECT 
  'empresas' as tabela,
  id,
  user_id,
  nome,
  razao_social,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste
FROM empresas
WHERE email = 'silviobritoempreendedor@gmail.com'
   OR user_id IN (SELECT id FROM auth.users WHERE email = 'silviobritoempreendedor@gmail.com');

-- Dados do funcionarios
SELECT 
  'funcionarios' as tabela,
  id,
  empresa_id,
  user_id,
  nome,
  email,
  status,
  tipo_admin,
  funcao_id
FROM funcionarios
WHERE email = 'silviobritoempreendedor@gmail.com'
   OR user_id IN (SELECT id FROM auth.users WHERE email = 'silviobritoempreendedor@gmail.com');

-- Dados das funcoes (se tiver funcionario)
SELECT 
  'funcoes_do_funcionario' as tabela,
  func.*
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'silviobritoempreendedor@gmail.com'
   OR f.user_id IN (SELECT id FROM auth.users WHERE email = 'silviobritoempreendedor@gmail.com');

-- Dados da subscriptions
SELECT 
  'subscriptions' as tabela,
  id,
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  CASE 
    WHEN trial_end_date IS NOT NULL AND trial_end_date > NOW() THEN 
      EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER
    WHEN subscription_end_date IS NOT NULL AND subscription_end_date > NOW() THEN
      EXTRACT(DAY FROM (subscription_end_date - NOW()))::INTEGER
    ELSE 0
  END as dias_restantes
FROM subscriptions
WHERE email = 'silviobritoempreendedor@gmail.com';

-- 4️⃣ VERIFICAR TRIGGER QUE CRIA FUNCIONARIOS APÓS CRIAR EMPRESA
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'empresas'
  AND event_object_schema = 'public'
ORDER BY trigger_name;

-- 5️⃣ VERIFICAR CÓDIGO COMPLETO DOS TRIGGERS (apenas os que existem)
SELECT 
  '=== Trigger: on_auth_user_created ===' as info,
  pg_get_triggerdef(oid) as definicao
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

SELECT 
  '=== Função: handle_new_user (se existir) ===' as info;

SELECT 
  pg_get_functiondef(oid) as definicao_handle_new_user
FROM pg_proc
WHERE proname = 'handle_new_user'
  AND pronamespace = 'public'::regnamespace
LIMIT 1;

SELECT 
  '=== Trigger: trigger_auto_setup_admin (se existir) ===' as info;

SELECT 
  pg_get_triggerdef(oid) as definicao_trigger_admin
FROM pg_trigger
WHERE tgname = 'trigger_auto_setup_admin';

SELECT 
  '=== Função: setup_admin_permissions_for_user (se existir) ===' as info;

SELECT 
  pg_get_functiondef(oid) as definicao_setup_admin
FROM pg_proc
WHERE proname = 'setup_admin_permissions_for_user'
  AND pronamespace = 'public'::regnamespace
LIMIT 1;

-- 6️⃣ RESUMO DO PROBLEMA
SELECT 
  '❌ PROBLEMA IDENTIFICADO' as status,
  'Fluxo esperado:' as descricao,
  '1. Usuário se cadastra → cria auth.users' as passo_1,
  '2. Trigger cria empresa → dispara outro trigger' as passo_2,
  '3. Trigger cria funcionario com tipo_admin=admin_empresa' as passo_3,
  '4. Sistema lê tipo_admin e mostra "Proprietário"' as passo_4,
  '' as separador,
  '🔍 Verificar qual passo está faltando nos resultados acima' as instrucao;
