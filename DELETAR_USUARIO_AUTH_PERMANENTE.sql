-- ========================================
-- SCRIPT DE EXCLUSÃO PERMANENTE DE USUÁRIOS
-- ========================================
-- Este script deve ser executado no SQL Editor do Supabase
-- quando necessário excluir permanentemente a conta de autenticação de um usuário
--
-- ATENÇÃO: Esta ação é IRREVERSÍVEL!
-- ========================================

-- 1. LISTAR TODOS OS USUÁRIOS PARA IDENTIFICAR O ID
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  raw_user_meta_data->>'full_name' as nome
FROM auth.users
ORDER BY email;

-- ========================================
-- 2. DELETAR USUÁRIO ESPECÍFICO POR EMAIL
-- ========================================
-- Substitua 'usuario@example.com' pelo email do usuário

-- Opção A: Deletar por email
DELETE FROM auth.users 
WHERE email = 'usuario@example.com';

-- Opção B: Deletar por ID
-- DELETE FROM auth.users 
-- WHERE id = 'uuid-do-usuario-aqui';

-- ========================================
-- 3. VERIFICAR SE FOI DELETADO
-- ========================================
SELECT 
  id,
  email,
  deleted_at
FROM auth.users
WHERE email = 'usuario@example.com';

-- Se não retornar nenhum resultado, foi deletado com sucesso!

-- ========================================
-- 4. DELETAR MÚLTIPLOS USUÁRIOS (CUIDADO!)
-- ========================================
-- DELETE FROM auth.users 
-- WHERE email IN (
--   'usuario1@example.com',
--   'usuario2@example.com',
--   'usuario3@example.com'
-- );

-- ========================================
-- 5. DELETAR USUÁRIOS INATIVOS HÁ MAIS DE 90 DIAS
-- ========================================
-- DELETE FROM auth.users 
-- WHERE last_sign_in_at < NOW() - INTERVAL '90 days'
-- AND email NOT IN (
--   'admin@example.com', -- Proteger emails importantes
--   'suporte@example.com'
-- );

-- ========================================
-- OBSERVAÇÕES IMPORTANTES:
-- ========================================
-- 1. Antes de executar a exclusão via SQL, o sistema já deve ter deletado:
--    - Registro na tabela 'funcionarios'
--    - Produtos do usuário
--    - Clientes do usuário
--    - Vendas do usuário
--    - Ordens de serviço do usuário
--
-- 2. A exclusão via auth.users é automática em cascata para:
--    - Sessões ativas (auth.sessions)
--    - Tokens de refresh (auth.refresh_tokens)
--
-- 3. Se precisar restaurar, NÃO HÁ COMO - faça backup antes!
--
-- 4. Para ter capacidade de exclusão via código, seria necessário:
--    - Usar SUPABASE_SERVICE_ROLE_KEY (não recomendado no frontend)
--    - Criar uma Edge Function com service_role_key
--    - Configurar RPC function com security definer
-- ========================================

-- ========================================
-- ALTERNATIVA: FUNÇÃO RPC PARA DELETAR VIA CÓDIGO
-- ========================================
-- Execute este bloco completo no SQL Editor do Supabase:

-- Dropar função antiga se existir (para permitir mudança de tipo de retorno)
DROP FUNCTION IF EXISTS admin_delete_user(TEXT);

CREATE OR REPLACE FUNCTION admin_delete_user(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_user_id UUID;
  current_user_email TEXT;
  is_admin BOOLEAN := FALSE;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO current_user_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Verificar se é admin pelo email (lista de admins conhecidos)
  IF current_user_email IN (
    'novaradiosystem@outlook.com',
    'assistenciaallimport10@gmail.com'
  ) THEN
    is_admin := TRUE;
  END IF;

  -- Verificar se tem role admin nos metadados
  IF EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  ) THEN
    is_admin := TRUE;
  END IF;

  -- Se não é admin, retornar erro
  IF NOT is_admin THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'Apenas administradores podem executar esta função',
      'executor', current_user_email
    );
  END IF;

  -- Buscar o ID do usuário pelo email
  SELECT id INTO target_user_id
  FROM auth.users
  WHERE email = user_email;

  -- Se não encontrou, retornar erro
  IF target_user_id IS NULL THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'Usuário não encontrado: ' || user_email
    );
  END IF;

  -- Prevenir que admin delete a si mesmo
  IF target_user_id = auth.uid() THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', 'Você não pode deletar sua própria conta enquanto está logado'
    );
  END IF;

  -- Deletar o usuário (cascata automática para sessions e refresh_tokens)
  DELETE FROM auth.users WHERE id = target_user_id;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', TRUE,
    'message', 'Usuário deletado com sucesso',
    'deleted_email', user_email,
    'deleted_id', target_user_id,
    'deleted_by', current_user_email,
    'deleted_at', NOW()
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', FALSE,
      'error', SQLERRM,
      'sqlstate', SQLSTATE
    );
END;
$$;

-- ========================================
-- PERMISSÕES DA FUNÇÃO RPC
-- ========================================
-- Garantir que apenas usuários autenticados podem executar
GRANT EXECUTE ON FUNCTION admin_delete_user(TEXT) TO authenticated;

-- Revogar de usuários anônimos
REVOKE EXECUTE ON FUNCTION admin_delete_user(TEXT) FROM anon;

-- ========================================
-- TESTAR A FUNÇÃO RPC
-- ========================================
-- Teste 1: Tentar deletar usuário inexistente
-- SELECT admin_delete_user('naoexiste@example.com');

-- Teste 2: Deletar um usuário de teste (se existir)
-- SELECT admin_delete_user('cristiano@gruporaval.com.br');

-- Teste 3: Ver resultado formatado
-- SELECT jsonb_pretty(admin_delete_user('teste@example.com')::jsonb);

-- ========================================
-- VERIFICAR SE A FUNÇÃO FOI CRIADA
-- ========================================
SELECT 
  routine_name,
  routine_type,
  security_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'admin_delete_user';

-- Deve retornar:
-- routine_name: admin_delete_user
-- routine_type: FUNCTION
-- security_type: DEFINER (permite acesso privilegiado)
