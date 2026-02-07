-- ============================================================================
-- VERIFICAR E CORRIGIR get_admin_subscribers
-- ============================================================================

-- 1️⃣ Ver se a função existe
SELECT 
  '🔍 FUNÇÃO EXISTE?' as info,
  proname as nome_funcao,
  pronargs as num_argumentos
FROM pg_proc
WHERE proname = 'get_admin_subscribers';

-- 2️⃣ Dropar e recriar a função corretamente
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
  
  -- Retornar apenas os owners APROVADOS
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

SELECT '✅ Função get_admin_subscribers() recriada!' as resultado;

-- 3️⃣ Testar a função
SELECT 
  '🧪 TESTE DA FUNÇÃO:' as info,
  COUNT(*) as total_usuarios
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved';

-- 4️⃣ Listar os usuários que devem aparecer
SELECT 
  '📋 USUÁRIOS QUE DEVEM APARECER:' as info,
  email,
  full_name,
  company_name,
  status,
  user_role
FROM user_approvals
WHERE user_role = 'owner' AND status = 'approved'
ORDER BY created_at DESC;
