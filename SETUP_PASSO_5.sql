-- ================================
-- PASSO 5: FUNÇÕES AUXILIARES
-- ================================

-- Função para verificar status de aprovação
CREATE OR REPLACE FUNCTION check_user_approval_status(user_uuid UUID)
RETURNS TABLE(
  is_approved BOOLEAN,
  status TEXT,
  approved_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (ua.status = 'approved') as is_approved,
    ua.status,
    ua.approved_at
  FROM public.user_approvals ua
  WHERE ua.user_id = user_uuid;
END;
$$;

-- Função para aprovar usuário
CREATE OR REPLACE FUNCTION approve_user(user_email TEXT, admin_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_user_id UUID;
BEGIN
  -- Verificar se quem está executando é admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = admin_user_id 
    AND (
      email = 'admin@pdvallimport.com' 
      OR email = 'novaradiosystem@outlook.com'
      OR email = 'teste@teste.com'
      OR raw_user_meta_data->>'role' = 'admin'
    )
  ) THEN
    RETURN FALSE;
  END IF;

  -- Buscar o user_id pelo email
  SELECT au.id INTO target_user_id
  FROM auth.users au
  WHERE au.email = user_email;

  IF target_user_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Atualizar status para aprovado
  UPDATE public.user_approvals 
  SET 
    status = 'approved',
    approved_by = admin_user_id,
    approved_at = NOW(),
    updated_at = NOW()
  WHERE user_id = target_user_id;

  RETURN TRUE;
END;
$$;
