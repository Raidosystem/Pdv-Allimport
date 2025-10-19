-- 🔍 DIAGNOSTICAR PROBLEMA - FUNCIONÁRIO NÃO APARECE NO LOGIN LOCAL

-- ====================================
-- 1. VERIFICAR RPC listar_usuarios_ativos
-- ====================================
SELECT 
  '🔍 RPC FUNCTION' as info,
  proname as function_name,
  pg_get_functiondef(oid) as definition
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';

-- ====================================
-- 2. VER TODOS FUNCIONÁRIOS DA EMPRESA
-- ====================================
SELECT 
  '👥 FUNCIONÁRIOS CADASTRADOS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  status,
  empresa_id
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY created_at DESC;

-- ====================================
-- 3. VERIFICAR LOGIN_FUNCIONARIOS
-- ====================================
SELECT 
  '🔑 LOGINS CRIADOS' as info,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome
FROM login_funcionarios lf
LEFT JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY lf.created_at DESC;

-- ====================================
-- 4. TESTAR RPC MANUALMENTE
-- ====================================
SELECT 
  '🧪 TESTE RPC' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ====================================
-- 5. VERIFICAR PERMISSÕES DA RPC
-- ====================================
SELECT 
  '🔒 PERMISSÕES RPC' as info,
  proname,
  proacl as permissions
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';
