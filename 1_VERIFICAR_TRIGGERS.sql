-- ============================================
-- 1️⃣ VERIFICAR TRIGGERS ATIVOS NA TABELA auth.users
-- ============================================

SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing,
  action_orientation
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth'
ORDER BY trigger_name;
