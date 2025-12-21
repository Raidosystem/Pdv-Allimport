-- ============================================
-- CORRIGIR get_all_subscriptions_admin (id ambíguo)
-- ============================================

DROP FUNCTION IF EXISTS get_all_subscriptions_admin();

CREATE OR REPLACE FUNCTION get_all_subscriptions_admin()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  email TEXT,
  plan_type TEXT,
  status TEXT,
  trial_start_date TIMESTAMPTZ,
  trial_end_date TIMESTAMPTZ,
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ
)
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar se é super admin (qualificar com alias)
  IF NOT EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid() 
    AND u.email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin';
  END IF;
  
  -- Retornar TODAS as subscriptions (bypassa RLS)
  RETURN QUERY
  SELECT 
    s.id,
    s.user_id,
    s.email,
    s.plan_type,
    s.status,
    s.trial_start_date,
    s.trial_end_date,
    s.subscription_start_date,
    s.subscription_end_date,
    s.created_at
  FROM subscriptions s
  ORDER BY s.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_all_subscriptions_admin() TO authenticated;

SELECT '✅ Função get_all_subscriptions_admin() corrigida!' as resultado;
