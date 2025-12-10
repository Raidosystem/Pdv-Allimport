-- 🔍 DIAGNÓSTICO COMPLETO DAS TABELAS
-- Execute este script para verificar a estrutura atual

-- 1. VERIFICAR TODAS AS TABELAS DISPONÍVEIS
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. VERIFICAR COLUNAS DA TABELA PRODUCTS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products'
ORDER BY ordinal_position;

-- 3. VERIFICAR COLUNAS DA TABELA CATEGORIES
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- 4. VERIFICAR COLUNAS DA TABELA CLIENTS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clients'
ORDER BY ordinal_position;

-- 5. VERIFICAR COLUNAS DA TABELA SERVICE_ORDERS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'service_orders'
ORDER BY ordinal_position;

-- 6. VERIFICAR SE EXISTEM TABELAS COM NOMES ALTERNATIVOS
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name LIKE '%product%' 
   OR table_name LIKE '%cliente%'
   OR table_name LIKE '%category%'
   OR table_name LIKE '%service%'
ORDER BY table_name, ordinal_position;
