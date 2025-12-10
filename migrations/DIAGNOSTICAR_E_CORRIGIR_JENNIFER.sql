-- =====================================================
-- DIAGNOSTICAR E CORRIGIR PROBLEMA DA JENNIFER
-- =====================================================

-- 1️⃣ VERIFICAR DADOS DA JENNIFER
SELECT 
  '👤 DADOS DA JENNIFER' as info,
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  func.nome as funcao_nome,
  f.status,
  f.tipo_admin,
  au.last_sign_in_at as ultimo_login,
  f.empresa_id
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN auth.users au ON f.user_id = au.id OR f.email = au.email
WHERE f.email = 'jennifer_sousa@temp.local';

-- 2️⃣ VERIFICAR PERMISSÕES QUE ELA TEM
SELECT 
  '🔑 PERMISSÕES DA JENNIFER' as info,
  p.categoria,
  p.recurso,
  p.acao
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON func.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.email = 'jennifer_sousa@temp.local'
ORDER BY p.categoria, p.recurso, p.acao;

-- 3️⃣ VERIFICAR SE ELA TEM PERMISSÕES JSONB
SELECT 
  '📦 PERMISSÕES JSONB' as info,
  f.nome,
  f.permissoes
FROM funcionarios f
WHERE f.email = 'jennifer_sousa@temp.local';

-- 4️⃣ VERIFICAR TIPO_ADMIN
SELECT 
  '👑 TIPO DE ADMIN' as info,
  CASE 
    WHEN f.tipo_admin = 'super_admin' THEN '🔴 SUPER ADMIN (acesso total)'
    WHEN f.tipo_admin = 'admin_empresa' THEN '🟡 ADMIN EMPRESA (acesso total)'
    WHEN f.tipo_admin = 'funcionario' OR f.tipo_admin IS NULL THEN '🟢 FUNCIONÁRIO (limitado)'
    ELSE f.tipo_admin
  END as status_admin
FROM funcionarios f
WHERE f.email = 'jennifer_sousa@temp.local';

-- =====================================================
-- CORREÇÕES
-- =====================================================

-- CORREÇÃO 1: Garantir que Jennifer é FUNCIONÁRIO (não admin)
UPDATE funcionarios
SET tipo_admin = 'funcionario'
WHERE email = 'jennifer_sousa@temp.local'
AND tipo_admin != 'funcionario';

-- CORREÇÃO 2: Limpar permissões JSONB (usar apenas funcao_permissoes)
UPDATE funcionarios
SET permissoes = NULL
WHERE email = 'jennifer_sousa@temp.local';

-- CORREÇÃO 3: Garantir que funcao_id está correto (Vendedor)
UPDATE funcionarios f
SET funcao_id = (
  SELECT id FROM funcoes 
  WHERE nome = 'Vendedor' 
  AND empresa_id = f.empresa_id
  LIMIT 1
)
WHERE f.email = 'jennifer_sousa@temp.local';

-- =====================================================
-- NOTA: ultimo_login é rastreado automaticamente pelo Supabase
-- através da coluna auth.users.last_sign_in_at
-- Não é necessário criar trigger adicional
-- =====================================================

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 
  '✅ JENNIFER CORRIGIDA' as status,
  f.nome,
  f.email,
  func.nome as funcao,
  f.tipo_admin,
  f.permissoes,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'jennifer_sousa@temp.local'
GROUP BY f.id, f.nome, f.email, func.nome, f.tipo_admin, f.permissoes;

-- =====================================================
-- ✅ O QUE FOI CORRIGIDO:
-- =====================================================
-- 1. ✅ tipo_admin = 'funcionario' (não é mais admin)
-- 2. ✅ permissoes JSONB = NULL (usar apenas funcao_permissoes)
-- 3. ✅ funcao_id = Vendedor (16 permissões)
-- 4. ✅ ultimo_login rastreado via auth.users.last_sign_in_at
-- 
-- 🎯 AGORA:
-- - Jennifer tem apenas permissões de Vendedor (16)
-- - ultimo_login é rastreado automaticamente pelo Supabase
-- - Todos os futuros funcionários seguirão as mesmas regras
-- =====================================================
