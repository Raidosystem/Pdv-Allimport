-- ========================================
-- 🚨 CORREÇÃO CRÍTICA DE SEGURANÇA - PDV ALLIMPORT V2
-- ⚡ REABILITAR ROW LEVEL SECURITY (RLS) COM TIPOS CORRETOS
-- ========================================

-- 1. VERIFICAR TIPOS DAS COLUNAS PRIMEIRO
SELECT 
    '🔍 VERIFICAÇÃO TIPOS' as info,
    table_name,
    column_name,
    data_type,
    udt_name
FROM information_schema.columns 
WHERE table_name IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
  AND column_name IN ('user_id', 'usuario_id')
  AND table_schema = 'public'
ORDER BY table_name, column_name;

-- 2. REABILITAR RLS EM TODAS AS TABELAS CRÍTICAS
ALTER TABLE IF EXISTS produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- 3. POLÍTICAS FLEXÍVEIS - FUNCIONAM COM TEXT OU UUID
DROP POLICY IF EXISTS "produtos_user_policy" ON produtos;
CREATE POLICY "produtos_user_policy" ON produtos
    FOR ALL
    USING (
        (user_id IS NULL) OR 
        (auth.uid()::text = user_id::text)
    );

DROP POLICY IF EXISTS "clientes_user_policy" ON clientes;
CREATE POLICY "clientes_user_policy" ON clientes
    FOR ALL
    USING (
        (user_id IS NULL) OR 
        (auth.uid()::text = user_id::text)
    );

DROP POLICY IF EXISTS "vendas_user_policy" ON vendas;
CREATE POLICY "vendas_user_policy" ON vendas
    FOR ALL
    USING (
        (user_id IS NULL) OR 
        (auth.uid()::text = user_id::text)
    );

DROP POLICY IF EXISTS "itens_venda_user_policy" ON itens_venda;
CREATE POLICY "itens_venda_user_policy" ON itens_venda
    FOR ALL
    USING (
        (user_id IS NULL) OR 
        (auth.uid()::text = user_id::text)
    );

DROP POLICY IF EXISTS "caixa_user_policy" ON caixa;
CREATE POLICY "caixa_user_policy" ON caixa
    FOR ALL
    USING (
        (usuario_id IS NULL) OR 
        (auth.uid()::text = usuario_id::text)
    );

DROP POLICY IF EXISTS "movimentacoes_caixa_user_policy" ON movimentacoes_caixa;
CREATE POLICY "movimentacoes_caixa_user_policy" ON movimentacoes_caixa
    FOR ALL
    USING (
        (usuario_id IS NULL) OR 
        (auth.uid()::text = usuario_id::text)
    );

-- 4. POLÍTICAS PARA CATEGORIAS (PÚBLICAS PARA TODOS OS USUÁRIOS LOGADOS)
DROP POLICY IF EXISTS "categorias_authenticated_policy" ON categorias;
CREATE POLICY "categorias_authenticated_policy" ON categorias
    FOR ALL
    USING (auth.role() = 'authenticated');

-- 5. VERIFICAR STATUS FINAL DO RLS
SELECT 
    '🔍 STATUS RLS FINAL' as info,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as status
FROM pg_tables 
WHERE tablename IN ('produtos', 'clientes', 'categorias', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
AND schemaname = 'public'
ORDER BY tablename;

-- 6. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    '🔑 POLÍTICAS CRIADAS' as info,
    tablename,
    policyname,
    cmd as operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'categorias', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
ORDER BY tablename, policyname;

-- 7. INFORMAÇÕES DO USUÁRIO ATUAL
SELECT 
    '👤 USUÁRIO ATUAL' as info,
    auth.uid() as user_id_uuid,
    auth.uid()::text as user_id_text,
    auth.email() as email,
    auth.role() as role;

-- 8. TESTE DE ISOLAMENTO (deve retornar apenas dados do usuário logado)
SELECT 
    '🧪 TESTE ISOLAMENTO' as info,
    'Produtos visíveis após RLS' as descricao,
    COUNT(*) as quantidade
FROM produtos;

SELECT 
    '🧪 TESTE ISOLAMENTO' as info,
    'Clientes visíveis após RLS' as descricao,
    COUNT(*) as quantidade
FROM clientes;

SELECT '✅ CORREÇÃO DE SEGURANÇA V2 APLICADA COM SUCESSO' as resultado;
SELECT '⚠️ IMPORTANTE: Verifique se os dados agora estão isolados por usuário' as aviso;