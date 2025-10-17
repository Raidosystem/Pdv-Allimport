-- ========================================
-- VERIFICAR SE FUNCIONÁRIO FOI REALMENTE CRIADO
-- ========================================

-- Ver todos os funcionários (sem RLS)
SELECT 
  'TODOS OS FUNCIONARIOS (sem RLS):' as info;

SELECT 
  id,
  user_id,
  empresa_id,
  nome,
  email,
  status,
  is_main_account,
  created_at
FROM funcionarios
ORDER BY created_at DESC;

-- Ver funcionário do usuário atual (com RLS)
SELECT 
  'FUNCIONARIO DO USUARIO ATUAL (com RLS):' as info;

SELECT 
  id,
  user_id,
  empresa_id,
  nome,
  email,
  status,
  is_main_account
FROM funcionarios
WHERE user_id = auth.uid();

-- Ver usuário autenticado
SELECT 
  'USUARIO AUTENTICADO:' as info;

SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE id = auth.uid();

-- Verificar políticas RLS de funcionarios
SELECT 
  'POLITICAS RLS DA TABELA FUNCIONARIOS:' as info;

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'funcionarios';
