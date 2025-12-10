-- ============================================
-- 🧪 CRIAR FUNCIONÁRIO TESTE (SE NÃO EXISTIR)
-- ============================================

-- 1️⃣ CRIAR FUNCIONÁRIO TESTE NA TABELA
INSERT INTO funcionarios (
  nome,
  email,
  cpf,
  empresa_id,
  funcao_id,
  tipo_admin,
  status,
  user_id,
  created_at,
  updated_at
)
SELECT 
  'Funcionário Teste',
  'funcionario.teste@pdvallimport.com',
  '00000000000',
  u.id, -- empresa_id = ID do Cristiano
  (SELECT id FROM funcoes WHERE nome = 'Vendedor' LIMIT 1), -- Função padrão
  NULL, -- NÃO é admin
  'ativo',
  NULL, -- Ainda não tem user_id (não fez login)
  NOW(),
  NOW()
FROM auth.users u
WHERE u.email = 'assistenciaallimport10@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM funcionarios WHERE email = 'funcionario.teste@pdvallimport.com'
);

-- 2️⃣ VERIFICAR SE FOI CRIADO
SELECT 
  '=== FUNCIONÁRIO CRIADO ===' as info,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  f.empresa_id
FROM funcionarios f
WHERE f.email = 'funcionario.teste@pdvallimport.com';

-- 3️⃣ TESTAR check_subscription_status COM O FUNCIONÁRIO TESTE
SELECT 
  '=== TESTE: FUNCIONÁRIO TESTE ===' as info,
  check_subscription_status('funcionario.teste@pdvallimport.com') as resultado;

-- Resultado esperado:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "premium",
--   "access_allowed": true,    ← DEVE SER TRUE!
--   "subscription_end_date": "2026-12-01...",
--   "days_remaining": 358,
--   "is_employee": true,
--   "empresa_id": "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"
-- }

-- 4️⃣ COMPARAR COM O ADMIN (DEVEM TER MESMA DATA)
SELECT 
  '=== TESTE: ADMIN (Cristiano) ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado;

-- ============================================
-- 📋 VALIDAÇÃO FINAL
-- ============================================
-- 
-- ✅ SUCESSO SE:
-- - Funcionário tem access_allowed = true
-- - Funcionário tem is_employee = true
-- - Ambos têm mesma subscription_end_date
-- - Ambos têm mesmo days_remaining
--
-- ❌ FALHA SE:
-- - Funcionário tem access_allowed = false
-- - Erro "no_owner_subscription"
-- - Datas diferentes entre admin e funcionário
--
-- ============================================
