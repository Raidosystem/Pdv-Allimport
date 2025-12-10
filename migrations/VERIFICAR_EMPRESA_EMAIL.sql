-- 🔍 VERIFICAR tabela empresas

-- ✅ Passo 1: A empresa existe?
SELECT 
  '1️⃣ EMPRESA EXISTE?' as verificacao,
  id,
  email,
  cnpj,
  nome,
  created_at
FROM empresas
WHERE email = 'assistenciaallimport10@gmail.com';

-- ✅ Passo 2: Relacionamento entre auth.users e empresas
SELECT 
  '2️⃣ AUTH USER' as verificacao,
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- ✅ Passo 3: Verificar se existe relação user_id -> empresa_id
SELECT 
  '3️⃣ RELAÇÃO?' as verificacao,
  u.id as user_id,
  u.email,
  e.id as empresa_id,
  e.nome as empresa_nome
FROM auth.users u
LEFT JOIN empresas e ON e.id = u.id OR e.email = u.email
WHERE u.email = 'assistenciaallimport10@gmail.com';
