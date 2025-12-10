-- ============================================
-- 🧪 TESTE COMPLETO: Listar e testar funcionários
-- ============================================

-- 1️⃣ BUSCAR UUID DO CRISTIANO
SELECT 
  '=== UUID DO CRISTIANO ===' as info,
  id as user_id,
  email
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2️⃣ LISTAR TODOS OS FUNCIONÁRIOS (ATIVOS E INATIVOS)
SELECT 
  '=== TODOS OS FUNCIONÁRIOS ===' as info,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id,
  CASE 
    WHEN f.empresa_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')
    THEN '✅ É do Cristiano'
    ELSE '❌ Outra empresa'
  END as verifica_empresa
FROM funcionarios f
ORDER BY f.created_at DESC
LIMIT 20;

-- 3️⃣ LISTAR APENAS FUNCIONÁRIOS ATIVOS DO CRISTIANO
SELECT 
  '=== FUNCIONÁRIOS ATIVOS DO CRISTIANO ===' as info,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id
FROM funcionarios f
WHERE f.empresa_id = (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
AND f.status = 'ativo'
ORDER BY f.created_at DESC;

-- 4️⃣ CONTAR FUNCIONÁRIOS POR STATUS
SELECT 
  '=== CONTAGEM POR STATUS ===' as info,
  f.status,
  COUNT(*) as total
FROM funcionarios f
WHERE f.empresa_id = (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
GROUP BY f.status;

-- 5️⃣ SE ENCONTROU FUNCIONÁRIOS, TESTE COM O PRIMEIRO EMAIL ENCONTRADO
-- (DESCOMENTE E SUBSTITUA O EMAIL APÓS EXECUTAR AS QUERIES ACIMA)

-- SELECT 
--   '=== TESTE: FUNCIONÁRIO ===' as info,
--   check_subscription_status('email_do_funcionario@aqui.com') as resultado;

-- ============================================
-- 📋 INSTRUÇÕES
-- ============================================
-- 
-- 1. Execute as queries acima no Supabase
-- 2. Veja se existem funcionários cadastrados
-- 3. Se SIM: copie o email de um funcionário e teste na query 5️⃣
-- 4. Se NÃO: cadastre um funcionário teste via sistema
--
-- ============================================
