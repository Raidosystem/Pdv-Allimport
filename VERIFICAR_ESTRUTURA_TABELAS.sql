-- ========================================
-- 🔍 VERIFICAÇÃO COMPLETA DA ESTRUTURA DAS TABELAS
-- Verificar se todas as tabelas têm as colunas necessárias para RLS
-- ========================================

-- 1. VERIFICAR COLUNAS USER_ID/USUARIO_ID EM TABELAS CRÍTICAS
SELECT 
    '🔍 VERIFICAÇÃO USER_ID' as info,
    table_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = t.table_name 
              AND table_schema = 'public'
              AND column_name = 'user_id'
        ) THEN '✅ user_id EXISTE'
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = t.table_name 
              AND table_schema = 'public'
              AND column_name = 'usuario_id'
        ) THEN '✅ usuario_id EXISTE'
        ELSE '❌ FALTA COLUNA'
    END as status_user_id
FROM (
    SELECT 'produtos' as table_name
    UNION SELECT 'clientes'
    UNION SELECT 'vendas'
    UNION SELECT 'itens_venda'
    UNION SELECT 'caixa'
    UNION SELECT 'movimentacoes_caixa'
    UNION SELECT 'categorias'
    UNION SELECT 'ordens_servico'
) t
ORDER BY table_name;

-- 2. LISTAR TODAS AS COLUNAS DAS TABELAS PRINCIPAIS
SELECT 
    '📋 ESTRUTURA PRODUTOS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'produtos' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 
    '📋 ESTRUTURA CLIENTES' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 
    '📋 ESTRUTURA VENDAS' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'vendas' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. VERIFICAR SE AS TABELAS EXISTEM
SELECT 
    '📊 TABELAS EXISTENTES' as info,
    table_name,
    'EXISTS' as status
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa', 'categorias', 'ordens_servico')
ORDER BY table_name;

-- 4. CONTAR REGISTROS POR TABELA (SEM RLS ATIVO)
SELECT 'CONTAGEM PRODUTOS' as tabela, COUNT(*) as registros FROM produtos;
SELECT 'CONTAGEM CLIENTES' as tabela, COUNT(*) as registros FROM clientes;
SELECT 'CONTAGEM VENDAS' as tabela, COUNT(*) as registros FROM vendas;

-- 5. VERIFICAR STATUS ATUAL DO RLS
SELECT 
    '🔒 STATUS RLS ATUAL' as info,
    tablename,
    CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa', 'categorias')
ORDER BY tablename;

SELECT '✅ VERIFICAÇÃO COMPLETA FINALIZADA' as resultado;