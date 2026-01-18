-- ============================================================================
-- CORREÇÃO RÁPIDA: APROVAR E ATIVAR ÚLTIMO CADASTRO
-- ============================================================================

-- ⚠️ Execute INVESTIGAR_CADASTRO_HOJE.sql primeiro para ver o problema
-- Depois execute este script para corrigir

-- ============================================================================
-- OPÇÃO 1: Corrigir APENAS o último cadastro
-- ============================================================================

-- Ver o último cadastro
SELECT 
  '👤 ÚLTIMO CADASTRO:' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified
FROM user_approvals
ORDER BY created_at DESC
LIMIT 1;

-- ⚠️ DESCOMENTAR PARA EXECUTAR:
/*
-- 1️⃣ Aprovar o último cadastro
UPDATE user_approvals 
SET 
  status = 'approved',
  user_role = 'owner',
  approved_at = NOW(),
  email_verified = TRUE
WHERE user_id = (SELECT user_id FROM user_approvals ORDER BY created_at DESC LIMIT 1)
RETURNING email, status, user_role, approved_at;

-- 2️⃣ Ativar 15 dias de teste
DO $$
DECLARE
  v_email TEXT;
  v_result JSON;
BEGIN
  -- Pegar email do último usuário
  SELECT email INTO v_email FROM user_approvals ORDER BY created_at DESC LIMIT 1;
  
  -- Ativar trial
  SELECT activate_trial_for_new_user(v_email) INTO v_result;
  
  RAISE NOTICE 'Resultado: %', v_result;
END $$;

-- 3️⃣ Verificar se foi corrigido
SELECT 
  '✅ VERIFICAÇÃO:' as resultado,
  email,
  status,
  user_role,
  approved_at,
  (SELECT COUNT(*) FROM subscriptions s WHERE s.email = ua.email) as tem_assinatura
FROM user_approvals ua
ORDER BY created_at DESC
LIMIT 1;
*/

-- ============================================================================
-- OPÇÃO 2: Corrigir TODOS os cadastros de hoje
-- ============================================================================

-- Ver quantos cadastros de hoje precisam correção
SELECT 
  '📊 CADASTROS DE HOJE QUE PRECISAM CORREÇÃO:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE DATE(created_at) = CURRENT_DATE
  AND (status = 'pending' OR user_role != 'owner' OR user_role IS NULL);

-- ⚠️ DESCOMENTAR PARA EXECUTAR:
/*
-- Aprovar todos os cadastros de hoje
UPDATE user_approvals 
SET 
  status = 'approved',
  user_role = 'owner',
  approved_at = NOW(),
  email_verified = TRUE
WHERE DATE(created_at) = CURRENT_DATE
  AND (status = 'pending' OR user_role != 'owner' OR user_role IS NULL)
RETURNING email, status, user_role;

-- Ativar trial para todos
DO $$
DECLARE
  v_user RECORD;
BEGIN
  FOR v_user IN 
    SELECT email FROM user_approvals 
    WHERE DATE(created_at) = CURRENT_DATE
    AND approved_at > NOW() - INTERVAL '1 minute'
  LOOP
    PERFORM activate_trial_for_new_user(v_user.email);
    RAISE NOTICE 'Trial ativado para: %', v_user.email;
  END LOOP;
END $$;
*/

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

-- Ver todos os cadastros de hoje corrigidos
SELECT 
  '✅ CADASTROS DE HOJE APÓS CORREÇÃO:' as resultado,
  email,
  full_name,
  status,
  user_role,
  approved_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ OK - Aparece no admin'
    ELSE '❌ Ainda tem problema'
  END as situacao
FROM user_approvals
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at DESC;

-- Ver assinaturas criadas
SELECT 
  '💳 ASSINATURAS DE HOJE:' as info,
  email,
  status,
  plan_type,
  EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER as dias_restantes,
  created_at
FROM subscriptions
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at DESC;
