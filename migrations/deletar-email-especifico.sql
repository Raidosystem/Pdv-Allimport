-- ============================================
-- DELETAR EMAIL ESPECÍFICO COMPLETAMENTE
-- Email: cris-ramos30@hotmail.com
-- ============================================

-- 1️⃣ VERIFICAR SE EXISTE
SELECT 
  'AUTH.USERS' as tabela,
  id,
  email,
  created_at,
  deleted_at,
  CASE 
    WHEN deleted_at IS NOT NULL THEN '❌ Soft deleted'
    ELSE '✅ Ativo'
  END as status
FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

SELECT 
  'EMPRESAS' as tabela,
  user_id,
  email,
  nome,
  cnpj,
  tipo_conta
FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- 2️⃣ DELETAR COMPLETAMENTE
DO $$ 
DECLARE
  v_user_id uuid;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');
  
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '🗑️ Deletando usuário: % (ID: %)', 'cris-ramos30@hotmail.com', v_user_id;
    
    -- Deletar da tabela empresas
    DELETE FROM empresas WHERE user_id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de empresas';
    
    -- Deletar do auth.users
    DELETE FROM auth.users WHERE id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de auth.users';
    
    RAISE NOTICE '✅ Email liberado!';
  ELSE
    RAISE NOTICE '⚠️ Email não encontrado no auth.users';
    
    -- Limpar da tabela empresas mesmo assim
    DELETE FROM empresas 
    WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');
    RAISE NOTICE '✅ Limpeza de empresas concluída';
  END IF;
END $$;

-- 3️⃣ VERIFICAÇÃO FINAL
SELECT 
  COUNT(*) as total,
  'Deve ser 0' as status
FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

SELECT 
  COUNT(*) as total,
  'Deve ser 0' as status
FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- 4️⃣ VALIDAR DISPONIBILIDADE
SELECT 
  '✅ Email liberado para cadastro!' as mensagem,
  'cris-ramos30@hotmail.com' as email;
