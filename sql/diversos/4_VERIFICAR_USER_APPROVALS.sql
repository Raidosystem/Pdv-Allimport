-- ============================================
-- 4️⃣ VERIFICAR DADOS DO USUÁRIO EM user_approvals
-- ============================================

SELECT 
  'user_approvals' as tabela,
  id,
  user_id,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at,
  approved_at
FROM user_approvals
WHERE email = 'silviobritoempreendedor@gmail.com';
