-- 🔍 ENCONTRAR FUNCIONÁRIO CRIADO RECENTEMENTE

-- ====================================
-- 1. VER ÚLTIMOS 5 FUNCIONÁRIOS CRIADOS (TODAS EMPRESAS)
-- ====================================
SELECT 
  '🆕 ÚLTIMOS CRIADOS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  status,
  empresa_id,
  created_at,
  funcao_id
FROM funcionarios
ORDER BY created_at DESC
LIMIT 5;

-- ====================================
-- 2. FUNCIONÁRIOS SEM usuario_ativo ou senha_definida
-- ====================================
SELECT 
  '⚠️ FUNCIONÁRIOS INATIVOS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  empresa_id,
  funcao_id,
  created_at
FROM funcionarios
WHERE (usuario_ativo IS NULL OR usuario_ativo = false)
   OR (senha_definida IS NULL OR senha_definida = false)
ORDER BY created_at DESC;

-- ====================================
-- 3. ATIVAR TODOS FUNCIONÁRIOS PENDENTES
-- ====================================
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true,
  status = COALESCE(status, 'ativo'),
  primeiro_acesso = COALESCE(primeiro_acesso, true)
WHERE (usuario_ativo IS NULL OR usuario_ativo = false)
   OR (senha_definida IS NULL OR senha_definida = false)
RETURNING 
  id,
  nome,
  email,
  empresa_id,
  'ATIVADO' as status_update;

-- ====================================
-- 4. CRIAR LOGINS FALTANTES
-- ====================================
-- Para funcionários que não têm login, criar com senha padrão "123456"
INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
SELECT 
  f.id,
  f.nome,
  crypt('123456', gen_salt('bf')),
  true
FROM funcionarios f
WHERE NOT EXISTS (
  SELECT 1 FROM login_funcionarios lf 
  WHERE lf.funcionario_id = f.id
)
AND f.senha_definida = true
RETURNING funcionario_id, usuario, 'LOGIN CRIADO (senha: 123456)' as info;

-- ====================================
-- 5. TESTAR RPC NOVAMENTE
-- ====================================
SELECT 
  '🧪 RPC - EMPRESA PRINCIPAL' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ====================================
-- 6. VER TODOS ATIVOS AGORA
-- ====================================
SELECT 
  '✅ TODOS ATIVOS AGORA' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  funcao_id
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND usuario_ativo = true
  AND senha_definida = true
ORDER BY created_at DESC;
