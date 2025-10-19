-- ============================================
-- DELETAR USUÁRIO ESPECÍFICO: cris-ramos30@hotmail.com
-- Script DIRETO e SIMPLES
-- ============================================

-- ============================================
-- 1️⃣ VER O USUÁRIO ANTES DE DELETAR
-- ============================================
SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  i.id as identity_id,
  i.provider
FROM auth.users u
LEFT JOIN auth.identities i ON i.user_id = u.id
WHERE u.email ILIKE '%cris-ramos30%';

-- ============================================
-- 2️⃣ DELETAR O USUÁRIO DIRETAMENTE
-- ============================================

DO $$ 
DECLARE
  v_user_id uuid;
BEGIN
  -- Buscar o ID do usuário
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email ILIKE '%cris-ramos30%'
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado!';
    RETURN;
  END IF;
  
  RAISE NOTICE '🗑️ Deletando usuário ID: %', v_user_id;
  
  -- Deletar na ordem correta (do mais dependente para o menos)
  
  -- 1. Sessions
  DELETE FROM auth.sessions WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Sessions deletadas';
  
  -- 2. Refresh tokens
  DELETE FROM auth.refresh_tokens WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Refresh tokens deletados';
  
  -- 3. MFA factors (se existir)
  BEGIN
    DELETE FROM auth.mfa_factors WHERE user_id = v_user_id;
    RAISE NOTICE '✓ MFA factors deletados';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE 'ℹ️ Tabela mfa_factors não existe ou sem registros';
  END;
  
  -- 4. Identities (IMPORTANTE!)
  DELETE FROM auth.identities WHERE user_id = v_user_id;
  RAISE NOTICE '✓ Identities deletadas';
  
  -- 5. Finalmente, auth.users
  DELETE FROM auth.users WHERE id = v_user_id;
  RAISE NOTICE '✓ Auth.users deletado';
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ SUCESSO! Usuário cris-ramos30@hotmail.com completamente deletado!';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO: %', SQLERRM;
END $$;

-- ============================================
-- 3️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 registros
SELECT 
  COUNT(*) as usuarios_restantes,
  'Deve ser 0' as esperado
FROM auth.users
WHERE email ILIKE '%cris-ramos30%';

SELECT 
  COUNT(*) as identities_restantes,
  'Deve ser 0' as esperado
FROM auth.identities
WHERE identity_data->>'email' ILIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ LISTAR APENAS OS 2 USUÁRIOS ATIVOS
-- ============================================

SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  '✅ ATIVO' as status
FROM auth.users u
WHERE u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
ORDER BY u.email;

-- ============================================
-- ✅ PRONTO!
-- ============================================
-- Após executar este script:
-- 1. O usuário cris-ramos30@hotmail.com será COMPLETAMENTE removido
-- 2. Você poderá cadastrar um novo usuário com esse email
-- 3. Não haverá mais erro "User already registered"
