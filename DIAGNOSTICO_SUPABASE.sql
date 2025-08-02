-- 🔍 DIAGNÓSTICO COMPLETO: Verificar estrutura atual
-- Execute este script primeiro para ver a estrutura atual

-- 1. Verificar todas as tabelas existentes
SELECT 
    'TABELAS EXISTENTES:' as info,
    table_name as tabela
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Verificar estrutura da tabela cash_registers (se existir)
SELECT 
    'ESTRUTURA cash_registers:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'cash_registers' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Verificar estrutura da tabela caixa (se existir)
SELECT 
    'ESTRUTURA caixa:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'caixa' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Verificar estrutura da tabela clientes (se existir)
SELECT 
    'ESTRUTURA clientes:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. Buscar todas as colunas que contêm 'user' no nome
SELECT 
    'COLUNAS COM USER:' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name, column_name;
