-- Verificar se a função check_subscription_status existe
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'check_subscription_status';

-- Se não existir, precisamos criar
-- Se existir, ver o código completo
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'check_subscription_status';
