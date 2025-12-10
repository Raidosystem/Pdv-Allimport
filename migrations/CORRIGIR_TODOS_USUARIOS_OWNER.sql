-- ============================================
-- CORRIGIR TODOS OS USUÁRIOS NOVOS COMO OWNERS
-- Aplicar para TODOS que cadastraram recentemente
-- ============================================

-- 1️⃣ DIAGNÓSTICO: Ver todos os usuários sem empresa
SELECT 
  '⚠️ USUÁRIOS SEM EMPRESA' as problema,
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    ELSE '✅ TEM EMPRESA'
  END as status_empresa,
  CASE 
    WHEN ua.id IS NULL THEN '❌ SEM APROVAÇÃO'
    WHEN ua.user_role = 'owner' THEN '✅ É OWNER'
    ELSE '⚠️ ' || ua.user_role
  END as status_aprovacao
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '7 days'  -- Últimos 7 dias
ORDER BY u.created_at DESC;

-- 2️⃣ CRIAR EMPRESA PARA TODOS OS USUÁRIOS SEM EMPRESA
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
  u.created_at,
  u.created_at + INTERVAL '15 days'
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
  AND u.created_at >= NOW() - INTERVAL '7 days'
ON CONFLICT (user_id) DO UPDATE
SET
  tipo_conta = 'teste_ativo',
  data_fim_teste = GREATEST(empresas.data_cadastro + INTERVAL '15 days', NOW() + INTERVAL '1 day');

-- 3️⃣ CRIAR/ATUALIZAR user_approvals PARA TODOS COMO OWNER
INSERT INTO user_approvals (
  user_id,
  email,
  full_name,
  company_name,
  cpf_cnpj,
  user_role,
  status,
  approved_at,
  created_at
)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', 'Usuário'),
  COALESCE(u.raw_user_meta_data->>'company_name', 'Empresa'),
  COALESCE(u.raw_user_meta_data->>'cpf_cnpj', ''),
  'owner',
  'approved',
  NOW(),
  u.created_at
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE ua.id IS NULL
  AND u.created_at >= NOW() - INTERVAL '7 days'
ON CONFLICT (user_id) DO UPDATE
SET
  user_role = 'owner',
  status = 'approved',
  approved_at = NOW();

-- 4️⃣ ATUALIZAR USUÁRIOS QUE JÁ EXISTEM MAS SÃO FUNCIONÁRIOS INCORRETAMENTE
UPDATE user_approvals
SET 
  user_role = 'owner',
  status = 'approved',
  approved_at = COALESCE(approved_at, NOW())
WHERE user_role != 'owner'
  AND user_id IN (
    SELECT u.id 
    FROM auth.users u
    LEFT JOIN funcionarios f ON f.user_id = u.id
    WHERE f.id IS NULL  -- Não tem registro de funcionário real
      AND u.created_at >= NOW() - INTERVAL '7 days'
  );

-- 5️⃣ GARANTIR 15 DIAS DE TESTE PARA TODOS
UPDATE empresas
SET 
  tipo_conta = 'teste_ativo',
  data_fim_teste = GREATEST(data_cadastro + INTERVAL '15 days', NOW() + INTERVAL '1 day')
WHERE tipo_conta IN ('teste_ativo', 'teste_expirado', 'pendente', '')
  AND (
    data_fim_teste IS NULL 
    OR data_fim_teste < NOW()
    OR data_fim_teste < data_cadastro + INTERVAL '15 days'
  )
  AND data_cadastro >= NOW() - INTERVAL '7 days';

-- 6️⃣ VERIFICAR RESULTADO
SELECT 
  '✅ CORREÇÃO APLICADA' as status,
  COUNT(*) FILTER (WHERE e.id IS NOT NULL) as empresas_criadas,
  COUNT(*) FILTER (WHERE ua.user_role = 'owner') as owners_configurados,
  COUNT(*) FILTER (WHERE e.tipo_conta = 'teste_ativo' AND e.data_fim_teste > NOW()) as testes_ativos
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '7 days';

-- 7️⃣ LISTAR TODOS OS USUÁRIOS RECENTES CORRIGIDOS
SELECT 
  '📋 USUÁRIOS CORRIGIDOS' as info,
  u.email,
  u.created_at,
  e.tipo_conta,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_teste,
  ua.user_role,
  ua.status,
  CASE 
    WHEN e.data_fim_teste > NOW() THEN '✅ TESTE ATIVO'
    ELSE '❌ EXPIRADO'
  END as status_final
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '7 days'
ORDER BY u.created_at DESC;

-- 8️⃣ TESTAR check_subscription_status PARA CADA USUÁRIO
SELECT 
  '🧪 TESTE RPC' as teste,
  u.email,
  check_subscription_status(u.email) as resultado
FROM auth.users u
WHERE u.created_at >= NOW() - INTERVAL '7 days'
ORDER BY u.created_at DESC;

-- ============================================
-- MENSAGEM FINAL
-- ============================================
SELECT 
  '✅ CORREÇÃO EM MASSA APLICADA' as status,
  'Todos os usuários dos últimos 7 dias agora são OWNERS' as mensagem,
  'Limpe o cache do navegador e faça login novamente' as acao;
