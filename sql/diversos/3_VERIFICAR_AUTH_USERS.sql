-- ============================================
-- 3️⃣ VERIFICAR DADOS DO USUÁRIO EM auth.users
-- ============================================

SELECT 
  'auth.users' as tabela,
  id,
  email,
  email_confirmed_at,
  raw_user_meta_data->>'full_name' as nome,
  raw_user_meta_data->>'company_name' as empresa,
  raw_user_meta_data->>'role' as role_metadata,
  created_at
FROM auth.users
WHERE email = 'silviobritoempreendedor@gmail.com';
