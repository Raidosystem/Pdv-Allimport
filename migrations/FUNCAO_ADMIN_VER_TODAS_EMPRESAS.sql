-- =========================================
-- FUNÇÃO ADMIN: Ver TODAS as empresas
-- =========================================
-- Super admin precisa ver todas as empresas no painel
-- RLS bloqueia acesso, então criamos função que bypassa

CREATE OR REPLACE FUNCTION get_all_empresas_admin()
RETURNS TABLE (
  user_id UUID,
  tipo_conta VARCHAR,
  data_cadastro TIMESTAMPTZ,
  data_fim_teste TIMESTAMPTZ
)
SECURITY DEFINER -- Executa com privilégios do dono da função
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar se quem está chamando é o super admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin pode ver todas as empresas';
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

-- Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION get_all_empresas_admin() TO authenticated;

-- NOTA: A função só pode ser chamada pelo super admin (novaradiosystem@outlook.com)
-- quando logado no sistema. Não pode ser testada diretamente no SQL Editor.
