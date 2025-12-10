-- ============================================
-- RESTAURAÇÃO AUTOMÁTICA DE ASSINATURAS
-- Baseado em análise de atividade dos usuários
-- ============================================

-- 1️⃣ RESTAURAR CLIENTE PAGO CONFIRMADO
-- assistenciaallimport10@gmail.com (Score 80 - 809 produtos, 132 clientes)
-- DAR 6 MESES GRÁTIS COMO COMPENSAÇÃO
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '6 months',  -- 6 MESES GRÁTIS
  trial_start_date = NULL,
  trial_end_date = NULL,
  amount = 0,  -- Grátis como compensação
  payment_method = 'compensacao_perda_dados',
  updated_at = NOW()
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- 2️⃣ USUÁRIOS ATIVOS - DAR 2 MESES GRÁTIS
-- Estes usuários estavam usando ativamente, merecem benefício da dúvida

-- cris-ramos30@hotmail.com (Você - proprietário do sistema)
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '12 months',  -- 1 ANO para o proprietário
  trial_start_date = NULL,
  trial_end_date = NULL,
  amount = 0,
  payment_method = 'proprietario',
  updated_at = NOW()
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com');

-- novaradiosystem@outlook.com (Login recente, 1 venda)
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '2 months',  -- 2 MESES como compensação
  trial_start_date = NULL,
  trial_end_date = NULL,
  amount = 0,
  payment_method = 'compensacao_teste_ativo',
  updated_at = NOW()
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');

-- marcovalentim04@gmail.com (10 vendas realizadas)
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '2 months',  -- 2 MESES como compensação
  trial_start_date = NULL,
  trial_end_date = NULL,
  amount = 0,
  payment_method = 'compensacao_teste_ativo',
  updated_at = NOW()
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'marcovalentim04@gmail.com');

-- 3️⃣ USUÁRIOS INATIVOS - MANTER TESTE PADRÃO DE 15 DIAS
-- Já foram resetados pelo script RESTAURAR_ASSINATURAS_URGENTE.sql
-- Não precisa fazer nada

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================
SELECT 
  u.email,
  s.status,
  s.plan_type,
  s.subscription_start_date,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes,
  s.payment_method as motivo
FROM auth.users u
JOIN subscriptions s ON s.user_id = u.id
WHERE u.email IN (
  'assistenciaallimport10@gmail.com',
  'cris-ramos30@hotmail.com',
  'novaradiosystem@outlook.com',
  'marcovalentim04@gmail.com'
)
ORDER BY dias_restantes DESC;

-- ============================================
-- RESUMO DO QUE FOI FEITO:
-- ============================================
-- ✅ assistenciaallimport10@gmail.com → 6 MESES PREMIUM (Cliente pago confirmado)
-- ✅ cris-ramos30@hotmail.com → 1 ANO PREMIUM (Proprietário do sistema)
-- ✅ novaradiosystem@outlook.com → 2 MESES PREMIUM (Compensação)
-- ✅ marcovalentim04@gmail.com → 2 MESES PREMIUM (Compensação por vendas realizadas)
-- ⚠️ Demais usuários → 15 dias de teste (já configurado)
