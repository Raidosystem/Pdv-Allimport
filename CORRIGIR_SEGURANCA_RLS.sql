-- ========================================
-- 🚨 CORREÇÃO CRÍTICA DE SEGURANÇA - PDV ALLIMPORT
-- ⚡ REABILITAR ROW LEVEL SECURITY (RLS)
-- ========================================
-- PROBLEMA: O arquivo DISABLE_RLS_SIMPLES.sql desabilitou a segurança,
-- causando vazamento de dados entre usuários/empresas.
-- 
-- SOLUÇÃO: Reabilitar RLS e criar políticas básicas de segurança
-- ========================================

-- 1. REABILITAR RLS EM TODAS AS TABELAS CRÍTICAS
ALTER TABLE IF EXISTS produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- 2. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA PRODUTOS
DROP POLICY IF EXISTS "produtos_user_policy" ON produtos;
CREATE POLICY "produtos_user_policy" ON produtos
    FOR ALL
    USING (auth.uid() = user_id::uuid OR user_id IS NULL);

-- 3. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA CLIENTES
DROP POLICY IF EXISTS "clientes_user_policy" ON clientes;
CREATE POLICY "clientes_user_policy" ON clientes
    FOR ALL
    USING (auth.uid() = user_id::uuid OR user_id IS NULL);

-- 4. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA VENDAS
DROP POLICY IF EXISTS "vendas_user_policy" ON vendas;
CREATE POLICY "vendas_user_policy" ON vendas
    FOR ALL
    USING (auth.uid() = user_id::uuid OR user_id IS NULL);

-- 5. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA ITENS_VENDA
DROP POLICY IF EXISTS "itens_venda_user_policy" ON itens_venda;
CREATE POLICY "itens_venda_user_policy" ON itens_venda
    FOR ALL
    USING (auth.uid() = user_id::uuid OR user_id IS NULL);

-- 6. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA CAIXA
DROP POLICY IF EXISTS "caixa_user_policy" ON caixa;
CREATE POLICY "caixa_user_policy" ON caixa
    FOR ALL
    USING (auth.uid() = usuario_id::uuid OR usuario_id IS NULL);

-- 7. CRIAR POLÍTICAS BÁSICAS DE SEGURANÇA PARA MOVIMENTACOES_CAIXA
DROP POLICY IF EXISTS "movimentacoes_caixa_user_policy" ON movimentacoes_caixa;
CREATE POLICY "movimentacoes_caixa_user_policy" ON movimentacoes_caixa
    FOR ALL
    USING (auth.uid() = usuario_id::uuid OR usuario_id IS NULL);

-- 8. POLÍTICAS PARA CATEGORIAS (PÚBLICAS PARA TODOS OS USUÁRIOS LOGADOS)
DROP POLICY IF EXISTS "categorias_authenticated_policy" ON categorias;
CREATE POLICY "categorias_authenticated_policy" ON categorias
    FOR ALL
    USING (auth.role() = 'authenticated');

-- 9. VERIFICAR STATUS FINAL DO RLS
SELECT 
    '🔍 STATUS RLS FINAL' as info,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as status
FROM pg_tables 
WHERE tablename IN ('produtos', 'clientes', 'categorias', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
AND schemaname = 'public'
ORDER BY tablename;

-- 10. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    '🔑 POLÍTICAS CRIADAS' as info,
    tablename,
    policyname,
    cmd as operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'categorias', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
ORDER BY tablename, policyname;

-- 11. TESTE DE ISOLAMENTO (deve retornar apenas dados do usuário logado)
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

-- 12. INFORMAÇÕES DO USUÁRIO ATUAL
SELECT 
    '👤 USUÁRIO ATUAL' as info,
    auth.uid() as user_id,
    auth.email() as email,
    auth.role() as role;

SELECT '✅ CORREÇÃO DE SEGURANÇA APLICADA COM SUCESSO' as resultado;
SELECT '⚠️ IMPORTANTE: Verifique se os dados agora estão isolados por usuário' as aviso;