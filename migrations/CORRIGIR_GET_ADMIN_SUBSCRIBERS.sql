-- ============================================================================
-- CORRIGIR FUNÇÃO get_admin_subscribers PARA MOSTRAR TODOS OS USUÁRIOS
-- ============================================================================
-- Modificar para retornar TODOS os usuários aprovados, não só owners
-- ============================================================================

-- Substituir a função existente
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
  
  -- Retornar TODOS os usuários aprovados (não só owners)
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
  WHERE ua.status = 'approved'  -- Apenas aprovados
  ORDER BY ua.created_at DESC;
END;
$$;

-- Verificar se a função foi atualizada corretamente
SELECT 
  'Função atualizada com sucesso!' as mensagem,
  'Agora retorna TODOS os usuários aprovados' as descricao;
