-- =====================================================
-- 🧹 LIMPEZA COMPLETA - DADOS DE AMOSTRA
-- =====================================================
-- Remove TODOS os dados de teste/amostra mantendo apenas dados reais
-- =====================================================

-- 1️⃣ BACKUP PREVENTIVO (opcional - apenas para verificação)
SELECT 
  'BACKUP_ANTES_LIMPEZA' as operacao,
  COUNT(*) as total_empresas
FROM empresas;

SELECT 
  'BACKUP_ANTES_LIMPEZA' as operacao,
  COUNT(*) as total_funcionarios  
FROM funcionarios;

-- 2️⃣ IDENTIFICAR EMPRESAS REAIS (com user_id válido)
SELECT 
  'EMPRESAS_REAIS' as tipo,
  id,
  nome,
  user_id,
  created_at
FROM empresas 
WHERE user_id IS NOT NULL
ORDER BY created_at;

-- 3️⃣ LIMPAR DADOS DE AMOSTRA - ORDEM ESPECÍFICA PARA EVITAR CONFLITOS

-- 3.1 - LIMPAR VENDAS DE TESTE
DELETE FROM vendas 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.2 - LIMPAR ORDENS DE SERVIÇO DE TESTE
DELETE FROM ordens_servico 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.3 - LIMPAR PRODUTOS DE TESTE
DELETE FROM produtos 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.4 - LIMPAR CLIENTES DE TESTE
DELETE FROM clientes 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.5 - LIMPAR FORNECEDORES DE TESTE
DELETE FROM fornecedores 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.6 - LIMPAR FUNCIONÁRIOS DE TESTE
DELETE FROM funcionarios 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
)
OR nome ILIKE '%teste%'
OR nome ILIKE '%demo%'
OR email ILIKE '%teste%'
OR email ILIKE '%demo%'
OR email ILIKE '%example%';

-- 3.7 - LIMPAR CAIXA DE TESTE
DELETE FROM caixa 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
);

-- 3.8 - LIMPAR EMPRESAS DE TESTE/AMOSTRA
DELETE FROM empresas 
WHERE user_id IS NULL 
OR nome ILIKE '%teste%' 
OR nome ILIKE '%amostra%'
OR nome ILIKE '%demo%'
OR nome ILIKE '%example%'
OR nome = 'Minha Empresa'
OR nome = 'Nova Empresa'
OR cnpj = '00000000000000'
OR cnpj ILIKE '%12345%'
OR cnpj ILIKE '%00000%';

-- 4️⃣ LIMPEZA ADICIONAL - DADOS ÓRFÃOS OU INCONSISTENTES

-- 4.1 - Produtos sem empresa válida
DELETE FROM produtos 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.2 - Clientes sem empresa válida  
DELETE FROM clientes 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.3 - Fornecedores sem empresa válida
DELETE FROM fornecedores 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.4 - Funcionários sem empresa válida
DELETE FROM funcionarios 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.5 - Vendas sem empresa válida
DELETE FROM vendas 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.6 - Ordens de serviço sem empresa válida
DELETE FROM ordens_servico 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 4.7 - Caixa sem empresa válida
DELETE FROM caixa 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 5️⃣ LIMPEZA DE DADOS ESPECÍFICOS DE TESTE

-- 5.1 - Produtos com nomes de teste
DELETE FROM produtos 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%amostra%'
OR nome ILIKE '%demo%'
OR nome ILIKE '%example%'
OR nome = 'Produto Exemplo'
OR codigo_barras ILIKE '%12345%'
OR codigo_barras ILIKE '%00000%';

-- 5.2 - Clientes com dados de teste
DELETE FROM clientes 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%amostra%'
OR nome ILIKE '%demo%'
OR nome ILIKE '%example%'
OR nome = 'Cliente Exemplo'
OR email ILIKE '%teste%'
OR email ILIKE '%demo%'
OR telefone ILIKE '%12345%'
OR telefone ILIKE '%00000%'
OR cpf_cnpj ILIKE '%12345%'
OR cpf_cnpj ILIKE '%00000%';

