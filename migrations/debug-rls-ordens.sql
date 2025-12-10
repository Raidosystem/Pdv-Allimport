-- 🔒 Debug: Verificar políticas RLS da tabela ordens_servico
-- Execute no SQL Editor do Supabase

-- 1. Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity,
  enablerls
FROM pg_tables 
WHERE tablename = 'ordens_servico';

-- 2. Ver todas as políticas da tabela
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
WHERE tablename = 'ordens_servico';

-- 3. Testar acesso direto (sem RLS temporariamente)
-- CUIDADO: Só para debug, não deixe assim em produção
-- ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

-- 4. Verificar se consegue ver todas as ordens sem RLS
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  usuario_id,
  created_at
FROM ordens_servico 
ORDER BY created_at DESC
LIMIT 10;

-- 5. Reabilitar RLS após teste
-- ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. Verificar qual usuário você está logado
SELECT 
  auth.uid() as current_user_id,
  auth.email() as current_email;