-- =====================================================
-- 🧹 LIMPEZA COMPLETA CORRIGIDA - DADOS DE AMOSTRA
-- =====================================================
-- Versão corrigida que trata adequadamente UUIDs e sequências
-- =====================================================

-- 1️⃣ VERIFICAR TIPOS DE ID DAS TABELAS
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND column_name = 'id'
  AND table_name IN ('empresas', 'funcionarios', 'produtos', 'clientes', 'fornecedores', 'vendas', 'ordens_servico')
ORDER BY table_name;

-- 2️⃣ BACKUP PREVENTIVO - CONTADORES ANTES DA LIMPEZA
SELECT 
  'ANTES_LIMPEZA' as momento,
  'empresas' as tabela,
  COUNT(*) as total
FROM empresas

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'funcionarios' as tabela,
  COUNT(*) as total
FROM funcionarios

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'produtos' as tabela,
  COUNT(*) as total
FROM produtos

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'clientes' as tabela,
  COUNT(*) as total
FROM clientes

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'fornecedores' as tabela,
  COUNT(*) as total
FROM fornecedores

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'vendas' as tabela,
  COUNT(*) as total
FROM vendas

UNION ALL

SELECT 
  'ANTES_LIMPEZA' as momento,
  'ordens_servico' as tabela,
  COUNT(*) as total
FROM ordens_servico;

-- 3️⃣ IDENTIFICAR EMPRESAS REAIS (com user_id válido do Supabase Auth)
SELECT 
  'EMPRESAS_REAIS_IDENTIFICADAS' as status,
  e.id,
  e.nome,
  e.cnpj,
  e.user_id,
  e.created_at,
  CASE 
    WHEN au.id IS NOT NULL THEN '✅ User existe no Auth'
    ELSE '❌ User não encontrado no Auth'
  END as auth_status
FROM empresas e
LEFT JOIN auth.users au ON au.id = e.user_id
WHERE e.user_id IS NOT NULL
ORDER BY e.created_at;

-- 4️⃣ LIMPEZA ORDENADA - CASCATA PARA EVITAR CONFLITOS DE FOREIGN KEY

-- 4.1 - Limpar vendas primeiro (podem ter foreign keys)
DELETE FROM vendas 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.2 - Limpar ordens de serviço
DELETE FROM ordens_servico 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.3 - Limpar caixa
DELETE FROM caixa 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.4 - Limpar produtos
DELETE FROM produtos 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.5 - Limpar clientes
DELETE FROM clientes 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.6 - Limpar fornecedores
DELETE FROM fornecedores 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
);

-- 4.7 - Limpar funcionários
DELETE FROM funcionarios 
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id IS NULL 
  OR nome ILIKE '%teste%' 
  OR nome ILIKE '%amostra%'
  OR nome ILIKE '%demo%'
  OR nome ILIKE '%example%'
  OR nome = 'Minha Empresa'
  OR nome = 'Nova Empresa'
)
OR nome ILIKE '%teste%'
OR nome ILIKE '%demo%'
OR email ILIKE '%teste%'
OR email ILIKE '%demo%'
OR email ILIKE '%example%';

-- 4.8 - Por último, limpar empresas de teste
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

-- 5️⃣ LIMPEZA DE DADOS ÓRFÃOS (registros sem empresa válida)
DELETE FROM produtos WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM clientes WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM fornecedores WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM funcionarios WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM vendas WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM ordens_servico WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM caixa WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 6️⃣ LIMPEZA ESPECÍFICA DE DADOS COM PADRÕES DE TESTE

-- 6.1 - Produtos com códigos de barras ou nomes suspeitos
DELETE FROM produtos 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%amostra%'
OR nome ILIKE '%demo%'
OR nome ILIKE '%example%'
OR nome = 'Produto Exemplo'
OR codigo_barras IN ('7891234567890', '1234567890123', '0000000000000')
OR codigo_barras ILIKE '%12345%'
OR codigo_barras ILIKE '%00000%';

-- 6.2 - Clientes com dados obviamente falsos
DELETE FROM clientes 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%cliente%'
OR nome ILIKE '%example%'
OR email ILIKE '%@example.com'
OR email ILIKE '%@teste.com'
OR telefone ILIKE '%12345%'
OR telefone ILIKE '%00000%'
OR cpf_cnpj IN ('000.000.000-00', '111.111.111-11', '123.456.789-00')
OR cpf_cnpj ILIKE '%12345%'
OR cpf_cnpj ILIKE '%00000%';

