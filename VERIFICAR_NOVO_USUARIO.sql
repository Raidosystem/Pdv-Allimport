-- ============================================
-- VERIFICAR SUBSCRIPTION DE NOVO USUÁRIO
-- ============================================

-- PASSO 1: Ver último usuário criado
SELECT 
  u.id,
  u.email,
  u.created_at,
  '👤 Último usuário cadastrado' as tipo
FROM auth.users u
ORDER BY u.created_at DESC
LIMIT 1;

-- PASSO 2: Ver se ele tem empresa
SELECT 
  e.id,
  e.user_id,
  e.nome,
  e.email,
  e.tipo_conta,
  e.data_cadastro,
  e.data_fim_teste,
  CASE 
    WHEN e.data_fim_teste > NOW() THEN '✅ Teste ATIVO'
    WHEN e.data_fim_teste < NOW() THEN '❌ Teste EXPIRADO'
    ELSE '⚠️ Sem data de teste'
  END as status_teste
FROM empresas e
WHERE e.user_id = (
  SELECT u.id FROM auth.users u ORDER BY u.created_at DESC LIMIT 1
);

-- PASSO 3: Ver se ele tem subscription
SELECT 
  s.id,
  s.user_id,
  s.email,
  s.plan_type,
  s.status,
  s.trial_start_date,
  s.trial_end_date,
  s.subscription_end_date,
  EXTRACT(DAY FROM (COALESCE(s.trial_end_date, s.subscription_end_date) - NOW())) as dias_restantes,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date > NOW() THEN '✅ TRIAL ATIVO'
    WHEN s.status = 'active' AND s.subscription_end_date > NOW() THEN '✅ SUBSCRIPTION ATIVA'
    WHEN COALESCE(s.trial_end_date, s.subscription_end_date) < NOW() THEN '❌ EXPIRADO'
    ELSE '⚠️ Status desconhecido'
  END as status_real
FROM subscriptions s
WHERE s.user_id = (
  SELECT u.id FROM auth.users u ORDER BY u.created_at DESC LIMIT 1
);

-- PASSO 4: Verificar se RPC check_subscription_status retorna dados corretos
-- (execute esta query MANUALMENTE logado como o usuário de teste)
-- SELECT * FROM check_subscription_status('EMAIL_DO_USUARIO_TESTE');
