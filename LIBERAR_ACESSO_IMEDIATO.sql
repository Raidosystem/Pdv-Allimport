-- ============================================
-- SOLUÇÃO IMEDIATA - LIBERAR ACESSO AGORA
-- ============================================

-- Execute este script PRIMEIRO para liberar seu acesso imediatamente
-- Depois execute o RESTAURAR_ASSINATURAS_AUTOMATICO.sql

-- Liberar TODOS os usuários temporariamente (30 dias para dar tempo de resolver)
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '30 days',
  trial_start_date = NULL,
  trial_end_date = NULL,
  updated_at = NOW()
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email IN (
    'assistenciaallimport10@gmail.com',
    'cris-ramos30@hotmail.com',
    'novaradiosystem@outlook.com',
    'marcovalentim04@gmail.com'
  )
);

-- Verificar resultado
SELECT 
  u.email,
  s.status,
  s.plan_type,
  s.trial_end_date,
  s.subscription_start_date,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes
FROM auth.users u
JOIN subscriptions s ON s.user_id = u.id
ORDER BY s.subscription_end_date DESC NULLS LAST;

-- ============================================
-- DEPOIS execute RESTAURAR_ASSINATURAS_AUTOMATICO.sql
-- para ajustar os períodos corretos
-- ============================================
