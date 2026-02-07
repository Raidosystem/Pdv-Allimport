-- ============================================
-- CORRIGIR FUNÇÃO get_admin_subscribers (email ambíguo)
-- ============================================

DROP FUNCTION IF EXISTS get_admin_subscribers();

CREATE OR REPLACE FUNCTION get_admin_subscribers()
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  full_name TEXT,
  company_name TEXT,
  created_at TIMESTAMPTZ,
  status TEXT,
  user_role TEXT
)
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar se é super admin (qualificar coluna com nome da tabela)
  IF NOT EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid() 
    AND u.email = 'novaradiosystem@outlook.com'  -- ← Qualificado com "u."
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin';
  END IF;
  
  -- Retornar todos os owners (bypassa RLS)
  RETURN QUERY
  SELECT 
    ua.user_id,
    ua.email,
    ua.full_name,
    ua.company_name,
    ua.created_at,
    ua.status,
    ua.user_role
  FROM user_approvals ua
  WHERE ua.user_role = 'owner'
  ORDER BY ua.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO authenticated;

-- Teste
SELECT '✅ Função get_admin_subscribers() corrigida!' as resultado;
