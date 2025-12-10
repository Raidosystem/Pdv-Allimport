-- ========================================
-- RPC PARA BUSCAR DADOS DA EMPRESA DO USUÁRIO
-- ========================================
-- Esta função bypassa RLS de forma segura usando SECURITY DEFINER

-- Remover função se existir
DROP FUNCTION IF EXISTS get_empresa_do_usuario();

-- Criar função
CREATE OR REPLACE FUNCTION get_empresa_do_usuario()
RETURNS TABLE (
  nome text,
  plano text,
  status text,
  assinatura_expires_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com permissões do dono da função
AS $$
BEGIN
  -- Buscar empresa e assinatura do usuário autenticado
  RETURN QUERY
  SELECT 
    e.nome,
    COALESCE(s.plan_type, 'free')::text as plano,
    COALESCE(s.status, 'trial')::text as status,
    s.subscription_end_date as assinatura_expires_at
  FROM empresas e
  INNER JOIN funcionarios f ON f.empresa_id = e.id
  LEFT JOIN subscriptions s ON s.user_id = auth.uid()
  WHERE f.user_id = auth.uid()
  LIMIT 1;
END;
$$;

-- Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION get_empresa_do_usuario() TO authenticated;

-- Comentário
COMMENT ON FUNCTION get_empresa_do_usuario() IS 'Retorna dados da empresa do usuário autenticado';
