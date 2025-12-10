-- =============================================
-- REMOVER ISOLAMENTO POR EMPRESA_ID (REVERTER)
-- =============================================
-- Este script remove as políticas RLS baseadas em empresa_id
-- que estavam causando o sumiço dos dados

-- =====================================
-- REMOVER POLÍTICAS RLS RESTRITIVAS
-- =====================================

-- Desabilitar RLS temporariamente
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes_impressao DISABLE ROW LEVEL SECURITY;

-- Remover políticas baseadas em empresa_id
DROP POLICY IF EXISTS "clientes_empresa_isolation" ON clientes;
DROP POLICY IF EXISTS "produtos_empresa_isolation" ON produtos;
DROP POLICY IF EXISTS "vendas_empresa_isolation" ON vendas;
DROP POLICY IF EXISTS "caixa_empresa_isolation" ON caixa;
DROP POLICY IF EXISTS "ordens_servico_empresa_isolation" ON ordens_servico;
DROP POLICY IF EXISTS "configuracoes_impressao_empresa_isolation" ON configuracoes_impressao;

-- =====================================
-- CRIAR POLÍTICAS PERMISSIVAS (SEM ISOLAMENTO)
-- =====================================

-- Reativar RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- CLIENTES - Permitir tudo para usuários autenticados
CREATE POLICY "clientes_all_authenticated" ON clientes
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- PRODUTOS - Permitir tudo para usuários autenticados
CREATE POLICY "produtos_all_authenticated" ON produtos
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- VENDAS - Permitir tudo para usuários autenticados
CREATE POLICY "vendas_all_authenticated" ON vendas
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- CAIXA - Permitir tudo para usuários autenticados
CREATE POLICY "caixa_all_authenticated" ON caixa
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- ORDENS_SERVICO - Permitir tudo para usuários autenticados
CREATE POLICY "ordens_servico_all_authenticated" ON ordens_servico
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- CONFIGURACOES_IMPRESSAO - Permitir tudo para usuários autenticados
CREATE POLICY "configuracoes_impressao_all_authenticated" ON configuracoes_impressao
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- =====================================
-- REMOVER TRIGGERS DE empresa_id
-- =====================================

DROP TRIGGER IF EXISTS set_empresa_id_clientes ON clientes;
DROP TRIGGER IF EXISTS set_empresa_id_produtos ON produtos;
DROP TRIGGER IF EXISTS set_empresa_id_vendas ON vendas;
DROP TRIGGER IF EXISTS set_empresa_id_caixa ON caixa;
DROP TRIGGER IF EXISTS set_empresa_id_ordens ON ordens_servico;
DROP TRIGGER IF EXISTS set_empresa_id_config ON configuracoes_impressao;

DROP FUNCTION IF EXISTS set_empresa_id_from_user();
DROP FUNCTION IF EXISTS get_user_empresa_id();

-- =====================================
-- VERIFICAÇÃO
-- =====================================

SELECT 
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'ordens_servico', 'configuracoes_impressao')
ORDER BY tablename, policyname;

SELECT '✅ POLÍTICAS PERMISSIVAS RESTAURADAS! Todos os dados devem estar visíveis.' as resultado;
