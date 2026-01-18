-- ============================================================================
-- CORRIGIR ERRO: column reference "email" is ambiguous
-- ============================================================================

-- O problema: A função está fazendo JOIN com auth.users e "email" existe nas 2 tabelas
-- Solução: Qualificar todas as colunas com alias da tabela

DROP FUNCTION IF EXISTS get_admin_subscribers();

CREATE FUNCTION get_admin_subscribers()
RETURNS TABLE (
  user_id UUID,
  email VARCHAR,
  full_name VARCHAR,
  company_name VARCHAR,
  created_at TIMESTAMPTZ,
  status VARCHAR,
  user_role VARCHAR
)
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Retornar apenas os owners APROVADOS (sem verificação de super admin)
  RETURN QUERY
  SELECT 
    ua.user_id,
    ua.email::VARCHAR,
    ua.full_name::VARCHAR,
    ua.company_name::VARCHAR,
    ua.created_at,
    ua.status::VARCHAR,
    ua.user_role::VARCHAR
  FROM user_approvals ua
  WHERE ua.user_role = 'owner'
    AND ua.status = 'approved'
  ORDER BY ua.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO anon;

SELECT '✅ Função get_admin_subscribers() corrigida (sem ambiguidade)!' as resultado;

-- Testar a função
SELECT 
  '🧪 TESTE:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved';

-- Listar usuários
SELECT 
  '📋 USUÁRIOS:' as info,
  email,
  full_name,
  company_name
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved'
ORDER BY created_at DESC;
