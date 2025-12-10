-- 🔍 INVESTIGAR: Por que o empresa_id mudou?

-- ✅ Verificar a Maria Silva
SELECT 
  '1️⃣ MARIA SILVA' as item,
  id,
  empresa_id,
  nome,
  created_at
FROM funcionarios
WHERE nome = 'Maria Silva';

-- ✅ Verificar ambos os IDs
SELECT 
  '2️⃣ EMPRESA ID CORRETO (login)' as item,
  'f1726fcf-d23b-4cca-8079-39314ae56e00'::uuid as id_usado_no_login;

SELECT 
  '3️⃣ EMPRESA ID ERRADO (frontend)' as item,
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid as id_usado_no_frontend;

-- ✅ Verificar funcionários em AMBOS os IDs
SELECT 
  '4️⃣ FUNCIONÁRIOS NO ID CORRETO' as item,
  id,
  nome,
  tipo_admin
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

SELECT 
  '5️⃣ FUNCIONÁRIOS NO ID ERRADO' as item,
  id,
  nome,
  tipo_admin
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- ✅ Verificar auth.users
SELECT 
  '6️⃣ USUÁRIO NO AUTH' as item,
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- ✅ SOLUÇÃO: Atualizar Maria Silva para o ID correto do auth?
-- NÃO EXECUTE AINDA - só para ver qual seria a correção
SELECT 
  '7️⃣ SOLUÇÃO POSSÍVEL' as item,
  'UPDATE funcionarios SET empresa_id = ''f7fdf4cf-7101-45ab-86db-5248a7ac58c1'' WHERE id = ''96c36a45-3cf3-4e76-b291-c3a5475e02aa'';' as comando;
