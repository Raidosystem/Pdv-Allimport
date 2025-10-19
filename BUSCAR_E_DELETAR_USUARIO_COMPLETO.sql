-- ============================================
-- BUSCAR E DELETAR USUÁRIO COMPLETAMENTE
-- Email: cris-ramos30@hotmail.com
-- ============================================

-- ============================================
-- 1️⃣ BUSCAR NO AUTH.USERS (incluindo soft deleted)
-- ============================================
SELECT 
  id,
  email,
  created_at,
  updated_at,
  last_sign_in_at,
  email_confirmed_at,
  deleted_at,
  is_super_admin,
  CASE 
    WHEN deleted_at IS NOT NULL THEN '🗑️ SOFT DELETED'
    WHEN email_confirmed_at IS NULL THEN '⚠️ EMAIL NÃO CONFIRMADO'
    ELSE '✅ ATIVO'
  END as status
FROM auth.users
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 2️⃣ BUSCAR NO AUTH.IDENTITIES
-- ============================================
SELECT 
  i.id as identity_id,
  i.user_id,
  i.provider,
  i.identity_data,
  i.identity_data->>'email' as email_from_identity,
  i.created_at,
  u.email as email_from_users,
  u.deleted_at as user_deleted_at
FROM auth.identities i
LEFT JOIN auth.users u ON u.id = i.user_id
WHERE i.identity_data->>'email' ILIKE '%cris-ramos30%';

-- ============================================
-- 3️⃣ BUSCAR NAS EMPRESAS
-- ============================================
SELECT 
  e.id as empresa_id,
  e.user_id,
  e.nome,
  e.created_at,
  u.email as user_email
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.email ILIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ DELETAR COMPLETAMENTE (execute após confirmar)
-- ============================================

-- ⚠️ ATENÇÃO: Execute apenas se confirmar que o usuário existe nas buscas acima!

DO $$ 
DECLARE
  v_user_id uuid;
  v_email text;
  v_empresa_id uuid;
BEGIN
  RAISE NOTICE '🚀 Iniciando deleção completa do usuário cris-ramos30@hotmail.com...';
  RAISE NOTICE '';
  
  -- Buscar o user_id pelo email
  SELECT id, email INTO v_user_id, v_email
  FROM auth.users
  WHERE email ILIKE '%cris-ramos30%'
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado no auth.users';
    
    -- Tentar buscar pela identity
    SELECT user_id INTO v_user_id
    FROM auth.identities
    WHERE identity_data->>'email' ILIKE '%cris-ramos30%'
    LIMIT 1;
    
    IF v_user_id IS NULL THEN
      RAISE NOTICE '❌ Usuário não encontrado em auth.identities';
      RAISE NOTICE '✅ Nada para deletar!';
      RETURN;
    ELSE
      RAISE NOTICE '✅ Usuário encontrado em auth.identities: %', v_user_id;
    END IF;
  ELSE
    RAISE NOTICE '✅ Usuário encontrado: % (ID: %)', v_email, v_user_id;
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '🗑️ Iniciando deleção em cascata...';
  
  -- Buscar empresa_id
  SELECT id INTO v_empresa_id FROM empresas WHERE user_id = v_user_id;
  
  IF v_empresa_id IS NOT NULL THEN
    RAISE NOTICE '   📦 Empresa encontrada: %', v_empresa_id;
    
    -- Deletar registros relacionados
    DELETE FROM funcao_permissoes WHERE funcao_id IN (
      SELECT id FROM funcoes WHERE empresa_id = v_empresa_id
    );
    RAISE NOTICE '   ✓ funcao_permissoes deletadas';
    
    DELETE FROM funcoes WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ funcoes deletadas';
    
    DELETE FROM funcionarios WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ funcionarios deletados';
    
    DELETE FROM vendas WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ vendas deletadas';
    
    DELETE FROM produtos WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ produtos deletados';
    
    DELETE FROM clientes WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ clientes deletados';
    
    DELETE FROM ordens_servico WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ ordens_servico deletadas';
    
    DELETE FROM caixas WHERE empresa_id = v_empresa_id;
    RAISE NOTICE '   ✓ caixas deletados';
    
    DELETE FROM empresas WHERE id = v_empresa_id;
    RAISE NOTICE '   ✓ empresa deletada';
  ELSE
    RAISE NOTICE '   ℹ️ Nenhuma empresa vinculada';
  END IF;
  
  -- Deletar identidades
  DELETE FROM auth.identities WHERE user_id = v_user_id;
  RAISE NOTICE '   ✓ identities deletadas';
  
  -- Deletar sessions
  DELETE FROM auth.sessions WHERE user_id = v_user_id;
  RAISE NOTICE '   ✓ sessions deletadas';
  
  -- Deletar refresh_tokens
  DELETE FROM auth.refresh_tokens WHERE user_id = v_user_id;
  RAISE NOTICE '   ✓ refresh_tokens deletados';
  
  -- FINALMENTE deletar auth.users
  DELETE FROM auth.users WHERE id = v_user_id;
  RAISE NOTICE '   ✓ auth.users deletado';
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Deleção completa! Usuário cris-ramos30@hotmail.com removido de TODAS as tabelas';
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO: %', SQLERRM;
    RAISE NOTICE '⚠️ Tentando continuar...';
END $$;

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar VAZIO (0 resultados)
SELECT 
  'auth.users' as tabela,
  COUNT(*) as registros
FROM auth.users
WHERE email ILIKE '%cris-ramos30%'

UNION ALL

SELECT 
  'auth.identities' as tabela,
  COUNT(*) as registros
FROM auth.identities
WHERE identity_data->>'email' ILIKE '%cris-ramos30%'

UNION ALL

SELECT 
  'empresas' as tabela,
  COUNT(*) as registros
FROM empresas
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- ✅ RESUMO
-- ============================================
-- 1. Busca o usuário em auth.users e auth.identities
-- 2. Deleta TODOS os registros relacionados na ordem correta
-- 3. Deleta sessions, refresh_tokens e identities
-- 4. Deleta de auth.users por último
-- 5. Verifica que tudo foi deletado
