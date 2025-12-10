-- 🔍 VERIFICAR: Qual empresa_id está sendo usado?

-- ✅ 1. Ver auth.users vs empresas
SELECT 
  '📋 AUTH vs EMPRESAS' as status,
  au.id as auth_user_id,
  au.email as auth_email,
  e.id as empresa_id_tabela,
  e.email as empresa_email,
  e.nome as empresa_nome,
  CASE 
    WHEN au.id = e.id THEN '✅ IDs IGUAIS'
    ELSE '❌ IDs DIFERENTES'
  END as match_status
FROM auth.users au
JOIN empresas e ON e.email = au.email
WHERE au.email = 'assistenciaallimport10@gmail.com';

-- ✅ 2. Ver funcionários com CADA empresa_id
SELECT 
  '📋 FUNCIONÁRIOS POR ID' as tipo,
  'auth.users.id (f7fdf4cf...)' as qual_id,
  COUNT(*) as total_funcionarios
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
AND tipo_admin != 'admin_empresa'

UNION ALL

SELECT 
  '📋 FUNCIONÁRIOS POR ID' as tipo,
  'empresas.id (f1726fcf...)' as qual_id,
  COUNT(*) as total_funcionarios
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
AND tipo_admin != 'admin_empresa';

-- ✅ 3. SOLUÇÃO: ATUALIZAR funcionários para usar auth.users.id
-- Corrigir empresa_id de TODOS os funcionários
UPDATE funcionarios f
SET empresa_id = au.id
FROM auth.users au
JOIN empresas e ON e.email = au.email
WHERE f.empresa_id = e.id
AND au.id != e.id;

-- ✅ 4. Verificar correção
SELECT 
  '✅ APÓS CORREÇÃO' as status,
  'auth.users.id' as usando,
  COUNT(*) as total_funcionarios
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
AND tipo_admin != 'admin_empresa';

-- ✅ 5. Testar busca do ActivateUsersPage
-- (simula o que o código faz)
SELECT 
  '🧪 TESTE ActivateUsersPage' as teste,
  f.id,
  f.nome,
  f.empresa_id,
  f.status,
  f.tipo_admin
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
AND f.tipo_admin != 'admin_empresa'
ORDER BY f.nome;

-- 📊 RESUMO
SELECT 
  '📊 RESUMO FINAL' as titulo,
  (
    SELECT COUNT(*) 
    FROM funcionarios 
    WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    AND tipo_admin != 'admin_empresa'
  ) as funcionarios_visiveis_activate_users,
  (
    SELECT COUNT(*) 
    FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00')
  ) as funcionarios_visiveis_login_local;
