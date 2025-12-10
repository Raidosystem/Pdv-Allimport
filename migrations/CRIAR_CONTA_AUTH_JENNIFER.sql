-- ============================================
-- 🔧 CRIAR CONTA SUPABASE AUTH PARA JENNIFER
-- ============================================
-- Jennifer precisa ter conta no auth.users para persistir sessão
-- Executar no Supabase SQL Editor
-- ============================================

DO $$
DECLARE
  v_jennifer_funcionario_id uuid;
  v_jennifer_email text := 'sousajenifer895@gmail.com';
  v_jennifer_senha text := '123456';
  v_auth_user_id uuid;
BEGIN
  -- 1. Buscar Jennifer na tabela funcionarios
  SELECT id INTO v_jennifer_funcionario_id
  FROM funcionarios
  WHERE email = v_jennifer_email
  LIMIT 1;

  IF v_jennifer_funcionario_id IS NULL THEN
    RAISE EXCEPTION '❌ Jennifer não encontrada na tabela funcionarios';
  END IF;

  RAISE NOTICE '✅ Jennifer encontrada: %', v_jennifer_funcionario_id;

  -- 2. Verificar se Jennifer já tem user_id (conta auth.users)
  SELECT user_id INTO v_auth_user_id
  FROM funcionarios
  WHERE id = v_jennifer_funcionario_id;

  IF v_auth_user_id IS NOT NULL THEN
    RAISE NOTICE 'ℹ️  Jennifer já tem conta auth.users: %', v_auth_user_id;
    RAISE NOTICE '✅ Sistema já configurado corretamente!';
    RETURN;
  END IF;

  RAISE NOTICE '⚠️  Jennifer NÃO tem conta no auth.users';
  RAISE NOTICE '📝 Para criar conta, use o painel do Supabase:';
  RAISE NOTICE '   1. Acesse: Authentication > Users';
  RAISE NOTICE '   2. Clique em "Add user"';
  RAISE NOTICE '   3. Email: %', v_jennifer_email;
  RAISE NOTICE '   4. Senha: %', v_jennifer_senha;
  RAISE NOTICE '   5. Auto Confirm User: SIM';
  RAISE NOTICE '   6. Após criar, execute: UPDATE funcionarios SET user_id = ''[novo_user_id]'' WHERE id = ''%'';', v_jennifer_funcionario_id;

END $$;

-- Verificar estado atual
SELECT 
  'Jennifer - Estado Atual' as info,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  f.funcao_id,
  fc.nome as funcao,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ SEM CONTA AUTH.USERS'
    ELSE '✅ TEM CONTA AUTH.USERS'
  END as status_auth
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';
