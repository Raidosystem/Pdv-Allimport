-- ============================================
-- VERIFICAR ESTRUTURA DAS TABELAS PARA RELATÓRIOS
-- Execute no Supabase SQL Editor
-- ============================================

-- 1. Verificar estrutura da tabela VENDAS
SELECT 
    '📋 ESTRUTURA TABELA VENDAS' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'vendas'
ORDER BY ordinal_position;

-- 2. Verificar estrutura da tabela CLIENTES
SELECT 
    '📋 ESTRUTURA TABELA CLIENTES' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'clientes'
ORDER BY ordinal_position;

-- 3. Verificar estrutura da tabela ORDENS DE SERVIÇO
SELECT 
    '📋 ESTRUTURA TABELA ORDENS_SERVICO' as secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ordens_servico'
ORDER BY ordinal_position;

-- 4. Contar registros
SELECT 
    '📊 CONTAGEM DE DADOS' as secao,
    (SELECT COUNT(*) FROM vendas) as total_vendas,
    (SELECT COUNT(*) FROM clientes) as total_clientes,
    (SELECT COUNT(*) FROM ordens_servico) as total_ordens;

-- 5. Amostra de vendas (últimas 5) - Usando apenas colunas que existem
SELECT 
    '💰 ÚLTIMAS VENDAS' as secao,
    *
FROM vendas
LIMIT 5;

-- 6. Verificar campos de data
SELECT 
    '📅 CAMPOS DE DATA DISPONÍVEIS' as secao,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'vendas'
  AND (data_type LIKE '%timestamp%' OR data_type LIKE '%date%')
ORDER BY column_name;