-- 5.3 - Fornecedores com dados de teste
DELETE FROM fornecedores 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%amostra%'
OR nome ILIKE '%demo%'
OR nome ILIKE '%example%'
OR nome = 'Fornecedor Exemplo'
OR email ILIKE '%teste%'
OR email ILIKE '%demo%'
OR telefone ILIKE '%12345%'
OR telefone ILIKE '%00000%'
OR cnpj ILIKE '%12345%'
OR cnpj ILIKE '%00000%';

-- 6️⃣ RESETAR SEQUÊNCIAS (IDs) PARA OTIMIZAR - APENAS TABELAS COM INTEGER ID
-- Nota: empresas usa UUID, não precisa resetar sequência
SELECT setval('funcionarios_id_seq', COALESCE((SELECT MAX(id) FROM funcionarios), 1));
SELECT setval('produtos_id_seq', COALESCE((SELECT MAX(id) FROM produtos), 1));
SELECT setval('clientes_id_seq', COALESCE((SELECT MAX(id) FROM clientes), 1));
SELECT setval('fornecedores_id_seq', COALESCE((SELECT MAX(id) FROM fornecedores), 1));
SELECT setval('vendas_id_seq', COALESCE((SELECT MAX(id) FROM vendas), 1));
SELECT setval('ordens_servico_id_seq', COALESCE((SELECT MAX(id) FROM ordens_servico), 1));

-- 7️⃣ VERIFICAÇÃO PÓS-LIMPEZA
SELECT 
  'POS_LIMPEZA' as operacao,
  'empresas' as tabela,
  COUNT(*) as total_registros
FROM empresas

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'funcionarios' as tabela,
  COUNT(*) as total_registros
FROM funcionarios

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'produtos' as tabela,
  COUNT(*) as total_registros
FROM produtos

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'clientes' as tabela,
  COUNT(*) as total_registros
FROM clientes

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'fornecedores' as tabela,
  COUNT(*) as total_registros
FROM fornecedores

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'vendas' as tabela,
  COUNT(*) as total_registros
FROM vendas

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'ordens_servico' as tabela,
  COUNT(*) as total_registros
FROM ordens_servico

UNION ALL

SELECT 
  'POS_LIMPEZA' as operacao,
  'caixa' as tabela,
  COUNT(*) as total_registros
FROM caixa;

-- 8️⃣ VERIFICAR DADOS REAIS RESTANTES
SELECT 
  'EMPRESAS_FINAIS' as tipo,
  e.id,
  e.nome,
  e.user_id,
  e.created_at,
  COUNT(f.id) as funcionarios,
  COUNT(p.id) as produtos,
  COUNT(c.id) as clientes
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
LEFT JOIN produtos p ON p.empresa_id = e.id  
LEFT JOIN clientes c ON c.empresa_id = e.id
GROUP BY e.id, e.nome, e.user_id, e.created_at
ORDER BY e.created_at;

-- 9️⃣ VERIFICAR INTEGRIDADE REFERENCIAL
SELECT 
  'INTEGRIDADE_CHECK' as tipo,
  'produtos_sem_empresa' as problema,
  COUNT(*) as registros_problema
FROM produtos 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  'INTEGRIDADE_CHECK' as tipo,
  'clientes_sem_empresa' as problema,
  COUNT(*) as registros_problema
FROM clientes 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  'INTEGRIDADE_CHECK' as tipo,
  'funcionarios_sem_empresa' as problema,
  COUNT(*) as registros_problema
FROM funcionarios 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Apenas empresas com user_id válido
-- ✅ Apenas dados associados a empresas reais
-- ✅ Zero registros órfãos ou de teste
-- ✅ Sequências otimizadas
-- ✅ Integridade referencial 100%
-- =====================================================

-- 🚨 ATENÇÃO: Este script REMOVE PERMANENTEMENTE dados de teste
-- Execute apenas se tiver certeza que quer limpar tudo!