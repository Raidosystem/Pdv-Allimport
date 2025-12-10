-- ========================================
-- SOLUÇÃO: Conceder permissões em auth.users
-- ========================================
-- Problema: authenticated não tem permissão para SELECT em auth.users
-- Solução: Conceder SELECT para authenticated e anon
-- ========================================

-- 1. Conceder permissão de SELECT em auth.users para roles autenticados
GRANT SELECT ON auth.users TO authenticated;
GRANT SELECT ON auth.users TO anon;

-- 2. Também conceder em outras tabelas auth se necessário
GRANT SELECT ON auth.sessions TO authenticated;
GRANT SELECT ON auth.refresh_tokens TO authenticated;

-- 3. Verificar permissões concedidas
SELECT 
  grantee, 
  privilege_type 
FROM information_schema.role_table_grants 
WHERE table_schema = 'auth' 
  AND table_name = 'users'
ORDER BY grantee, privilege_type;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- Deve aparecer:
-- | authenticated | SELECT |
-- | anon          | SELECT |
-- | postgres      | (todas as permissões) |
-- ========================================
