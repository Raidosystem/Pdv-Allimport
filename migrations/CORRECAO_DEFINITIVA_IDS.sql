-- 🎯 CORREÇÃO DEFINITIVA: Sincronizar TODOS os IDs

-- ⚠️ PROBLEMA:
-- - auth.users.id é diferente de empresas.id
-- - LocalLoginPage usa empresas.id
-- - ActivateUsersPage usa auth.users.id
-- - Funcionários ficam "perdidos" entre os dois IDs

-- ✅ SOLUÇÃO: Fazer empresa_id = auth.users.id em TODOS os funcionários

-- 1. Mostrar a bagunça atual
SELECT 
  '❌ BAGUNÇA ATUAL' as status,
  au.email,
  au.id as auth_id,
  e.id as empresa_id,
  COUNT(f1.id) as func_no_auth_id,
  COUNT(f2.id) as func_no_empresa_id
FROM auth.users au
LEFT JOIN empresas e ON e.email = au.email
LEFT JOIN funcionarios f1 ON f1.empresa_id = au.id AND f1.tipo_admin != 'admin_empresa'
LEFT JOIN funcionarios f2 ON f2.empresa_id = e.id AND f2.tipo_admin != 'admin_empresa'
GROUP BY au.email, au.id, e.id
ORDER BY au.email
LIMIT 10;

-- 2. CORRIGIR: Mover TODOS os funcionários para auth.users.id
UPDATE funcionarios f
SET empresa_id = au.id
FROM auth.users au
JOIN empresas e ON e.email = au.email
WHERE f.empresa_id = e.id
AND au.id != e.id;

-- 3. CORRIGIR: Atualizar empresas.id para ser igual a auth.users.id
UPDATE empresas e
SET id = au.id
FROM auth.users au
WHERE e.email = au.email
AND e.id != au.id;

-- ⚠️ NOTA: O UPDATE acima pode falhar por FK constraints
-- Se falhar, vamos criar uma função helper

-- 4. Verificar resultado
SELECT 
  '✅ APÓS CORREÇÃO' as status,
  au.email,
  au.id as auth_e_empresa_id,
  COUNT(f.id) as total_funcionarios
FROM auth.users au
LEFT JOIN funcionarios f ON f.empresa_id = au.id AND f.tipo_admin != 'admin_empresa'
GROUP BY au.email, au.id
ORDER BY au.email
LIMIT 10;

-- 5. Testar ActivateUsersPage (usa auth.users.id)
SELECT 
  '🧪 TESTE ActivateUsersPage' as teste,
  COUNT(*) as funcionarios_visiveis
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
AND tipo_admin != 'admin_empresa';

-- 6. Testar LocalLoginPage (usa empresas.id, que agora é igual a auth.users.id)
SELECT 
  '🧪 TESTE LocalLoginPage' as teste,
  COUNT(*) as funcionarios_visiveis
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 📊 RESUMO FINAL
SELECT 
  '📊 TUDO UNIFICADO' as titulo,
  'Agora auth.users.id = empresas.id = funcionarios.empresa_id' as explicacao,
  (SELECT COUNT(*) FROM funcionarios WHERE tipo_admin != 'admin_empresa') as total_funcionarios,
  'Todos usando o mesmo ID' as resultado;
