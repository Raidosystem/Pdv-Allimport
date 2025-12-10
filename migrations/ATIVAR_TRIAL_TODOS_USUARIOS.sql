-- ============================================
-- ATIVAR TESTE DE 15 DIAS PARA TODOS OS USUÁRIOS
-- ============================================

-- 1️⃣ BUSCAR O USER_ID DO CRISTIANO
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Buscar o user_id do auth.users
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'cristiano@gruporaval.com.br';
  
  -- Se encontrou o usuário, criar/atualizar a assinatura
  IF v_user_id IS NOT NULL THEN
    INSERT INTO subscriptions (
      user_id,
      email,
      status,
      trial_end_date,
      created_at,
      updated_at
    )
    VALUES (
      v_user_id,
      'cristiano@gruporaval.com.br',
      'trial',
      NOW() + INTERVAL '15 days',
      NOW(),
      NOW()
    )
    ON CONFLICT (email) 
    DO UPDATE SET
      user_id = v_user_id,
      status = 'trial',
      trial_end_date = NOW() + INTERVAL '15 days',
      updated_at = NOW();
    
    RAISE NOTICE '✅ Trial de 15 dias ativado para cristiano@gruporaval.com.br';
  ELSE
    RAISE NOTICE '❌ Usuário cristiano@gruporaval.com.br não encontrado na tabela auth.users';
  END IF;
END $$;

-- 2️⃣ ASSISTÊNCIA ALL-IMPORT (TEM ACTIVE) - MANTER COMO ESTÁ
-- Este já tem assinatura ativa, não precisa alterar

-- 3️⃣ VERIFICAR TODOS OS USUÁRIOS
SELECT 
  email,
  status,
  CASE 
    WHEN status = 'trial' THEN trial_end_date
    WHEN status = 'active' THEN subscription_end_date
    ELSE NULL
  END as data_expiracao,
  CASE 
    WHEN status = 'trial' THEN EXTRACT(DAY FROM (trial_end_date - NOW()))
    WHEN status = 'active' THEN EXTRACT(DAY FROM (subscription_end_date - NOW()))
    ELSE 0
  END as dias_restantes,
  CASE 
    WHEN status = 'trial' AND trial_end_date > NOW() THEN '✅ Trial Válido'
    WHEN status = 'active' AND subscription_end_date > NOW() THEN '✅ Assinatura Ativa'
    WHEN status = 'trial' AND trial_end_date <= NOW() THEN '❌ Trial Expirado'
    WHEN status = 'active' AND subscription_end_date <= NOW() THEN '❌ Assinatura Expirada'
    ELSE '❌ Sem Assinatura'
  END as situacao
FROM subscriptions
ORDER BY email;

-- 4️⃣ TESTAR AS FUNÇÕES
SELECT 'cristiano@gruporaval.com.br' as usuario, 
       check_subscription_status('cristiano@gruporaval.com.br') as status;

SELECT 'assistenciaallimport10@gmail.com' as usuario, 
       check_subscription_status('assistenciaallimport10@gmail.com') as status;

-- ============================================
-- RESULTADO ESPERADO:
-- 
-- cristiano@gruporaval.com.br:
-- ✅ access_allowed: true
-- ✅ status: trial
-- ✅ days_remaining: 15
-- 
-- assistenciaallimport10@gmail.com:
-- ✅ access_allowed: true
-- ✅ status: active
-- ✅ days_remaining: 18 (ou quantos dias restam)
-- ============================================

-- 5️⃣ SE QUISER ATIVAR TRIAL PARA QUALQUER OUTRO USUÁRIO:
-- 
-- INSERT INTO subscriptions (email, status, trial_end_date, created_at, updated_at)
-- VALUES ('email@exemplo.com', 'trial', NOW() + INTERVAL '15 days', NOW(), NOW())
-- ON CONFLICT (email) DO UPDATE 
-- SET status = 'trial', trial_end_date = NOW() + INTERVAL '15 days', updated_at = NOW();
