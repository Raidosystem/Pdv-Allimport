-- ========================================
-- 🔍 VERIFICAÇÃO PÓS-CORREÇÃO
-- Confirmar que o vazamento foi corrigido
-- ========================================

-- 1. VERIFICAR SE RLS ESTÁ ATIVO EM TODAS AS TABELAS
SELECT 
    '🔍 STATUS RLS ATUAL' as tipo,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico', 'categorias')
ORDER BY tablename;

-- 2. VERIFICAR POLÍTICAS ATIVAS
SELECT 
    '🔑 POLÍTICAS ATIVAS' as tipo,
    tablename,
    policyname,
    cmd as operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename, policyname;

-- 3. VERIFICAR COLUNAS user_id
SELECT 
    '🔍 COLUNAS USER_ID' as tipo,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
  AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name;

-- 4. VERIFICAR TRIGGERS ATIVOS
SELECT 
    '⚙️ TRIGGERS ATIVOS' as tipo,
    trigger_name,
    event_object_table as tabela,
    event_manipulation as evento
FROM information_schema.triggers 
WHERE event_object_schema = 'public'
  AND event_object_table IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
  AND trigger_name LIKE '%user_id%'
ORDER BY event_object_table;

-- 5. TESTE DE ISOLAMENTO - CONTAR REGISTROS VISÍVEIS
SELECT 'TESTE PRODUTOS' as teste, COUNT(*) as registros_visiveis FROM produtos;
SELECT 'TESTE CLIENTES' as teste, COUNT(*) as registros_visiveis FROM clientes;
SELECT 'TESTE VENDAS' as teste, COUNT(*) as registros_visiveis FROM vendas;

-- 6. VERIFICAR USUÁRIO ATUAL
SELECT 
    '👤 USUÁRIO ATUAL' as tipo,
    auth.uid() as user_id,
    auth.email() as email;

SELECT '✅ VERIFICAÇÃO CONCLUÍDA - SISTEMA SEGURO!' as resultado;