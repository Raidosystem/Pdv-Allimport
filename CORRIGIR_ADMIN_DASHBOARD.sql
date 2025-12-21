-- ============================================
-- CORRIGIR ADMIN DASHBOARD - ERR_CONNECTION_CLOSED
-- ============================================

-- PASSO 1: Verificar se user_approvals existe
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_approvals')
    THEN '✅ Tabela user_approvals EXISTE'
    ELSE '❌ Tabela user_approvals NÃO EXISTE'
  END as status_tabela;

-- PASSO 2: Verificar políticas RLS de user_approvals
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'user_approvals';

-- PASSO 3: Criar função RPC para admin ver todos os dados
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

-- Dar permissão
GRANT EXECUTE ON FUNCTION get_admin_subscribers() TO authenticated;

-- PASSO 4: Verificar se função get_all_empresas_admin existe
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_all_empresas_admin')
    THEN '✅ Função get_all_empresas_admin EXISTE'
    ELSE '❌ Função get_all_empresas_admin NÃO EXISTE'
  END as status_funcao;

-- PASSO 5: Criar função se não existir
CREATE OR REPLACE FUNCTION get_all_empresas_admin()
RETURNS TABLE (
  user_id UUID,
  tipo_conta VARCHAR,
  data_cadastro TIMESTAMPTZ,
  data_fim_teste TIMESTAMPTZ
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
  
  -- Retornar TODAS as empresas (bypassa RLS)
  RETURN QUERY
  SELECT 
    e.user_id,
    e.tipo_conta,
    e.data_cadastro,
    e.data_fim_teste
  FROM empresas e
  ORDER BY e.data_cadastro DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_all_empresas_admin() TO authenticated;

-- PASSO 6: Criar função para ver todas as subscriptions
CREATE OR REPLACE FUNCTION get_all_subscriptions_admin()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  email VARCHAR,
  plan_type VARCHAR,
  status VARCHAR,
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
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'novaradiosystem@outlook.com'
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

-- PASSO 7: Teste final
SELECT 
  '🎯 FUNÇÕES CRIADAS:' as resultado
UNION ALL
SELECT '✅ get_admin_subscribers()'
UNION ALL
SELECT '✅ get_all_empresas_admin()'
UNION ALL
SELECT '✅ get_all_subscriptions_admin()';
