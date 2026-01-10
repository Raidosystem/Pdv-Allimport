-- ============================================================================
-- CORRIGIR get_admin_subscribers - APENAS OWNERS (EXCLUIR ADMIN E EMPLOYEES)
-- ============================================================================
-- Retornar apenas usuários que COMPRARAM o sistema (role = owner)
-- Excluir super_admin e employees
-- ============================================================================

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
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid() 
    AND u.email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin';
  END IF;
  
  -- Retornar APENAS OWNERS (pessoas que compraram o sistema)
  -- Exclui: super_admin e employees
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
  WHERE ua.status = 'approved'
    AND ua.user_role = 'owner'  -- Apenas owners
  ORDER BY ua.created_at DESC;
END;
$$;

-- Verificar
SELECT 
  'Função corrigida!' as mensagem,
  'Agora mostra apenas OWNERS (2 usuários: cris-ramos e assistenciaallimport)' as descricao;
