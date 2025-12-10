-- ============================================
-- 🧪 TESTE AUTOMÁTICO: Todos os funcionários do Cristiano
-- ============================================

-- 1️⃣ LISTAR E TESTAR CADA FUNCIONÁRIO AUTOMATICAMENTE
WITH funcionarios_cristiano AS (
  SELECT 
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
)
SELECT 
  '=== FUNCIONÁRIO: ' || fc.nome || ' ===' as info,
  fc.email,
  fc.tipo_admin,
  check_subscription_status(fc.email) as resultado_assinatura
FROM funcionarios_cristiano fc
ORDER BY fc.nome;

-- 2️⃣ COMPARAR COM O ADMIN
SELECT 
  '=== ADMIN (Cristiano) ===' as info,
  'assistenciaallimport10@gmail.com' as email,
  'admin_empresa' as tipo_admin,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado_assinatura;

-- 3️⃣ RESUMO: TODOS OS USUÁRIOS E SEUS ACESSOS
WITH todos_usuarios AS (
  -- Admin
  SELECT 
    'ADMIN' as tipo,
    'Cristiano' as nome,
    'assistenciaallimport10@gmail.com' as email,
    'admin_empresa' as tipo_admin
  
  UNION ALL
  
  -- Funcionários
  SELECT 
    'FUNCIONÁRIO' as tipo,
    f.nome,
    f.email,
    COALESCE(f.tipo_admin, 'funcionario') as tipo_admin
  FROM funcionarios f
  WHERE f.empresa_id = (
    SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
  )
  AND f.status = 'ativo'
)
SELECT 
  tu.tipo,
  tu.nome,
  tu.email,
  tu.tipo_admin,
  (check_subscription_status(tu.email)->>'access_allowed')::boolean as tem_acesso,
  (check_subscription_status(tu.email)->>'status') as status_assinatura,
  (check_subscription_status(tu.email)->>'days_remaining')::integer as dias_restantes,
  (check_subscription_status(tu.email)->>'is_employee')::boolean as eh_funcionario
FROM todos_usuarios tu
ORDER BY tu.tipo, tu.nome;

-- ============================================
-- 📋 RESULTADO ESPERADO
-- ============================================
-- 
-- Query 1 e 2: Detalhes completos do JSON
-- - Admin: access_allowed = true, sem is_employee
-- - Funcionários: access_allowed = true, is_employee = true
--
-- Query 3: Tabela resumida
-- tipo       | nome        | email                   | tem_acesso | dias_restantes | eh_funcionario
-- -----------|-------------|-------------------------|------------|----------------|---------------
-- ADMIN      | Cristiano   | assistencia...@gmail    | true       | 358            | null/false
-- FUNCIONÁRIO| João        | joao@email.com          | true       | 358            | true
-- FUNCIONÁRIO| Maria       | maria@email.com         | true       | 358            | true
--
-- ✅ TODOS DEVEM TER: tem_acesso = true, dias_restantes = 358
--
-- ============================================
