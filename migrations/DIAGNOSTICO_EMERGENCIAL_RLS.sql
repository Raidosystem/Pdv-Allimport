-- ================================================
-- DIAGNÓSTICO EMERGENCIAL - PROBLEMAS DE RLS
-- ================================================

-- 1. Verificar se o usuário existe na tabela auth.users
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at
FROM auth.users
WHERE id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 2. Verificar se existe empresa associada
SELECT 
  id,
  user_id,
  nome,
  created_at
FROM empresas
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 3. Se não existir empresa, CRIAR AGORA
INSERT INTO empresas (user_id, nome, cnpj, email, telefone)
VALUES (
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'Assistência All-Import',
  '00.000.000/0001-00',
  'assistenciaallimport10@gmail.com',
  '(00) 00000-0000'
)
ON CONFLICT (user_id) DO NOTHING;

-- 4. Verificar políticas RLS da tabela clientes
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'clientes';

-- 5. DESABILITAR RLS TEMPORARIAMENTE para clientes (EMERGÊNCIA)
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;

-- 6. Verificar políticas de empresas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'empresas';

-- 7. Criar política PERMISSIVA para empresas (se não existir)
DROP POLICY IF EXISTS "allow_all_for_authenticated" ON empresas;
CREATE POLICY "allow_all_for_authenticated" 
ON empresas FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 8. Verificar tabela funcionarios
SELECT 
  id,
  empresa_id,
  user_id,
  nome,
  email,
  status,
  tipo_admin
FROM funcionarios
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 9. Se não existir funcionário, CRIAR
DO $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Buscar empresa_id
  SELECT id INTO v_empresa_id 
  FROM empresas 
  WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  LIMIT 1;

  IF v_empresa_id IS NOT NULL THEN
    INSERT INTO funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      status,
      tipo_admin
    )
    VALUES (
      v_empresa_id,
      'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
      'Administrador',
      'assistenciaallimport10@gmail.com',
      'ativo',
      'admin_empresa'
    )
    ON CONFLICT (empresa_id, email) DO NOTHING;
    
    RAISE NOTICE '✅ Funcionário criado/atualizado!';
  ELSE
    RAISE NOTICE '❌ Empresa não encontrada!';
  END IF;
END $$;

-- 10. Verificar subscriptions
SELECT 
  id,
  user_id,
  status,
  expires_at,
  plan_name
FROM subscriptions
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 11. RESULTADO FINAL
SELECT 
  '===== RESUMO DIAGNÓSTICO =====' AS info;

SELECT 
  'Empresa: ' || COALESCE(nome, 'NÃO EXISTE') AS status
FROM empresas
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

SELECT 
  'Funcionário: ' || COALESCE(nome, 'NÃO EXISTE') AS status
FROM funcionarios
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

SELECT 
  'Subscription: ' || COALESCE(status, 'NÃO EXISTE') AS status
FROM subscriptions
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

RAISE NOTICE '🔍 Execute este script no SQL Editor do Supabase!';
RAISE NOTICE '📋 Verifique os resultados acima.';
