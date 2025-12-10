-- ============================================
-- LIMPAR APENAS USUÁRIOS DELETADOS/ÓRFÃOS
-- Mantém todos os usuários ATIVOS intactos
-- ============================================

-- Execute no SQL Editor do Supabase:
-- https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql/new

-- ============================================
-- 1️⃣ VERIFICAR O QUE SERÁ DELETADO
-- ============================================

-- Ver usuários deletados no auth.users (soft delete)
SELECT 
  id,
  email,
  created_at,
  deleted_at,
  '❌ DELETADO - Será limpo' as status
FROM auth.users 
WHERE deleted_at IS NOT NULL;

-- Ver registros órfãos (empresas sem user no auth.users)
SELECT 
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.tipo_conta,
  '❌ ÓRFÃO - Será limpo' as status
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL;

-- ============================================
-- 2️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NOT NULL) as users_deletados,
  (SELECT COUNT(*) FROM empresas e LEFT JOIN auth.users u ON u.id = e.user_id WHERE u.id IS NULL) as empresas_orfas;

-- ============================================
-- 3️⃣ EXECUTAR LIMPEZA
-- ============================================
DO $$ 
DECLARE
  v_user_id uuid;
  v_email text;
  v_total_deletado int := 0;
BEGIN
  RAISE NOTICE '🚀 Iniciando limpeza de usuários deletados...';
  RAISE NOTICE '';
  
  -- Loop por cada empresa deletada/órfã
  FOR v_user_id, v_email IN 
    SELECT DISTINCT e.user_id, e.email
    FROM empresas e
    LEFT JOIN auth.users u ON u.id = e.user_id
    WHERE u.id IS NULL  -- Órfãos
       OR u.deleted_at IS NOT NULL  -- Deletados no auth
  LOOP
    RAISE NOTICE '🗑️ Limpando: % (ID: %)', v_email, v_user_id;
    
    -- Deletar da tabela empresas
    DELETE FROM empresas WHERE user_id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de empresas';
    
    -- Deletar do auth.users (se ainda existir)
    DELETE FROM auth.users WHERE id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de auth.users';
    
    v_total_deletado := v_total_deletado + 1;
    RAISE NOTICE '   ✅ Concluído';
    RAISE NOTICE '';
  END LOOP;
  
  RAISE NOTICE '✅ Limpeza completa! Total de usuários deletados: %', v_total_deletado;
END $$;

-- ============================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 deletados no auth
SELECT 
  COUNT(*) as total_deletados,
  'Usuários com deleted_at no auth.users' as descricao
FROM auth.users 
WHERE deleted_at IS NOT NULL;

-- Deve retornar 0 órfãos
SELECT 
  COUNT(*) as total_orfaos,
  'Empresas sem user no auth.users' as descricao
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL;

-- Ver quantos usuários ATIVOS restaram (estes NÃO foram tocados)
SELECT 
  COUNT(*) as total_ativos,
  'Empresas ativas mantidas' as descricao
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.deleted_at IS NULL;

-- ============================================
-- 5️⃣ LISTAR USUÁRIOS ATIVOS (SEGURANÇA)
-- ============================================

-- Ver todos os usuários ATIVOS que foram preservados
SELECT 
  u.email,
  e.nome,
  e.cnpj,
  e.tipo_conta,
  u.created_at,
  '✅ ATIVO - Preservado' as status
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.deleted_at IS NULL
ORDER BY u.created_at DESC;

-- ============================================
-- ✅ RESUMO DO QUE FOI FEITO
-- ============================================
-- 1. Identificou usuários deletados (deleted_at != NULL no auth.users)
-- 2. Identificou registros órfãos (empresas sem auth.users)
-- 3. Deletou da tabela empresas
-- 4. Deletou do auth.users
-- 5. PRESERVOU todos os usuários ATIVOS intactos
