-- ================================================
-- DISABLE RLS SIMPLES - PDV ALLIMPORT
-- Execute este comando no SQL Editor do Supabase
-- ================================================

-- Desabilitar RLS de forma mais explícita
ALTER TABLE IF EXISTS produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS itens_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- Verificar status do RLS nas tabelas
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('produtos', 'clientes', 'categorias', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
AND schemaname = 'public';

-- Teste direto de acesso
SELECT COUNT(*) as total_produtos FROM produtos;
