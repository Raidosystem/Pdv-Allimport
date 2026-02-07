-- =============================================
-- DIAGNÓSTICO: Funcionário criado mas não aparece no login
-- =============================================

-- 1️⃣ VERIFICAR FUNCIONÁRIOS RECENTES (últimos 5)
SELECT 
  '🔍 FUNCIONÁRIOS RECENTES' as info,
  id,
  nome,
  email,
  status,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  created_at
FROM funcionarios
ORDER BY created_at DESC
LIMIT 5;

-- 2️⃣ VERIFICAR LOGIN_FUNCIONARIOS (últimos 5)
SELECT 
  '🔍 LOGINS RECENTES' as info,
  id,
  funcionario_id,
  usuario,
  ativo,
  precisa_trocar_senha,
  created_at
FROM login_funcionarios
ORDER BY created_at DESC
LIMIT 5;

-- 3️⃣ VERIFICAR SE TRIGGER ESTÁ ATIVO
SELECT 
  '🔍 STATUS DO TRIGGER' as info,
  tgname as trigger_name,
  tgenabled as enabled,
  CASE tgenabled
    WHEN 'O' THEN '✅ ATIVO'
    WHEN 'D' THEN '❌ DESABILITADO'
    WHEN 'R' THEN '⚠️ REPLICA ONLY'
    WHEN 'A' THEN '⚠️ ALWAYS'
  END as status,
  CASE 
    WHEN tgtype & 2 = 2 THEN 'BEFORE'
    WHEN tgtype & 4 = 4 THEN 'INSTEAD OF'
    ELSE 'AFTER'
  END as timing
FROM pg_trigger
WHERE tgrelid = 'funcionarios'::regclass
AND tgname = 'trigger_auto_criar_login';

-- 4️⃣ VERIFICAR FUNCIONÁRIOS SEM LOGIN
SELECT 
  '⚠️ FUNCIONÁRIOS SEM LOGIN' as info,
  f.id,
  f.nome,
  f.email,
  f.status,
  f.created_at
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE lf.id IS NULL
ORDER BY f.created_at DESC;

-- 5️⃣ VERIFICAR SE PGCRYPTO ESTÁ ATIVO
SELECT 
  '🔍 EXTENSÃO PGCRYPTO' as info,
  extname,
  extversion,
  CASE WHEN extname IS NOT NULL THEN '✅ INSTALADA' ELSE '❌ NÃO INSTALADA' END as status
FROM pg_extension
WHERE extname = 'pgcrypto';

-- 6️⃣ TESTAR TRIGGER MANUALMENTE
DO $$
DECLARE
  v_test_func_id UUID;
  v_login_criado BOOLEAN;
BEGIN
  -- Criar funcionário de teste
  INSERT INTO funcionarios (
    empresa_id,
    nome,
    email,
    status,
    tipo_admin,
    usuario_ativo,
    funcao_id
  )
  VALUES (
    (SELECT empresa_id FROM funcionarios LIMIT 1), -- Usar empresa existente
    'TESTE TRIGGER ' || NOW()::TEXT,
    'teste_trigger_' || EXTRACT(EPOCH FROM NOW())::TEXT || '@test.com',
    'ativo',
    'funcionario',
    true,
    (SELECT id FROM funcoes LIMIT 1) -- Usar função existente
  )
  RETURNING id INTO v_test_func_id;
  
  -- Verificar se login foi criado
  SELECT EXISTS (
    SELECT 1 FROM login_funcionarios WHERE funcionario_id = v_test_func_id
  ) INTO v_login_criado;
  
  IF v_login_criado THEN
    RAISE NOTICE '✅ TRIGGER FUNCIONOU! Login criado automaticamente para funcionário %', v_test_func_id;
    
    -- Mostrar o login criado
    RAISE NOTICE 'Usuario criado: %', (SELECT usuario FROM login_funcionarios WHERE funcionario_id = v_test_func_id);
  ELSE
    RAISE NOTICE '❌ TRIGGER NÃO FUNCIONOU! Login não foi criado para funcionário %', v_test_func_id;
  END IF;
  
  -- Limpar teste
  DELETE FROM funcionarios WHERE id = v_test_func_id;
  
END $$;

SELECT '✅ Diagnóstico completo!' as resultado;
