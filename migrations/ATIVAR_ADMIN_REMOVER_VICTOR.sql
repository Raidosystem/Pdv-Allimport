-- =====================================================
-- ATIVAR ADMIN E REMOVER VICTOR
-- =====================================================
-- 1. Remove Victor (que tem acesso mas não é Admin)
-- 2. Garante que Cristiano (Admin) tenha acesso total

-- =====================================================
-- PARTE 1: REMOVER VICTOR
-- =====================================================
DO $$
DECLARE
  v_victor_id UUID;
  v_user_id UUID;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🗑️ Removendo Victor...';
  
  -- Buscar primeira empresa
  SELECT id INTO v_empresa_id
  FROM empresas 
  WHERE nome = 'Assistência All-Import'
  ORDER BY created_at ASC
  LIMIT 1;
  
  -- Buscar Victor
  SELECT id INTO v_victor_id
  FROM funcionarios
  WHERE nome = 'Victor'
  AND empresa_id = v_empresa_id
  LIMIT 1;
  
  IF v_victor_id IS NOT NULL THEN
    -- Buscar user_id se tiver email
    SELECT au.id INTO v_user_id
    FROM funcionarios f
    JOIN auth.users au ON au.email = f.email
    WHERE f.id = v_victor_id;
    
    -- Remover de funcionarios
    DELETE FROM funcionarios WHERE id = v_victor_id;
    
    -- Remover de user_approvals se existir
    IF v_user_id IS NOT NULL THEN
      DELETE FROM user_approvals WHERE user_id = v_user_id;
      RAISE NOTICE '  ⚠️ ATENÇÃO: Remova o usuário Victor do Authentication no Dashboard do Supabase';
    END IF;
    
    RAISE NOTICE '✅ Victor removido com sucesso';
  ELSE
    RAISE NOTICE '⚠️ Victor não encontrado';
  END IF;
END $$;

-- =====================================================
-- PARTE 2: VERIFICAR STATUS DO ADMIN (CRISTIANO)
-- =====================================================
SELECT 
  '👑 STATUS DO ADMIN' as info,
  f.nome,
  f.email,
  e.nome as empresa,
  fn.nome as funcao,
  f.status,
  CASE 
    WHEN ua.approved_at IS NOT NULL THEN '✅ APROVADO'
    WHEN ua.approved_at IS NULL AND ua.user_id IS NOT NULL THEN '⚠️ PENDENTE'
    ELSE '❌ SEM REGISTRO'
  END as aprovacao
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
LEFT JOIN auth.users au ON au.email = f.email
LEFT JOIN user_approvals ua ON ua.user_id = au.id
WHERE f.email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- PARTE 3: ATIVAR ACESSO DO ADMIN
-- =====================================================
DO $$
DECLARE
  v_cristiano_user_id UUID;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '👑 Ativando acesso do Admin (Cristiano)...';
  
  -- Buscar empresa
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE nome = 'Assistência All-Import'
  ORDER BY created_at ASC
  LIMIT 1;
  
  -- Buscar user_id do Cristiano
  SELECT id INTO v_cristiano_user_id
  FROM auth.users
  WHERE email = 'assistenciaallimport10@gmail.com';
  
  IF v_cristiano_user_id IS NOT NULL AND v_empresa_id IS NOT NULL THEN
    -- Atualizar ou criar registro em user_approvals
    INSERT INTO user_approvals (user_id, empresa_id, approved_at, approved_by, user_role)
    VALUES (v_cristiano_user_id, v_empresa_id, NOW(), v_cristiano_user_id, 'admin')
    ON CONFLICT (user_id) 
    DO UPDATE SET 
      approved_at = NOW(),
      approved_by = v_cristiano_user_id,
      user_role = 'admin',
      empresa_id = v_empresa_id;
    
    -- Garantir que funcionario está ativo
    UPDATE funcionarios
    SET status = 'ativo'
    WHERE email = 'assistenciaallimport10@gmail.com';
    
    RAISE NOTICE '✅ Cristiano ativado como Admin com acesso total';
  ELSE
    RAISE NOTICE '⚠️ Usuário ou empresa não encontrado';
  END IF;
END $$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '👥 FUNCIONÁRIOS FINAIS' as info,
  f.nome,
  f.email,
  e.nome as empresa,
  fn.nome as funcao,
  f.status,
  CASE 
    WHEN ua.approved_at IS NOT NULL THEN '✅ COM ACESSO'
    ELSE '❌ SEM ACESSO'
  END as acesso
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
LEFT JOIN auth.users au ON au.email = f.email
LEFT JOIN user_approvals ua ON ua.user_id = au.id
WHERE e.nome = 'Assistência All-Import'
  AND e.created_at = (SELECT MIN(created_at) FROM empresas WHERE nome = 'Assistência All-Import')
ORDER BY fn.nome NULLS LAST, f.nome;
