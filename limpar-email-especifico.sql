-- ============================================
-- LIMPAR EMAIL ESPECÍFICO: cris-ramos30@hotmail.com
-- Preserva todos os usuários ativos
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR O EMAIL ESPECÍFICO
-- ============================================

-- Verificar no auth.users
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  deleted_at,
  'auth.users' as tabela
FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- Verificar na tabela empresas
SELECT 
  user_id,
  email,
  nome,
  cnpj,
  tipo_conta,
  created_at,
  'empresas' as tabela
FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- ============================================
-- 2️⃣ DELETAR APENAS ESTE EMAIL
-- ============================================

DO $$ 
DECLARE
  v_user_id uuid;
BEGIN
  -- Buscar user_id pelo email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
  LIMIT 1;
  
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '🗑️ Deletando: cris-ramos30@hotmail.com (ID: %)', v_user_id;
    
    -- Deletar da tabela empresas
    DELETE FROM empresas WHERE user_id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de empresas';
    
    -- Deletar do auth.users
    DELETE FROM auth.users WHERE id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de auth.users';
    
    RAISE NOTICE '✅ Email removido com sucesso!';
  ELSE
    RAISE NOTICE '⚠️ Email não encontrado no sistema';
  END IF;
  
  -- Também limpar por email direto na empresas (caso seja órfão)
  DELETE FROM empresas 
  WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
    AND user_id NOT IN (SELECT id FROM auth.users);
  
  RAISE NOTICE '✅ Limpeza completa!';
END $$;

-- ============================================
-- 3️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0
SELECT 
  COUNT(*) as total,
  'Verificando se email foi removido' as descricao
FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- Deve retornar 0
SELECT 
  COUNT(*) as total,
  'Verificando empresas com este email' as descricao
FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- ============================================
-- 4️⃣ TESTAR DISPONIBILIDADE
-- ============================================

-- Testar CPF
SELECT validate_document_uniqueness('28219618809') as teste_cpf;

-- ============================================
-- ✅ AGORA PODE CADASTRAR NOVAMENTE!
-- ============================================
-- Email: cris-ramos30@hotmail.com
-- CPF: 28219618809
