-- ============================================================================
-- CORREÇÃO RÁPIDA: Aprovar Último Cadastro
-- ============================================================================
-- ⚠️ Execute este script para aprovar manualmente o último usuário cadastrado
-- ============================================================================

-- ============================================================================
-- PASSO 1: Identificar o último usuário
-- ============================================================================

SELECT 
  '👤 ÚLTIMO USUÁRIO CADASTRADO:' as info,
  user_id,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 1;

-- ============================================================================
-- PASSO 2: Aprovar o último usuário
-- ============================================================================

-- ⚠️ DESCOMENTAR E EXECUTAR:

/*
-- Aprovar último usuário
UPDATE user_approvals 
SET 
  status = 'approved',
  user_role = 'owner',
  approved_at = NOW(),
  email_verified = TRUE
WHERE user_id = (
  SELECT user_id FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
RETURNING email, status, user_role, approved_at;
*/

-- ============================================================================
-- PASSO 3: Ativar teste de 15 dias para o último usuário
-- ============================================================================

-- ⚠️ DESCOMENTAR E EXECUTAR (após aprovar acima):

/*
-- Pegar email do último usuário e ativar trial
DO $$
DECLARE
  v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM user_approvals ORDER BY created_at DESC LIMIT 1;
  PERFORM activate_trial_for_new_user(v_email);
  RAISE NOTICE 'Trial ativado para: %', v_email;
END $$;
*/

-- ============================================================================
-- PASSO 4: Verificar se foi aprovado com sucesso
-- ============================================================================

SELECT 
  '✅ VERIFICAÇÃO APÓS APROVAÇÃO:' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' 
    THEN '✅ OK - Agora aparece no painel admin!'
    ELSE '❌ Ainda há problema - verificar'
  END as resultado
FROM user_approvals
ORDER BY created_at DESC
LIMIT 1;

-- ============================================================================
-- PASSO 5: Ver assinatura criada
-- ============================================================================

SELECT 
  '📅 ASSINATURA DO USUÁRIO:' as info,
  s.email,
  s.status,
  s.plan_type,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW()))::INTEGER as dias_restantes
FROM subscriptions s
WHERE s.email = (SELECT email FROM user_approvals ORDER BY created_at DESC LIMIT 1);

-- ============================================================================
-- ✅ ALTERNATIVA: Aprovar TODOS os usuários pendentes
-- ============================================================================

-- Ver quantos seriam aprovados
SELECT 
  '📊 USUÁRIOS PENDENTES QUE SERÃO APROVADOS:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE status = 'pending';

-- ⚠️ DESCOMENTAR PARA APROVAR TODOS OS PENDENTES:

/*
UPDATE user_approvals 
SET 
  status = 'approved',
  approved_at = NOW(),
  email_verified = TRUE
WHERE status = 'pending' 
  AND user_role = 'owner'
RETURNING email, status, approved_at;

-- Ativar trial para todos os recém-aprovados
DO $$
DECLARE
  v_user RECORD;
BEGIN
  FOR v_user IN 
    SELECT email FROM user_approvals 
    WHERE approved_at > NOW() - INTERVAL '1 minute'
  LOOP
    PERFORM activate_trial_for_new_user(v_user.email);
    RAISE NOTICE 'Trial ativado para: %', v_user.email;
  END LOOP;
END $$;
*/
