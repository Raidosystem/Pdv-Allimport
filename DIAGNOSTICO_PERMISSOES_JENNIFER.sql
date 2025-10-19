-- 🔍 DIAGNÓSTICO - POR QUE JENNIFER TEM ADMIN TOTAL?

-- ====================================
-- 1. VERIFICAR DADOS DA JENNIFER
-- ====================================
SELECT 
  '👤 JENNIFER - DADOS BÁSICOS' as info,
  id,
  nome,
  email,
  tipo_admin,
  funcao_id,
  usuario_ativo,
  senha_definida
FROM funcionarios
WHERE nome = 'Jennifer Sousa';

-- ====================================
-- 2. VERIFICAR FUNÇÃO DA JENNIFER
-- ====================================
SELECT 
  '🔑 JENNIFER - FUNÇÃO ATRIBUÍDA' as info,
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.funcao_id,
  func.id as funcao_id_real,
  func.nome as funcao_nome,
  func.descricao as funcao_descricao
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.nome = 'Jennifer Sousa';

-- ====================================
-- 3. VERIFICAR PERMISSÕES DA FUNÇÃO DA JENNIFER
-- ====================================
SELECT 
  '📋 PERMISSÕES DA FUNÇÃO DE JENNIFER' as info,
  func.nome as funcao_nome,
  p.recurso,
  p.acao,
  p.descricao,
  fp.id as funcao_permissao_id
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
ORDER BY p.recurso, p.acao;

-- ====================================
-- 4. VERIFICAR SE JENNIFER ESTÁ EM funcionario_funcoes
-- ====================================
SELECT 
  '🔗 JENNIFER - funcionario_funcoes' as info,
  f.id as funcionario_id,
  f.funcao_id as funcao_id_direto,
  'Tabela funcionario_funcoes pode não existir' as nota
FROM funcionarios f
WHERE f.nome = 'Jennifer Sousa';

-- ====================================
-- 5. VERIFICAR TODAS AS FUNÇÕES DISPONÍVEIS
-- ====================================
SELECT 
  '📚 TODAS AS FUNÇÕES' as info,
  id,
  nome,
  descricao,
  empresa_id
FROM funcoes
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY nome;

-- ====================================
-- 6. CONTAR PERMISSÕES POR FUNÇÃO
-- ====================================
SELECT 
  '📊 PERMISSÕES POR FUNÇÃO' as info,
  func.nome as funcao_nome,
  COUNT(fp.id) as total_permissoes
FROM funcoes func
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE func.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
GROUP BY func.id, func.nome
ORDER BY func.nome;

-- ====================================
-- 7. VERIFICAR SE PROBLEMA É NO tipo_admin
-- ====================================
SELECT 
  '⚠️ ANÁLISE DO PROBLEMA' as info,
  f.nome,
  f.tipo_admin,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '❌ PROBLEMA: Jennifer está como admin_empresa'
    WHEN f.tipo_admin = 'funcionario' THEN '✅ OK: Jennifer é funcionário'
    ELSE '⚠️ ATENÇÃO: tipo_admin desconhecido'
  END as diagnostico,
  CASE
    WHEN f.funcao_id IS NULL THEN '❌ PROBLEMA: Jennifer sem função atribuída'
    ELSE '✅ OK: Jennifer tem função'
  END as tem_funcao
FROM funcionarios f
WHERE f.nome = 'Jennifer Sousa';
