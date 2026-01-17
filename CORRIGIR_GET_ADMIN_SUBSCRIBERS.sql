-- ============================================================================
-- CORRIGIR get_admin_subscribers() para filtrar apenas usuários APROVADOS
-- ============================================================================

-- PROBLEMA: A função atual retorna TODOS os owners, incluindo os 'pending'
-- SOLUÇÃO: Adicionar filtro WHERE status = 'approved'

CREATE OR REPLACE FUNCTION get_admin_subscribers()
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
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin';
  END IF;
  
  -- Retornar apenas os owners APROVADOS (bypassa RLS)
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
    AND ua.status = 'approved'  -- ✅ FILTRO ADICIONADO
  ORDER BY ua.created_at DESC;
END;
$$;

-- Dar permissão
GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO authenticated;

SELECT '✅ Função get_admin_subscribers() atualizada com filtro de status!' as resultado;

-- VERIFICAR: Quantos usuários aparecerão agora
SELECT 
  '📊 TESTE DA FUNÇÃO CORRIGIDA:' as info,
  COUNT(*) as total_usuarios
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved';

-- VERIFICAR: Listar todos que aparecerão
SELECT 
  '📋 USUÁRIOS QUE APARECERÃO NO ADMIN:' as info,
  email,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved'
ORDER BY created_at DESC;
