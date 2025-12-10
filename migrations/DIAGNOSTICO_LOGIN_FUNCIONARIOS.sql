-- 🔍 DIAGNÓSTICO: Por que funcionários não aparecem no login?

-- ✅ 1. Verificar TODOS os funcionários
SELECT 
  '📋 TODOS OS FUNCIONÁRIOS' as status,
  f.id,
  f.nome,
  f.empresa_id,
  f.status,
  f.tipo_admin,
  f.usuario_ativo,
  f.senha_definida,
  f.primeiro_acesso,
  e.nome as empresa_nome
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
ORDER BY f.created_at DESC
LIMIT 20;

-- ✅ 2. Verificar login_funcionarios
SELECT 
  '📋 LOGINS CRIADOS' as status,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome,
  f.empresa_id
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
ORDER BY lf.created_at DESC
LIMIT 20;

-- ✅ 3. Testar função listar_usuarios_ativos para TODAS as empresas
SELECT 
  '🧪 TESTE FUNÇÃO' as teste,
  e.id as empresa_id,
  e.nome as empresa_nome,
  (
    SELECT COUNT(*) 
    FROM listar_usuarios_ativos(e.id)
  ) as total_usuarios_ativos
FROM empresas e
ORDER BY e.created_at DESC;

-- ✅ 4. Verificar problema específico: funcionários SEM usuario_ativo
SELECT 
  '⚠️ FUNCIONÁRIOS SEM usuario_ativo=TRUE' as problema,
  f.id,
  f.nome,
  f.empresa_id,
  f.usuario_ativo,
  f.tipo_admin,
  e.nome as empresa_nome
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.usuario_ativo IS NULL OR f.usuario_ativo = FALSE
ORDER BY f.created_at DESC;

-- ✅ 5. Verificar funcionários ATIVOS mas SEM login
SELECT 
  '⚠️ FUNCIONÁRIOS ATIVOS SEM LOGIN' as problema,
  f.id,
  f.nome,
  f.empresa_id,
  f.usuario_ativo,
  f.tipo_admin,
  e.nome as empresa_nome
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.usuario_ativo = TRUE
AND lf.id IS NULL
AND f.tipo_admin != 'admin_empresa'
ORDER BY f.created_at DESC;

-- ✅ 6. Verificar se admins de outras empresas têm empresa_id correto
SELECT 
  '📋 ADMINS DAS EMPRESAS' as status,
  au.id as auth_user_id,
  au.email,
  e.id as empresa_id_tabela,
  e.nome as empresa_nome,
  CASE 
    WHEN au.id = e.id THEN '✅ MATCH'
    ELSE '❌ MISMATCH'
  END as id_match
FROM auth.users au
JOIN empresas e ON e.email = au.email
ORDER BY e.created_at DESC
LIMIT 20;

-- 📊 RESUMO FINAL
SELECT 
  '📊 RESUMO' as titulo,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE) as funcionarios_ativos,
  (SELECT COUNT(*) FROM login_funcionarios) as total_logins,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE AND tipo_admin != 'admin_empresa') as funcionarios_devem_aparecer;
