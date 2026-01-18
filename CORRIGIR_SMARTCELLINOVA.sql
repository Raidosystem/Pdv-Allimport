-- ============================================================================
-- INVESTIGAR E CORRIGIR: smartcellinova@gmail.com
-- ============================================================================

-- ============================================================================
-- 1️⃣ INVESTIGAÇÃO COMPLETA DO USUÁRIO
-- ============================================================================

-- Ver dados em user_approvals
SELECT 
  '📋 DADOS EM user_approvals:' as info,
  user_id,
  email,
  full_name,
  company_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ OK - Deveria aparecer no admin'
    WHEN status = 'pending' THEN '❌ PROBLEMA: Status PENDING - não foi aprovado'
    WHEN status = 'approved' AND (user_role IS NULL OR user_role != 'owner') THEN '❌ PROBLEMA: user_role errado'
    ELSE '⚠️ Verificar'
  END as diagnostico
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- Ver se existe em auth.users
SELECT 
  '🔐 DADOS EM auth.users:' as info,
  id as user_id,
  email,
  email_confirmed_at,
  created_at,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN '✅ Email confirmado'
    ELSE '❌ Email NÃO confirmado'
  END as status_email
FROM auth.users
WHERE email = 'smartcellinova@gmail.com';

-- Ver se tem assinatura
SELECT 
  '💳 DADOS EM subscriptions:' as info,
  email,
  status,
  plan_type,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER as dias_restantes,
  created_at,
  CASE 
    WHEN trial_end_date IS NOT NULL THEN '✅ Trial ativo'
    ELSE '❌ Sem trial'
  END as status_trial
FROM subscriptions
WHERE email = 'smartcellinova@gmail.com';

-- ============================================================================
-- 2️⃣ DIAGNÓSTICO RESUMIDO
-- ============================================================================

SELECT 
  '🔍 DIAGNÓSTICO:' as tipo,
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM user_approvals WHERE email = 'smartcellinova@gmail.com') 
    THEN '❌ USUÁRIO NÃO EXISTE em user_approvals'
    
    WHEN EXISTS (
      SELECT 1 FROM user_approvals 
      WHERE email = 'smartcellinova@gmail.com' 
      AND status = 'pending'
    ) 
    THEN '❌ PROBLEMA: Status = pending (não foi aprovado após verificar email)'
    
    WHEN EXISTS (
      SELECT 1 FROM user_approvals 
      WHERE email = 'smartcellinova@gmail.com' 
      AND status = 'approved' 
      AND (user_role IS NULL OR user_role != 'owner')
    )
    THEN '❌ PROBLEMA: Aprovado mas user_role não é owner'
    
    WHEN EXISTS (
      SELECT 1 FROM user_approvals 
      WHERE email = 'smartcellinova@gmail.com' 
      AND status = 'approved' 
      AND user_role = 'owner'
    ) AND NOT EXISTS (
      SELECT 1 FROM subscriptions WHERE email = 'smartcellinova@gmail.com'
    )
    THEN '❌ PROBLEMA: Aprovado corretamente mas SEM assinatura'
    
    WHEN EXISTS (
      SELECT 1 FROM user_approvals 
      WHERE email = 'smartcellinova@gmail.com' 
      AND status = 'approved' 
      AND user_role = 'owner'
    ) AND EXISTS (
      SELECT 1 FROM subscriptions WHERE email = 'smartcellinova@gmail.com'
    )
    THEN '✅ TUDO OK - Deveria aparecer no admin'
    
    ELSE '⚠️ Situação inesperada'
  END as problema_identificado;

-- ============================================================================
-- 3️⃣ CORREÇÃO AUTOMÁTICA
-- ============================================================================

-- ⚠️ EXECUTAR: Corrigir tudo de uma vez
DO $$
DECLARE
  v_user_id UUID;
  v_status TEXT;
  v_user_role TEXT;
  v_has_subscription BOOLEAN;
BEGIN
  -- Buscar dados do usuário
  SELECT user_id, status, user_role INTO v_user_id, v_status, v_user_role
  FROM user_approvals
  WHERE email = 'smartcellinova@gmail.com';
  
  -- Verificar se tem assinatura
  SELECT EXISTS(SELECT 1 FROM subscriptions WHERE email = 'smartcellinova@gmail.com') INTO v_has_subscription;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado em user_approvals';
    RETURN;
  END IF;
  
  RAISE NOTICE '📋 Usuário encontrado: %', v_user_id;
  RAISE NOTICE '   Status atual: %', v_status;
  RAISE NOTICE '   Role atual: %', COALESCE(v_user_role, 'NULL');
  RAISE NOTICE '   Tem assinatura: %', v_has_subscription;
  
  -- CORREÇÃO 1: Aprovar se estiver pending
  IF v_status = 'pending' THEN
    UPDATE user_approvals 
    SET 
      status = 'approved',
      user_role = 'owner',
      approved_at = NOW(),
      email_verified = TRUE
    WHERE email = 'smartcellinova@gmail.com';
    
    RAISE NOTICE '✅ Status atualizado para approved';
  END IF;
  
  -- CORREÇÃO 2: Corrigir user_role se estiver errado
  IF v_user_role IS NULL OR v_user_role != 'owner' THEN
    UPDATE user_approvals 
    SET user_role = 'owner'
    WHERE email = 'smartcellinova@gmail.com';
    
    RAISE NOTICE '✅ user_role atualizado para owner';
  END IF;
  
  -- CORREÇÃO 3: Criar assinatura se não existir
  IF NOT v_has_subscription THEN
    PERFORM activate_trial_for_new_user('smartcellinova@gmail.com');
    RAISE NOTICE '✅ Trial de 15 dias ativado';
  ELSE
    RAISE NOTICE '✅ Usuário já possui assinatura';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '🎉 CORREÇÃO CONCLUÍDA!';
  
END $$;

-- ============================================================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- ============================================================================

SELECT '════════════════════════════════════════' as separador;
SELECT '✅ VERIFICAÇÃO APÓS CORREÇÃO:' as titulo;
SELECT '════════════════════════════════════════' as separador;

-- Status final em user_approvals
SELECT 
  '📋 user_approvals:' as tabela,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' 
    THEN '✅ OK - Aparece no admin'
    ELSE '❌ Ainda tem problema'
  END as resultado
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- Status final em subscriptions
SELECT 
  '💳 subscriptions:' as tabela,
  email,
  status,
  plan_type,
  EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER as dias_restantes,
  trial_end_date,
  CASE 
    WHEN status = 'trial' AND trial_end_date > NOW()
    THEN '✅ Trial ativo'
    ELSE '⚠️ Verificar status'
  END as resultado
FROM subscriptions
WHERE email = 'smartcellinova@gmail.com';

-- Resumo final
SELECT 
  '📊 RESUMO:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM user_approvals 
      WHERE email = 'smartcellinova@gmail.com'
      AND status = 'approved' 
      AND user_role = 'owner'
    ) AND EXISTS (
      SELECT 1 FROM subscriptions 
      WHERE email = 'smartcellinova@gmail.com'
      AND status = 'trial'
    )
    THEN '🎉 TUDO CORRIGIDO! Usuário deve aparecer no painel admin agora.'
    ELSE '⚠️ Ainda há problemas - verificar logs acima'
  END as status_final;
