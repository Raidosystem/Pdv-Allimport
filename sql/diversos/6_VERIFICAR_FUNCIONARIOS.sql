-- ============================================
-- 6️⃣ VERIFICAR DADOS DO USUÁRIO EM funcionarios (⚠️ CRÍTICO)
-- ============================================

SELECT 
  'funcionarios' as tabela,
  id,
  empresa_id,
  user_id,
  nome,
  email,
  status,
  tipo_admin,
  funcao_id
FROM funcionarios
WHERE email = 'silviobritoempreendedor@gmail.com'
   OR user_id IN (SELECT id FROM auth.users WHERE email = 'silviobritoempreendedor@gmail.com');
