-- 🔍 VERIFICAR ESTADO ATUAL: Ver qual é a situação real
-- Execute este script para ver o estado atual das tabelas

-- 1. Verificar todas as colunas relacionadas a usuário
SELECT 
    'COLUNAS ATUAIS:' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name IN ('caixa', 'movimentacoes_caixa', 'clientes')
AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name, column_name;

-- 2. Verificar estrutura completa da tabela caixa
SELECT 
    'ESTRUTURA CAIXA:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'caixa' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Verificar estrutura completa da tabela movimentacoes_caixa
SELECT 
    'ESTRUTURA MOVIMENTACOES:' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'movimentacoes_caixa' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Verificar status do RLS
SELECT 
    'STATUS RLS:' as info,
    tablename,
    CASE WHEN rowsecurity THEN '🔒 RLS Ativo' ELSE '🔓 RLS Inativo' END as status
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'clientes')
AND schemaname = 'public'
ORDER BY tablename;

-- 5. Verificar políticas existentes
SELECT 
    'POLÍTICAS EXISTENTES:' as info,
    tablename,
    policyname
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('caixa', 'movimentacoes_caixa', 'clientes')
ORDER BY tablename, policyname;
