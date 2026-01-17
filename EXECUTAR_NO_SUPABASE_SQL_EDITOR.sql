-- ============================================================================
-- EXECUTAR NO SQL EDITOR DO SUPABASE (usa service_role automaticamente)
-- ============================================================================

-- 1️⃣ Ver se smartcellinova está aprovado
SELECT 
  '🔍 SMARTCELLINOVA:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' 
    THEN '✅ DEVE APARECER NO ADMIN'
    WHEN status != 'approved'
    THEN '❌ Status: ' || status
    WHEN user_role != 'owner'
    THEN '❌ Role: ' || COALESCE(user_role, 'NULL')
    ELSE '❓ VERIFICAR'
  END as diagnostico
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- 2️⃣ Ver TODOS os 6 usuários aprovados
SELECT 
  '📋 TODOS OS 6 APROVADOS:' as info,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE status = 'approved' AND user_role = 'owner'
ORDER BY created_at DESC;

-- 3️⃣ CORRIGIR a função get_admin_subscribers (adicionar filtro de status)

-- ✅ IMPORTANTE: Dropar a função antiga primeiro
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
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin';
  END IF;
  
  -- ✅ CORREÇÃO: Adicionar filtro status = 'approved'
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

GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO authenticated;

SELECT '✅ Função get_admin_subscribers() corrigida!' as resultado;

-- 4️⃣ Testar a função corrigida (simulando super admin)
SELECT 
  '🧪 TESTE DA FUNÇÃO CORRIGIDA:' as info,
  email,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved'
ORDER BY created_at DESC;
