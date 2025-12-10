-- 🔍 ANÁLISE COMPLETA: Separar Empresas vs Funcionários

-- ====================================
-- 1. VER TODAS AS EMPRESAS (admin_empresa)
-- ====================================
SELECT 
  '👔 EMPRESAS (Donos do Sistema)' as tipo,
  f.id as funcionario_id,
  f.nome as nome_admin,
  f.email as email_admin,
  f.tipo_admin,
  f.status,
  e.id as empresa_id,
  e.cnpj,
  e.nome as nome_empresa,
  e.email as email_empresa
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.tipo_admin = 'admin_empresa'
ORDER BY e.nome, f.nome;

-- ====================================
-- 2. VER TODOS OS FUNCIONÁRIOS (não são donos)
-- ====================================
SELECT 
  '👥 FUNCIONÁRIOS' as tipo,
  f.id,
  f.nome,
  f.email,
  f.status,
  f.usuario_ativo,
  e.nome as empresa,
  e.cnpj,
  func.nome as funcao
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.tipo_admin != 'admin_empresa'
ORDER BY e.nome, f.nome;

-- ====================================
-- 3. RESUMO GERAL
-- ====================================
SELECT 
  '📊 RESUMO GERAL' as titulo,
  COUNT(DISTINCT CASE WHEN f.tipo_admin = 'admin_empresa' THEN e.id END) as total_empresas,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' THEN 1 END) as total_funcionarios,
  COUNT(*) as total_cadastros
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id;

-- ====================================
-- 4. FUNCIONÁRIOS POR EMPRESA
-- ====================================
SELECT 
  '👔 Empresa → 👥 Funcionários' as relacao,
  e.nome as empresa,
  e.cnpj,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' THEN 1 END) as funcionarios_cadastrados,
  COUNT(*) as total_cadastros
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.cnpj
ORDER BY e.nome;

-- ====================================
-- 5. IDENTIFICAR PROBLEMAS
-- ====================================
SELECT 
  '⚠️ POSSÍVEIS PROBLEMAS' as tipo,
  'Empresas sem admin' as problema,
  COUNT(*) as quantidade
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f 
  WHERE f.empresa_id = e.id 
  AND f.tipo_admin = 'admin_empresa'
)
UNION ALL
SELECT 
  '⚠️ POSSÍVEIS PROBLEMAS',
  'Funcionários sem empresa',
  COUNT(*)
FROM funcionarios f
WHERE NOT EXISTS (
  SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
);
