-- ===================================================
-- 🔍 DIAGNÓSTICO PRÉ-MIGRAÇÃO
-- ===================================================
-- Execute este script ANTES da migração para identificar problemas
-- Execute no Supabase SQL Editor
-- Data: 28/08/2025
-- ===================================================

-- 1. VERIFICAR ESTRUTURA ATUAL DAS TABELAS
-- ===================================================

-- Verificar se as tabelas principais existem
SELECT
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('produtos', 'clientes', 'categorias', 'products', 'customers', 'categories')
ORDER BY tablename;

-- 2. VERIFICAR COLUNAS DAS TABELAS EXISTENTES
-- ===================================================

-- Colunas da tabela produtos (se existir)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'produtos'
ORDER BY ordinal_position;

-- Colunas da tabela clientes (se existir)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'clientes'
ORDER BY ordinal_position;

-- Colunas da tabela categorias (se existir)
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name = 'categorias'
ORDER BY ordinal_position;

-- 3. CONTAR REGISTROS EXISTENTES
-- ===================================================

-- Contar registros em cada tabela
SELECT
    'produtos' as tabela,
    COUNT(*) as total_registros
FROM public.produtos
UNION ALL
SELECT
    'clientes' as tabela,
    COUNT(*) as total_registros
FROM public.clientes
UNION ALL
SELECT
    'categorias' as tabela,
    COUNT(*) as total_registros
FROM public.categorias
ORDER BY tabela;

-- 4. VERIFICAR ÍNDICES EXISTENTES
-- ===================================================

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('produtos', 'clientes', 'categorias')
ORDER BY tablename, indexname;

-- 5. VERIFICAR POLÍTICAS RLS E STATUS DAS TABELAS
-- ===================================================

-- Verificar se RLS está ativado nas tabelas
SELECT
    n.nspname as schemaname,
    c.relname as tablename,
    c.relrowsecurity as rls_ativado,
    CASE
        WHEN c.relrowsecurity THEN 'RLS ATIVADO'
        ELSE 'RLS DESABILITADO'
    END as status_rls
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
    AND c.relname IN ('produtos', 'clientes', 'categorias')
    AND c.relkind = 'r'
ORDER BY c.relname;

-- Políticas RLS existentes (se houver)
SELECT
    schemaname,
    tablename,
    policyname as nome_politica,
    cmd as comando,
    roles as roles
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN ('produtos', 'clientes', 'categorias')
ORDER BY tablename, policyname;

-- ===================================================
-- 📋 INTERPRETAÇÃO DOS RESULTADOS
-- ===================================================
-- Use estes resultados para decidir qual ação tomar:
--
-- SE tabelas NÃO existirem:
-- → Execute 001_MIGRACAO_RAPIDA.sql
--
-- SE tabelas existirem MAS faltarem colunas:
-- → O script adicionará as colunas automaticamente
--
-- SE tabelas existirem COM dados importantes:
-- → Faça backup antes de executar
--
-- SE RLS estiver ativado:
-- → O script desabilitará para acesso público
-- ===================================================
