-- 📊 VERIFICAR TODAS AS ASSINATURAS E DETALHES

-- 1️⃣ LISTAR TODAS AS ASSINATURAS COM DETALHES COMPLETOS
SELECT 
  s.email,
  s.status,
  s.plan_type,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date IS NOT NULL THEN
      GREATEST(0, EXTRACT(DAY FROM (s.trial_end_date - NOW())))::INTEGER
    WHEN s.status = 'active' AND s.subscription_end_date IS NOT NULL THEN
      GREATEST(0, EXTRACT(DAY FROM (s.subscription_end_date - NOW())))::INTEGER
    ELSE 0
  END as dias_restantes,
  CASE 
    WHEN s.status = 'trial' THEN s.trial_end_date
    WHEN s.status = 'active' THEN s.subscription_end_date
    ELSE NULL
  END as data_expiracao,
  s.created_at,
  s.updated_at,
  ua.full_name,
  ua.company_name
FROM subscriptions s
LEFT JOIN user_approvals ua ON ua.user_id = s.user_id
ORDER BY s.created_at DESC;

-- 2️⃣ ESTATÍSTICAS RESUMIDAS
SELECT 
  '📊 RESUMO GERAL' as titulo,
  COUNT(*) as total_assinaturas,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as premium_ativos,
  COUNT(CASE WHEN status = 'trial' THEN 1 END) as em_teste,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendentes,
  COUNT(CASE WHEN status = 'expired' THEN 1 END) as expirados
FROM subscriptions;

-- 3️⃣ VERIFICAR USER_APPROVALS
SELECT 
  '👥 USER APPROVALS' as titulo,
  COUNT(*) as total,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as aprovados,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendentes
FROM user_approvals;

-- 4️⃣ VERIFICAR SE ADMIN TEM ACESSO
SELECT 
  '🔐 VERIFICAÇÃO DE POLÍTICAS RLS' as info,
  tablename,
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- 5️⃣ TESTE: SIMULAR ADIÇÃO DE DIAS PARA UM USUÁRIO
-- (Apenas visualização, não executa)
SELECT 
  '🧪 TESTE DE FUNÇÃO' as info,
  'Exemplo de como adicionar 30 dias premium:' as descricao,
  'SELECT admin_add_subscription_days(user_id, 30, ''premium'')' as comando,
  'FROM subscriptions WHERE email = ''seu-email@exemplo.com'';' as complemento;

-- 6️⃣ LISTAR EMAILS ADMIN COM PERMISSÕES
SELECT 
  '🔑 EMAILS COM ACESSO ADMINISTRATIVO' as info,
  unnest(ARRAY[
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  ]) as email_admin;
