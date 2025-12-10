-- ============================================
-- LIMPAR USUÁRIO COMPLETAMENTE
-- Email: cris-ramos30@hotmail.com
-- CPF: 28219618809
-- ============================================

-- IMPORTANTE: Execute este script no SQL Editor do Supabase
-- https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql/new

-- ============================================
-- 1️⃣ VERIFICAR O QUE EXISTE
-- ============================================

-- Verificar no auth.users
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  deleted_at,
  'auth.users' as origem
FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

-- Verificar na tabela empresas
SELECT 
  user_id,
  email,
  nome,
  cnpj,
  ativo,
  deleted_at,
  'empresas' as origem
FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
   OR REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809';

-- ============================================
-- 2️⃣ BUSCAR user_id PARA DELETAR TUDO
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
    RAISE NOTICE '✅ Encontrado user_id: %', v_user_id;
    
    -- Deletar de todas as tabelas relacionadas
    RAISE NOTICE '🗑️ Deletando vendas...';
    DELETE FROM vendas WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando produtos...';
    DELETE FROM produtos WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando clientes...';
    DELETE FROM clientes WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando funcionarios...';
    DELETE FROM funcionarios WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando caixa...';
    DELETE FROM caixa WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando ordens_servico...';
    DELETE FROM ordens_servico WHERE empresa_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando empresas...';
    DELETE FROM empresas WHERE user_id = v_user_id;
    
    RAISE NOTICE '🗑️ Deletando auth.users...';
    DELETE FROM auth.users WHERE id = v_user_id;
    
    RAISE NOTICE '✅ Usuário completamente deletado!';
  ELSE
    RAISE NOTICE '⚠️ Usuário não encontrado no auth.users';
    
    -- Mesmo assim, limpar registros órfãos na tabela empresas
    RAISE NOTICE '🗑️ Limpando registros órfãos na tabela empresas...';
    DELETE FROM empresas 
    WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
       OR REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809';
  END IF;
END $$;

-- ============================================
-- 3️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 linhas
SELECT COUNT(*) as total_auth FROM auth.users 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com');

SELECT COUNT(*) as total_empresas FROM empresas
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
   OR REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809';

-- ============================================
-- 4️⃣ TESTAR DISPONIBILIDADE
-- ============================================

-- Deve retornar: {"valid": true, "document_type": "CPF", "message": "CPF disponível para cadastro"}
SELECT validate_document_uniqueness('28219618809') as validacao_cpf;

-- ============================================
-- 5️⃣ PRONTO! Agora pode cadastrar novamente
-- ============================================
-- ✅ Email liberado: cris-ramos30@hotmail.com
-- ✅ CPF liberado: 28219618809
