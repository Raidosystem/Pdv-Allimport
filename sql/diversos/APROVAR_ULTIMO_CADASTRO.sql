-- ============================================================================
-- SOLUÇÃO RÁPIDA: APROVAR ÚLTIMO CADASTRO MANUALMENTE
-- ============================================================================

-- ⚠️ IMPORTANTE: Execute primeiro DIAGNOSTICO_ULTIMO_CADASTRO.sql 
-- para identificar o problema antes de executar esta correção

-- ============================================================================
-- OPÇÃO 1: Aprovar o último usuário cadastrado
-- ============================================================================

-- Ver qual é o último usuário
SELECT 
  '📋 ÚLTIMO USUÁRIO CADASTRADO:' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 1;

-- ⚠️ DESCOMENTAR PARA EXECUTAR:
-- Aprovar o último usuário
/*
UPDATE user_approvals 
SET 
  status = 'approved',
  user_role = 'owner',
  approved_at = NOW(),
  email_verified = TRUE
WHERE user_id = (
  SELECT user_id FROM user_approvals ORDER BY created_at DESC LIMIT 1
);
*/

-- ============================================================================
-- OPÇÃO 2: Aprovar usuário específico por email
-- ============================================================================

-- ⚠️ DESCOMENTAR E SUBSTITUIR O EMAIL:
/*
UPDATE user_approvals 
SET 
  status = 'approved',
  user_role = 'owner',
  approved_at = NOW(),
  email_verified = TRUE
WHERE email = 'EMAIL_DO_USUARIO@exemplo.com';

-- Verificar se foi aprovado
SELECT 
  '✅ USUÁRIO APROVADO:' as resultado,
  email,
  status,
  user_role,
  approved_at
FROM user_approvals
WHERE email = 'EMAIL_DO_USUARIO@exemplo.com';

-- Ativar 15 dias de teste
SELECT activate_trial_for_new_user('EMAIL_DO_USUARIO@exemplo.com');
*/

-- ============================================================================
-- OPÇÃO 3: Aprovar TODOS os usuários que verificaram email
-- ============================================================================

-- Ver quantos usuários seriam aprovados
SELECT 
  '📊 USUÁRIOS QUE SERÃO APROVADOS:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE status = 'pending';

-- ⚠️ DESCOMENTAR PARA EXECUTAR:
-- Aprovar todos os usuários pendentes que verificaram email
/*
UPDATE user_approvals 
SET 
  status = 'approved',
  approved_at = NOW()
WHERE status = 'pending' 
  AND user_role = 'owner'
  AND email_verified = TRUE;

SELECT 
  '✅ USUÁRIOS APROVADOS COM SUCESSO' as resultado,
  COUNT(*) as total_aprovados
FROM user_approvals
WHERE status = 'approved' 
  AND approved_at > NOW() - INTERVAL '1 minute';
*/

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

-- Ver lista atualizada que aparecerá no admin
SELECT 
  '📋 USUÁRIOS QUE APARECERÃO NO PAINEL ADMIN:' as info,
  email,
  full_name,
  status,
  user_role,
  approved_at,
  created_at
FROM user_approvals
WHERE status = 'approved'
  AND user_role = 'owner'
ORDER BY created_at DESC
LIMIT 10;

-- Contar totais
SELECT 
  '📊 RESUMO:' as resumo,
  status,
  COUNT(*) as quantidade
FROM user_approvals
GROUP BY status;
