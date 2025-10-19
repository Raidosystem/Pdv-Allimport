-- 🔍 VERIFICAR TODAS AS EMPRESAS NO BANCO

-- ====================================
-- 1. LISTAR TODAS AS EMPRESAS
-- ====================================
SELECT 
  '📋 TODAS AS EMPRESAS' as titulo,
  id,
  nome,
  email,
  cnpj,
  tipo_conta,
  data_cadastro
FROM empresas
ORDER BY nome;

-- ====================================
-- 2. VERIFICAR DUPLICATAS POR EMAIL
-- ====================================
SELECT 
  '⚠️ EMAILS DUPLICADOS' as problema,
  email,
  COUNT(*) as total_duplicatas,
  STRING_AGG(nome, ', ') as empresas
FROM empresas
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ====================================
-- 3. VERIFICAR DUPLICATAS POR CNPJ
-- ====================================
SELECT 
  '⚠️ CNPJ DUPLICADOS' as problema,
  cnpj,
  COUNT(*) as total_duplicatas,
  STRING_AGG(nome, ', ') as empresas
FROM empresas
WHERE cnpj IS NOT NULL
GROUP BY cnpj
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ====================================
-- 4. EMPRESAS SEM ADMIN (precisam correção)
-- ====================================
SELECT 
  '⚠️ EMPRESAS SEM ADMIN' as problema,
  e.id,
  e.nome,
  e.email,
  e.tipo_conta
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f
  WHERE f.empresa_id = e.id
  AND f.tipo_admin = 'admin_empresa'
)
ORDER BY e.nome;

-- ====================================
-- 5. RESUMO GERAL
-- ====================================
SELECT 
  '📊 RESUMO' as titulo,
  COUNT(*) as total_empresas,
  COUNT(CASE WHEN tipo_conta = 'assinatura_ativa' THEN 1 END) as clientes_pagos,
  COUNT(CASE WHEN tipo_conta = 'teste_ativo' THEN 1 END) as em_teste,
  COUNT(CASE WHEN tipo_conta = 'funcionarios' THEN 1 END) as contas_funcionarios
FROM empresas;

-- ====================================
-- 6. FUNCIONÁRIOS POR EMPRESA
-- ====================================
SELECT 
  '👥 FUNCIONÁRIOS POR EMPRESA' as titulo,
  e.nome as empresa,
  e.tipo_conta,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' THEN 1 END) as funcionarios_comuns
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.tipo_conta
ORDER BY e.tipo_conta, e.nome;
