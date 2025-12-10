-- 🔍 DIAGNÓSTICO COMPLETO - PERMISSÕES vs CÓDIGO

-- ====================================
-- 1. PERMISSÕES QUE JENNIFER TEM NO BANCO
-- ====================================
SELECT 
  '📋 PERMISSÕES DE JENNIFER NO BANCO' as info,
  CONCAT(p.recurso, ':', p.acao) as permissao_banco
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
ORDER BY p.recurso, p.acao;

-- ====================================
-- 2. TODAS AS PERMISSÕES DE ADMINISTRAÇÃO NO BANCO
-- ====================================
SELECT 
  '🔐 PERMISSÕES ADMINISTRATIVAS NO BANCO' as info,
  id,
  recurso,
  acao,
  CONCAT(recurso, ':', acao) as permissao_completa,
  descricao
FROM permissoes
WHERE recurso LIKE '%admin%' OR recurso = 'administracao'
ORDER BY recurso, acao;

-- ====================================
-- 3. TODAS AS PERMISSÕES DISPONÍVEIS (AGRUPADAS)
-- ====================================
SELECT 
  '📚 TODOS OS RECURSOS' as info,
  recurso,
  COUNT(*) as total_acoes,
  STRING_AGG(acao, ', ' ORDER BY acao) as acoes_disponiveis
FROM permissoes
GROUP BY recurso
ORDER BY recurso;

-- ====================================
-- 4. VERIFICAR SE JENNIFER TEM PERMISSÕES DE ADMIN
-- ====================================
SELECT 
  '⚠️ JENNIFER TEM PERMISSÕES DE ADMIN?' as info,
  CASE 
    WHEN COUNT(*) > 0 THEN '❌ SIM - PROBLEMA DETECTADO!'
    ELSE '✅ NÃO - Está correto'
  END as resultado,
  COUNT(*) as total_permissoes_admin,
  STRING_AGG(CONCAT(p.recurso, ':', p.acao), ', ') as permissoes_admin
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
  AND (p.recurso LIKE '%admin%' OR p.recurso = 'administracao')
GROUP BY f.nome;

-- ====================================
-- 5. COMPARAR PERMISSÕES: JENNIFER vs CRISTIANO
-- ====================================
-- Cristiano (Admin)
SELECT 
  '👤 CRISTIANO (ADMIN)' as usuario,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(DISTINCT p.id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Cristiano Ramos Mendes'
GROUP BY f.id, f.tipo_admin, func.nome

UNION ALL

-- Jennifer (Vendedor)
SELECT 
  '👤 JENNIFER (VENDEDOR)' as usuario,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(DISTINCT p.id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
GROUP BY f.id, f.tipo_admin, func.nome;

-- ====================================
-- 6. VERIFICAR CÓDIGO vs BANCO
-- ====================================
-- Permissões que o código verifica para Admin
SELECT 
  '🔍 VERIFICAÇÃO: CÓDIGO vs BANCO' as info,
  permissao_codigo,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM permissoes 
      WHERE CONCAT(recurso, ':', acao) = permissao_codigo
    ) THEN '✅ EXISTE NO BANCO'
    ELSE '❌ NÃO EXISTE - PRECISA AJUSTAR'
  END as status
FROM (
  VALUES 
    ('administracao.usuarios:create'),
    ('administracao.usuarios:read'),
    ('administracao.usuarios:update'),
    ('administracao.usuarios:delete'),
    ('administracao.funcoes:create'),
    ('administracao.funcoes:read'),
    ('administracao.funcoes:update'),
    ('administracao.funcoes:delete'),
    ('administracao.sistema:read'),
    ('administracao.sistema:update'),
    ('administracao.backup:create'),
    ('administracao.backup:read'),
    ('administracao.logs:read'),
    ('admin.dashboard:read')
) AS t(permissao_codigo);
