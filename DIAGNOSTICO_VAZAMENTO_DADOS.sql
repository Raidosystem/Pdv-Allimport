-- ========================================
-- 🚨 DIAGNÓSTICO COMPLETO DE VAZAMENTO DE DADOS
-- Verificar por que RLS não está funcionando
-- ========================================

-- 1. VERIFICAR SE RLS ESTÁ REALMENTE ATIVO
SELECT 
    '🔍 STATUS RLS ATUAL' as tipo,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa', 'categorias')
ORDER BY tablename;

-- 2. VERIFICAR POLÍTICAS EXISTENTES
SELECT 
    '🔑 POLÍTICAS ATIVAS' as tipo,
    tablename,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa', 'categorias')
ORDER BY tablename, policyname;

-- 3. VERIFICAR ESTRUTURA REAL DAS TABELAS - TODAS AS COLUNAS
SELECT 
    '📊 ESTRUTURA PRODUTOS' as tipo,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'produtos' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 
    '📊 ESTRUTURA CLIENTES' as tipo,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 
    '📊 ESTRUTURA VENDAS' as tipo,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'vendas' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. VERIFICAR SE EXISTEM COLUNAS user_id/usuario_id
SELECT 
    '🔍 VERIFICAÇÃO USER_ID' as tipo,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
  AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name, column_name;

-- 5. VERIFICAR USUÁRIO ATUAL E SUAS PERMISSÕES
SELECT 
    '👤 USUÁRIO ATUAL' as tipo,
    auth.uid() as user_id,
    auth.email() as email,
    auth.role() as role;

-- 6. TESTE DIRETO SEM FILTROS - CONTAR TUDO
SELECT 'CONTAGEM TOTAL PRODUTOS' as teste, COUNT(*) as total FROM produtos;
SELECT 'CONTAGEM TOTAL CLIENTES' as teste, COUNT(*) as total FROM clientes;
SELECT 'CONTAGEM TOTAL VENDAS' as teste, COUNT(*) as total FROM vendas;

-- 7. VERIFICAR SE HÁ TRIGGERS QUE POPULAM user_id
SELECT 
    '⚙️ TRIGGERS' as tipo,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE event_object_schema = 'public'
  AND event_object_table IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
ORDER BY event_object_table, trigger_name;

-- 8. VERIFICAR DADOS SAMPLES - MOSTRAR user_id DE ALGUNS REGISTROS
SELECT 
    '🔍 SAMPLE PRODUTOS' as tipo,
    id,
    nome,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'user_id' AND table_schema = 'public')
        THEN 'user_id existe'
        ELSE 'user_id NÃO existe'
    END as status_user_id
FROM produtos 
LIMIT 3;

SELECT 
    '🔍 SAMPLE CLIENTES' as tipo,
    id,
    nome,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'user_id' AND table_schema = 'public')
        THEN 'user_id existe'
        ELSE 'user_id NÃO existe'
    END as status_user_id
FROM clientes 
LIMIT 3;

-- 9. VERIFICAR SE EXISTEM OUTRAS COLUNAS QUE PODERIAM SER USADAS PARA ISOLAMENTO
SELECT 
    '🔍 POSSÍVEIS COLUNAS ISOLAMENTO' as tipo,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas')
  AND (
    column_name LIKE '%empresa%' OR 
    column_name LIKE '%company%' OR 
    column_name LIKE '%owner%' OR 
    column_name LIKE '%created_by%' OR
    column_name LIKE '%criado_por%'
  )
ORDER BY table_name, column_name;

SELECT '🚨 DIAGNÓSTICO COMPLETO FINALIZADO' as resultado;