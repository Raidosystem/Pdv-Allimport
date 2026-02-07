-- ============================================
-- 5️⃣ VERIFICAR DADOS DO USUÁRIO EM empresas (⚠️ CRÍTICO)
-- ============================================

SELECT 
  'empresas' as tabela,
  id,
  user_id,
  nome,
  razao_social,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste
FROM empresas
WHERE email = 'silviobritoempreendedor@gmail.com'
   OR user_id IN (SELECT id FROM auth.users WHERE email = 'silviobritoempreendedor@gmail.com');
