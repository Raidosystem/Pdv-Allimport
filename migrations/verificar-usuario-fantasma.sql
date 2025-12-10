-- ============================================
-- VERIFICAR SE EXISTE REGISTRO ÓRFÃO
-- Usuário deletado do auth.users mas ainda na tabela empresas
-- ============================================

-- 1️⃣ Buscar registros com este CPF
SELECT 
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.ativo,
  e.deleted_at,
  e.created_at,
  'Registro na tabela empresas' as status
FROM empresas e
WHERE REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = '28219618809'
ORDER BY e.created_at DESC;

-- 2️⃣ Verificar se user_id existe no auth.users
SELECT 
  e.user_id,
  e.email as email_empresas,
  e.nome,
  CASE 
    WHEN u.id IS NULL THEN '❌ ÓRFÃO (sem usuário no auth.users)'
    ELSE '✅ Com usuário válido'
  END as status_auth,
  u.email as email_auth,
  u.created_at as criado_em,
  u.deleted_at as deletado_em
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = '28219618809'
ORDER BY e.created_at DESC;

-- 3️⃣ Verificar também por email
SELECT 
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.ativo,
  e.deleted_at
FROM empresas e
WHERE LOWER(TRIM(e.email)) = LOWER('cris-ramos30@hotmail.com')
ORDER BY e.created_at DESC;

-- 4️⃣ SOLUÇÃO: Deletar registros órfãos
-- (Descomente APENAS se confirmar que são registros antigos)

-- DELETE FROM empresas 
-- WHERE REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809'
--   AND user_id NOT IN (SELECT id FROM auth.users);

-- 5️⃣ Ou deletar TUDO relacionado a este CPF (CUIDADO!)
-- DELETE FROM empresas 
-- WHERE REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809';
