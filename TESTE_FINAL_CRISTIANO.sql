-- ============================================
-- TESTE FINAL - CRISTIANO
-- ============================================

-- Verificar se a função está retornando corretamente
SELECT check_subscription_status('cristiano@gruporaval.com.br');

-- ============================================
-- RESULTADO ESPERADO:
-- {
--   "has_subscription": true,
--   "status": "trial",
--   "access_allowed": true,
--   "days_remaining": 14,
--   "trial_end_date": "2025-12-04...",
--   "is_trial": true
-- }
-- ============================================
