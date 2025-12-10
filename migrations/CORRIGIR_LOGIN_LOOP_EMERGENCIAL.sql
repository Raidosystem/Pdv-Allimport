-- ============================================
-- CORREÇÃO EMERGENCIAL - LOGIN LOOP
-- Criar empresa para usuários existentes sem empresa
-- ============================================

-- 1️⃣ VERIFICAR SITUAÇÃO ATUAL
SELECT 
  '📊 DIAGNÓSTICO' as secao,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM auth.users u LEFT JOIN empresas e ON e.user_id = u.id WHERE e.id IS NULL) as usuarios_sem_empresa;

-- 2️⃣ LISTAR USUÁRIOS SEM EMPRESA
SELECT 
  '⚠️ USUÁRIOS SEM EMPRESA' as problema,
  u.id as user_id,
  u.email,
  u.created_at,
  u.raw_user_meta_data->>'full_name' as nome,
  u.raw_user_meta_data->>'company_name' as empresa
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
ORDER BY u.created_at DESC;

-- 3️⃣ CRIAR EMPRESA PARA USUÁRIOS SEM EMPRESA (CORREÇÃO EMERGENCIAL)
INSERT INTO empresas (
  user_id,
  nome,
  razao_social,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste
)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'company_name', 'Empresa'),
  COALESCE(u.raw_user_meta_data->>'company_name', u.raw_user_meta_data->>'full_name', 'Empresa'),
  u.email,
  'teste_ativo',
  NOW(),
  NOW() + INTERVAL '15 days'
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- 4️⃣ VERIFICAR RESULTADO
SELECT 
  '✅ EMPRESAS CRIADAS' as resultado,
  COUNT(*) as total
FROM empresas
WHERE data_cadastro >= NOW() - INTERVAL '1 minute';

-- 5️⃣ LISTAR TODAS AS EMPRESAS COM STATUS
SELECT 
  '📋 TODAS AS EMPRESAS' as lista,
  e.id,
  e.user_id,
  e.nome,
  e.email,
  e.tipo_conta,
  e.data_cadastro,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_restantes,
  CASE 
    WHEN e.data_fim_teste > NOW() THEN '✅ TESTE ATIVO'
    WHEN e.data_fim_teste IS NULL THEN '⚠️ SEM DATA'
    ELSE '❌ EXPIRADO'
  END as status
FROM empresas e
ORDER BY e.data_cadastro DESC;

-- 6️⃣ TESTAR FUNÇÃO check_subscription_status PARA CADA USUÁRIO
SELECT 
  '🧪 TESTE POR USUÁRIO' as teste,
  u.email,
  e.tipo_conta,
  e.data_fim_teste,
  check_subscription_status(u.email) as status_retornado
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 5;

-- 7️⃣ VERIFICAR SE TRIGGER ESTÁ ATIVO
SELECT 
  '🔧 STATUS TRIGGER' as info,
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- ============================================
-- MENSAGEM FINAL
-- ============================================
SELECT 
  '✅ CORREÇÃO APLICADA' as status,
  'Todos os usuários agora têm empresa com 15 dias de teste' as mensagem,
  'Faça logout e login novamente para testar' as proxima_acao;
