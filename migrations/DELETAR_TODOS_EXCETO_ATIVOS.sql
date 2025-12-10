-- ============================================
-- DELETAR TODOS OS EMAILS EXCETO OS ATIVOS
-- Preserva: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR TODOS OS EMAILS NO SISTEMA
-- ============================================

-- Ver TODOS os usuários no auth.users
SELECT 
  id,
  email,
  created_at,
  deleted_at,
  email_confirmed_at,
  CASE 
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN '✅ ATIVO - Preservar'
    ELSE '❌ Deletar'
  END as acao
FROM auth.users
ORDER BY 
  CASE 
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN 0
    ELSE 1
  END,
  email;

-- ============================================
-- 2️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_deletar,
  (SELECT COUNT(*) FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_preservar;

-- ============================================
-- 2️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_deletar,
  (SELECT COUNT(*) FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_preservar;

-- ============================================
-- 3️⃣ EXECUTAR LIMPEZA (DELETAR TUDO EXCETO OS 2 ATIVOS)
-- ============================================
DO $$ 
DECLARE
  v_user_id uuid;
  v_email text;
  v_total_deletado int := 0;
  v_emails_ativos text[] := ARRAY['novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com'];
BEGIN
  RAISE NOTICE '🚀 Iniciando limpeza de usuários (preservando 2 ativos)...';
  RAISE NOTICE '';
  
  -- Loop por TODOS os usuários EXCETO os 2 ativos
  FOR v_user_id, v_email IN 
    SELECT id, email
    FROM auth.users
    WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  LOOP
    RAISE NOTICE '🗑️ Deletando: % (ID: %)', v_email, v_user_id;
    
    -- Deletar do auth.users (empresas será deletada por CASCADE ou trigger)
    DELETE FROM auth.users WHERE id = v_user_id;
    RAISE NOTICE '   ✓ Deletado de auth.users';
    
    v_total_deletado := v_total_deletado + 1;
    RAISE NOTICE '   ✅ Concluído';
    RAISE NOTICE '';
  END LOOP;
  
  RAISE NOTICE '✅ Limpeza completa! Total deletado: %', v_total_deletado;
  RAISE NOTICE '✅ Preservados: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com';
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

-- ============================================
-- 5️⃣ LISTAR USUÁRIOS ATIVOS PRESERVADOS
-- ============================================

SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  '✅ ATIVO - Preservado' as status
FROM auth.users u
WHERE u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
ORDER BY u.email;

-- ============================================
-- ✅ RESUMO
-- ============================================
-- 1. Identificou TODOS os usuários no auth.users
-- 2. Preservou APENAS: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- 3. Deletou TODOS os outros do auth.users
-- 4. Registros relacionados serão deletados por CASCADE/trigger
-- 5. Sistema limpo e pronto para novos cadastros
