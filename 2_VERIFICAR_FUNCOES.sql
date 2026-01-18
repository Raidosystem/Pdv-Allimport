-- ============================================
-- 2️⃣ VERIFICAR FUNÇÕES DE TRIGGER RELACIONADAS A SIGNUP
-- ============================================

SELECT 
  routine_name,
  routine_type,
  routine_schema
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (
    routine_name LIKE '%new_user%'
    OR routine_name LIKE '%signup%'
    OR routine_name LIKE '%approval%'
  )
ORDER BY routine_name;
