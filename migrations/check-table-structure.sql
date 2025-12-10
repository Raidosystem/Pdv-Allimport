-- Script para verificar a estrutura completa da tabela ordens_servico
-- Execute este script no SQL Editor do Supabase Dashboard

-- 1. Verificar todas as colunas da tabela ordens_servico
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Verificar a estrutura da tabela (DDL)
SELECT 
    table_name,
    column_name,
    data_type,
    character_maximum_length,
    numeric_precision,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
AND table_schema = 'public'
ORDER BY ordinal_position;
