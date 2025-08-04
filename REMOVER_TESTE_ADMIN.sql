-- Script para remover teste@teste.com como admin
-- Execute este script no Supabase SQL Editor

-- 1. Remover usuário teste@teste.com da tabela auth.users se existir
DELETE FROM auth.users 
WHERE email = 'teste@teste.com';

-- 2. Remover registros de aprovação para teste@teste.com
DELETE FROM user_approvals 
WHERE email = 'teste@teste.com';

-- 3. Atualizar política RLS para admins (removendo teste@teste.com)
DROP POLICY IF EXISTS "Admins podem gerenciar aprovações" ON user_approvals;

CREATE POLICY "Admins podem gerenciar aprovações" ON user_approvals
FOR ALL 
TO authenticated
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  auth.jwt() ->> 'role' = 'admin'
)
WITH CHECK (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  auth.jwt() ->> 'role' = 'admin'
);

-- 4. Atualizar função is_admin para remover teste@teste.com
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
    OR 
    auth.jwt() ->> 'role' = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Verificar se as políticas foram atualizadas corretamente
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
WHERE tablename = 'user_approvals'
ORDER BY policyname;

-- 6. Verificar usuários admin restantes
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at
FROM auth.users 
WHERE email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com');

-- 7. Verificar se teste@teste.com foi removido
SELECT COUNT(*) as teste_user_count
FROM auth.users 
WHERE email = 'teste@teste.com';
