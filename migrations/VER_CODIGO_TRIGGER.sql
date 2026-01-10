-- ============================================================================
-- VER CÓDIGO DA FUNÇÃO DO TRIGGER
-- ============================================================================
-- Examinar o código de create_empresa_for_new_user() para encontrar bugs
-- ============================================================================

-- Ver código completo da função
SELECT 
  routine_name as funcao,
  routine_definition as codigo
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'create_empresa_for_new_user';

-- Ver código da outra função também
SELECT 
  routine_name as funcao,
  routine_definition as codigo
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user_approval';
