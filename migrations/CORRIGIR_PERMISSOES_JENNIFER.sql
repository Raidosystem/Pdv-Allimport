-- ============================================
-- VERIFICAR E CORRIGIR PERMISSÕES DA JENNIFER
-- ============================================

-- ============================================
-- 1️⃣ VER PERMISSÕES ATUAIS DA JENNIFER
-- ============================================
SELECT 
  f.nome as funcionario,
  fn.nome as funcao,
  p.modulo,
  p.recurso,
  fp.pode_visualizar,
  fp.pode_criar,
  fp.pode_editar,
  fp.pode_excluir,
  fp.ativo
FROM funcionarios f
JOIN funcoes fn ON f.funcao_id = fn.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = fn.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(f.nome) LIKE '%jennifer%'
ORDER BY p.modulo, p.recurso;

-- ============================================
-- 2️⃣ DESATIVAR PERMISSÕES PERIGOSAS DA JENNIFER
-- ============================================

-- Remover permissão de EXCLUIR produtos
UPDATE funcao_permissoes
SET 
  pode_excluir = false,
  ativo = true,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'produtos'
);

-- Remover permissão de EXCLUIR clientes
UPDATE funcao_permissoes
SET 
  pode_excluir = false,
  ativo = true,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'clientes'
);

-- Remover acesso a CONFIGURAÇÕES (módulo completo)
UPDATE funcao_permissoes
SET 
  ativo = false,
  pode_visualizar = false,
  pode_criar = false,
  pode_editar = false,
  pode_excluir = false,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE modulo = 'configuracoes'
);

-- ============================================
-- 3️⃣ ATIVAR PERMISSÕES QUE DEVEM ESTAR ATIVAS
-- ============================================

-- Ativar permissões básicas de vendas (visualizar, criar, editar - SEM excluir)
UPDATE funcao_permissoes
SET 
  ativo = true,
  pode_visualizar = true,
  pode_criar = true,
  pode_editar = true,
  pode_excluir = false,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE modulo = 'vendas'
);

-- Ativar permissões de produtos (visualizar, criar, editar - SEM excluir)
UPDATE funcao_permissoes
SET 
  ativo = true,
  pode_visualizar = true,
  pode_criar = true,
  pode_editar = true,
  pode_excluir = false,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'produtos'
);

-- Ativar permissões de clientes (visualizar, criar, editar - SEM excluir)
UPDATE funcao_permissoes
SET 
  ativo = true,
  pode_visualizar = true,
  pode_criar = true,
  pode_editar = true,
  pode_excluir = false,
  updated_at = NOW()
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'clientes'
);

-- ============================================
-- 4️⃣ VERIFICAR PERMISSÕES APÓS CORREÇÃO
-- ============================================
SELECT 
  f.nome as funcionario,
  fn.nome as funcao,
  p.modulo,
  p.recurso,
  fp.pode_visualizar as visualizar,
  fp.pode_criar as criar,
  fp.pode_editar as editar,
  fp.pode_excluir as excluir,
  fp.ativo,
  CASE 
    WHEN p.modulo = 'configuracoes' THEN '❌ Deve estar DESATIVADO'
    WHEN p.recurso IN ('produtos', 'clientes') AND fp.pode_excluir = true THEN '❌ NÃO pode excluir'
    WHEN fp.ativo = false AND p.modulo != 'configuracoes' THEN '⚠️ Deveria estar ATIVO'
    ELSE '✅ OK'
  END as status
FROM funcionarios f
JOIN funcoes fn ON f.funcao_id = fn.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = fn.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(f.nome) LIKE '%jennifer%'
ORDER BY p.modulo, p.recurso;

-- ============================================
-- ✅ RESUMO ESPERADO PARA JENNIFER
-- ============================================
-- ✅ Vendas: Visualizar, Criar, Editar (SEM excluir)
-- ✅ Produtos: Visualizar, Criar, Editar (SEM excluir)
-- ✅ Clientes: Visualizar, Criar, Editar (SEM excluir)
-- ✅ Ordens de Serviço: Visualizar, Criar, Editar (SEM excluir)
-- ❌ Configurações: DESATIVADO (não aparece no menu)
-- ❌ Administração: DESATIVADO (não aparece no menu)
-- ❌ Funcionários: DESATIVADO (não pode gerenciar funcionários)
