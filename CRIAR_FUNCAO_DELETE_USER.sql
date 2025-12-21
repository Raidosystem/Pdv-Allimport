-- ========================================
-- FUNÇÃO PARA EXCLUIR USUÁRIO (service_role)
-- ========================================
-- Esta função permite que o frontend delete usuários
-- sem expor a service_role key no código

-- 1. Criar a função que deleta usuário do auth.users
CREATE OR REPLACE FUNCTION delete_user_account(target_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com privilégios do owner (pode acessar auth.users)
SET search_path = public
AS $$
DECLARE
  result JSON;
BEGIN
  -- 🔒 VERIFICAÇÃO DE SEGURANÇA: Apenas super admin pode executar
  -- Verifica se o usuário atual é novaradiosystem@outlook.com
  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = auth.uid()
    AND email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado: apenas super admin pode excluir usuários';
  END IF;

  -- ✅ Executar exclusão do usuário no auth.users
  DELETE FROM auth.users
  WHERE id = target_user_id;

  -- Verificar se deletou
  IF NOT FOUND THEN
    result := json_build_object(
      'success', false,
      'message', 'Usuário não encontrado'
    );
  ELSE
    result := json_build_object(
      'success', true,
      'message', 'Usuário excluído com sucesso'
    );
  END IF;

  RETURN result;
END;
$$;

-- 2. Dar permissão para authenticated users executarem
GRANT EXECUTE ON FUNCTION delete_user_account(UUID) TO authenticated;

-- 3. Comentário explicativo
COMMENT ON FUNCTION delete_user_account(UUID) IS 
'Deleta um usuário do auth.users. Apenas novaradiosystem@outlook.com pode executar.';

-- ========================================
-- TESTE (executar como super admin)
-- ========================================
-- SELECT delete_user_account('UUID_DO_USUARIO_TESTE');
