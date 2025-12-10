-- ============================================
-- DELETAR TODOS OS USUÁRIOS EXCETO OS 2 ATIVOS
-- Inclui limpeza completa de identities, sessions, refresh_tokens
-- Preserva: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- ============================================

-- ============================================
-- 1️⃣ VER TODOS OS USUÁRIOS (incluindo orphans em identities)
-- ============================================

-- Usuários em auth.users
SELECT 
  'auth.users' as origem,
  u.id,
  u.email,
  u.created_at,
  u.deleted_at,
  CASE 
    WHEN u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN '✅ PRESERVAR'
    WHEN u.deleted_at IS NOT NULL THEN '🗑️ SOFT DELETED - Deletar'
    ELSE '❌ DELETAR'
  END as acao
FROM auth.users u
ORDER BY 
  CASE 
    WHEN u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN 0
    ELSE 1
  END,
  u.email;

-- Identities órfãs (sem usuário correspondente)
SELECT 
  'auth.identities (órfãs)' as origem,
  i.id as identity_id,
  i.user_id,
  i.identity_data->>'email' as email,
  i.created_at,
  '🗑️ ÓRFÃ - Deletar' as acao
FROM auth.identities i
LEFT JOIN auth.users u ON u.id = i.user_id
WHERE u.id IS NULL;

