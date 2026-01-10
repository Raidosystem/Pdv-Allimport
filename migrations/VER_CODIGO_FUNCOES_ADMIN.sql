-- ============================================================================
-- VER CÓDIGO DAS FUNÇÕES ADMIN
-- ============================================================================
-- Ver o código completo das funções para entender a lógica de segurança
-- ============================================================================

-- Ver código completo das 3 funções
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_admin_subscribers',
    'get_all_empresas_admin',
    'get_all_subscriptions_admin'
  )
ORDER BY routine_name;

-- Alternativa: Buscar diretamente na tabela pg_proc
SELECT 
  proname as function_name,
  prosrc as source_code
FROM pg_proc
WHERE proname IN (
  'get_admin_subscribers',
  'get_all_empresas_admin', 
  'get_all_subscriptions_admin'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