-- 6.3 - Fornecedores com dados de teste
DELETE FROM fornecedores 
WHERE nome ILIKE '%teste%'
OR nome ILIKE '%fornecedor%'
OR nome ILIKE '%example%'
OR email ILIKE '%@example.com'
OR email ILIKE '%@teste.com'
OR cnpj IN ('00.000.000/0000-00', '11.111.111/1111-11', '12.345.678/0001-90')
OR cnpj ILIKE '%12345%'
OR cnpj ILIKE '%00000%';

-- 7️⃣ RESETAR SEQUÊNCIAS - APENAS PARA TABELAS COM INTEGER ID
-- Verifica se a tabela tem sequência antes de tentar resetar

DO $$ 
BEGIN
  -- Resetar sequências apenas se existirem
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'funcionarios_id_seq') THEN
    PERFORM setval('funcionarios_id_seq', COALESCE((SELECT MAX(id) FROM funcionarios), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'produtos_id_seq') THEN
    PERFORM setval('produtos_id_seq', COALESCE((SELECT MAX(id) FROM produtos), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'clientes_id_seq') THEN
    PERFORM setval('clientes_id_seq', COALESCE((SELECT MAX(id) FROM clientes), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'fornecedores_id_seq') THEN
    PERFORM setval('fornecedores_id_seq', COALESCE((SELECT MAX(id) FROM fornecedores), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'vendas_id_seq') THEN
    PERFORM setval('vendas_id_seq', COALESCE((SELECT MAX(id) FROM vendas), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'ordens_servico_id_seq') THEN
    PERFORM setval('ordens_servico_id_seq', COALESCE((SELECT MAX(id) FROM ordens_servico), 1));
  END IF;
END $$;

-- 8️⃣ VERIFICAÇÃO PÓS-LIMPEZA
SELECT 
  'APOS_LIMPEZA' as momento,
  'empresas' as tabela,
  COUNT(*) as total_restante
FROM empresas

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'funcionarios' as tabela,
  COUNT(*) as total_restante
FROM funcionarios

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'produtos' as tabela,
  COUNT(*) as total_restante
FROM produtos

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'clientes' as tabela,
  COUNT(*) as total_restante
FROM clientes

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'fornecedores' as tabela,
  COUNT(*) as total_restante
FROM fornecedores

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'vendas' as tabela,
  COUNT(*) as total_restante
FROM vendas

UNION ALL

SELECT 
  'APOS_LIMPEZA' as momento,
  'ordens_servico' as tabela,
  COUNT(*) as total_restante
FROM ordens_servico;

-- 9️⃣ VERIFICAR EMPRESAS RESTANTES E SEUS DADOS
SELECT 
  'EMPRESAS_FINAIS' as status,
  e.id,
  e.nome,
  e.cnpj,
  e.user_id,
  e.created_at,
  COUNT(DISTINCT f.id) as funcionarios,
  COUNT(DISTINCT p.id) as produtos,
  COUNT(DISTINCT c.id) as clientes,
  COUNT(DISTINCT fo.id) as fornecedores
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
LEFT JOIN produtos p ON p.empresa_id = e.id  
LEFT JOIN clientes c ON c.empresa_id = e.id
LEFT JOIN fornecedores fo ON fo.empresa_id = e.id
GROUP BY e.id, e.nome, e.cnpj, e.user_id, e.created_at
ORDER BY e.created_at;

-- 🔟 VERIFICAR INTEGRIDADE REFERENCIAL FINAL
SELECT 
  'INTEGRIDADE_FINAL' as status,
  'Produtos órfãos' as tipo,
  COUNT(*) as quantidade
FROM produtos 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  'INTEGRIDADE_FINAL' as status,
  'Clientes órfãos' as tipo,
  COUNT(*) as quantidade
FROM clientes 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  'INTEGRIDADE_FINAL' as status,
  'Funcionários órfãos' as tipo,
  COUNT(*) as quantidade
FROM funcionarios 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  'INTEGRIDADE_FINAL' as status,
  'Fornecedores órfãos' as tipo,
  COUNT(*) as quantidade
FROM fornecedores 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- =====================================================
-- ✅ RESULTADO ESPERADO APÓS EXECUÇÃO
-- =====================================================
-- ✅ Apenas empresas com user_id válido (UUID do Supabase Auth)
-- ✅ Zero registros órfãos em qualquer tabela
-- ✅ Dados de teste/amostra completamente removidos
-- ✅ Sequências otimizadas (apenas para tabelas INTEGER)
-- ✅ Integridade referencial 100% preservada
-- ✅ Sistema limpo e profissional
-- =====================================================