-- ============================================
-- 2️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_deletar,
  (SELECT COUNT(*) FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_preservar,
  (SELECT COUNT(*) FROM auth.identities WHERE user_id NOT IN (
    SELECT id FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  )) as identities_a_deletar,
  (SELECT COUNT(*) FROM auth.sessions WHERE user_id NOT IN (
    SELECT id FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  )) as sessions_a_deletar;

-- ============================================
-- 3️⃣ DELETAR COMPLETAMENTE (auth.users + identities + sessions + tokens)
-- ============================================

DO $$ 
DECLARE
  v_user_id uuid;
  v_email text;
  v_count int;
  v_total_users_deletado int := 0;
  v_total_identities_deletado int := 0;
  v_total_sessions_deletado int := 0;
  v_total_refresh_tokens_deletado int := 0;
  v_total_empresas_deletado int := 0;
  v_emails_ativos text[] := ARRAY['novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com'];
BEGIN
  RAISE NOTICE '🚀 Iniciando limpeza COMPLETA de usuários...';
  RAISE NOTICE '✅ Preservando: % e %', v_emails_ativos[1], v_emails_ativos[2];
  RAISE NOTICE '';
  
  -- ============================================
  -- PARTE 1: DELETAR USUÁRIOS E SEUS RELACIONAMENTOS
  -- ============================================
  
  FOR v_user_id, v_email IN 
    SELECT id, email
    FROM auth.users
    WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  LOOP
    BEGIN
      RAISE NOTICE '🗑️ Deletando usuário: % (ID: %)', v_email, v_user_id;
      
      -- Deletar empresa e relacionamentos (se existir)
      DECLARE
        v_empresa_id uuid;
      BEGIN
        SELECT id INTO v_empresa_id FROM empresas WHERE user_id = v_user_id;
        
        IF v_empresa_id IS NOT NULL THEN
          DELETE FROM funcao_permissoes WHERE funcao_id IN (SELECT id FROM funcoes WHERE empresa_id = v_empresa_id);
          DELETE FROM funcoes WHERE empresa_id = v_empresa_id;
          DELETE FROM funcionarios WHERE empresa_id = v_empresa_id;
          DELETE FROM vendas WHERE empresa_id = v_empresa_id;
          DELETE FROM produtos WHERE empresa_id = v_empresa_id;
          DELETE FROM clientes WHERE empresa_id = v_empresa_id;
          DELETE FROM ordens_servico WHERE empresa_id = v_empresa_id;
          DELETE FROM caixas WHERE empresa_id = v_empresa_id;
          DELETE FROM empresas WHERE id = v_empresa_id;
          v_total_empresas_deletado := v_total_empresas_deletado + 1;
          RAISE NOTICE '   ✓ Empresa e relacionamentos deletados';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE '   ⚠️ Erro ao deletar empresa: %', SQLERRM;
      END;
      
      -- Deletar sessions
      DELETE FROM auth.sessions WHERE user_id = v_user_id;
      GET DIAGNOSTICS v_count = ROW_COUNT;
      v_total_sessions_deletado := v_total_sessions_deletado + v_count;
      
      -- Deletar refresh_tokens
      DELETE FROM auth.refresh_tokens WHERE user_id = v_user_id;
      GET DIAGNOSTICS v_count = ROW_COUNT;
      v_total_refresh_tokens_deletado := v_total_refresh_tokens_deletado + v_count;
      
      -- Deletar MFA factors (se existir)
      BEGIN
        DELETE FROM auth.mfa_factors WHERE user_id = v_user_id;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      
      -- Deletar identities
      DELETE FROM auth.identities WHERE user_id = v_user_id;
      GET DIAGNOSTICS v_count = ROW_COUNT;
      v_total_identities_deletado := v_total_identities_deletado + v_count;
      
      -- Deletar auth.users
      DELETE FROM auth.users WHERE id = v_user_id;
      
      v_total_users_deletado := v_total_users_deletado + 1;
      RAISE NOTICE '   ✅ Usuário completamente deletado';
      RAISE NOTICE '';
      
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '   ❌ ERRO ao deletar %: %', v_email, SQLERRM;
        RAISE NOTICE '   Continuando...';
        RAISE NOTICE '';
    END;
  END LOOP;
  
  -- ============================================
  -- PARTE 2: LIMPAR IDENTITIES ÓRFÃS
  -- ============================================
  
  RAISE NOTICE '🧹 Limpando identities órfãs...';
  
  DELETE FROM auth.identities 
  WHERE user_id NOT IN (
    SELECT id FROM auth.users 
    WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  );
  
  RAISE NOTICE '✓ Identities órfãs limpas';
  RAISE NOTICE '';
  
  -- ============================================
  -- PARTE 3: LIMPAR SESSIONS ÓRFÃS
  -- ============================================
  
  RAISE NOTICE '🧹 Limpando sessions órfãs...';
  
  DELETE FROM auth.sessions 
  WHERE user_id NOT IN (
    SELECT id FROM auth.users 
    WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  );
  
  RAISE NOTICE '✓ Sessions órfãs limpas';
  RAISE NOTICE '';
  
  -- ============================================
  -- PARTE 4: LIMPAR REFRESH_TOKENS ÓRFÃOS
  -- ============================================
  
  RAISE NOTICE '🧹 Limpando refresh_tokens órfãos...';
  
  -- Usar LEFT JOIN ao invés de NOT IN para evitar problemas de tipo
  DELETE FROM auth.refresh_tokens rt
  USING (
    SELECT rt2.id
    FROM auth.refresh_tokens rt2
    LEFT JOIN auth.users u ON rt2.user_id = u.id::text
    WHERE u.id IS NULL OR u.email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  ) as tokens_to_delete
  WHERE rt.id = tokens_to_delete.id;
  
  RAISE NOTICE '✓ Refresh_tokens órfãos limpos';
  RAISE NOTICE '';
  
  -- ============================================
  -- RESUMO FINAL
  -- ============================================
  
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '✅ LIMPEZA COMPLETA FINALIZADA!';
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Estatísticas:';
  RAISE NOTICE '   • Usuários deletados: %', v_total_users_deletado;
  RAISE NOTICE '   • Empresas deletadas: %', v_total_empresas_deletado;
  RAISE NOTICE '   • Identities deletadas: %', v_total_identities_deletado;
  RAISE NOTICE '   • Sessions deletadas: %', v_total_sessions_deletado;
  RAISE NOTICE '   • Refresh tokens deletados: %', v_total_refresh_tokens_deletado;
  RAISE NOTICE '';
  RAISE NOTICE '✅ Preservados: % e %', v_emails_ativos[1], v_emails_ativos[2];
  
END $$;

-- ============================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 (todos deletados)
SELECT 
  COUNT(*) as total_nao_ativos,
  'Usuários NÃO ativos restantes (deve ser 0)' as descricao
FROM auth.users
WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- Deve retornar 2 (apenas os ativos)
SELECT 
  COUNT(*) as total_ativos,
  'Usuários ativos preservados (deve ser 2)' as descricao
FROM auth.users
WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- Verificar identities órfãs (deve ser 0)
SELECT 
  COUNT(*) as identities_orfas,
  'Identities órfãs (deve ser 0)' as descricao
FROM auth.identities
WHERE user_id NOT IN (
  SELECT id FROM auth.users 
  WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
);

-- Verificar sessions órfãs (deve ser 0)
SELECT 
  COUNT(*) as sessions_orfas,
  'Sessions órfãs (deve ser 0)' as descricao
FROM auth.sessions s
LEFT JOIN auth.users u ON s.user_id = u.id
WHERE u.id IS NULL OR u.email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- ============================================
-- 5️⃣ LISTAR USUÁRIOS ATIVOS PRESERVADOS
-- ============================================

SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  (SELECT COUNT(*) FROM auth.identities WHERE user_id = u.id) as identities_count,
  '✅ ATIVO - Preservado' as status
FROM auth.users u
WHERE u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
ORDER BY u.email;

-- ============================================
-- ✅ RESUMO
-- ============================================
-- Este script faz limpeza COMPLETA:
-- 1. Deleta TODOS os usuários exceto os 2 ativos
-- 2. Deleta TODAS as empresas e relacionamentos
-- 3. Deleta TODAS as identities (incluindo órfãs)
-- 4. Deleta TODAS as sessions (incluindo órfãs)
-- 5. Deleta TODOS os refresh_tokens (incluindo órfãos)
-- 6. Preserva APENAS: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- 7. Sistema 100% limpo e pronto para novos cadastros!
