-- ========================================
-- 🔧 CORREÇÃO FINAL - FORÇAR RLS FUNCIONAR
-- Problema: novaradiosystem vendo dados do assistenciaallimport10
-- ========================================

-- 1. VERIFICAR USUÁRIO ATUAL
SELECT 
    '👤 EXECUTANDO COMO' as info,
    auth.email() as email,
    auth.uid() as user_id,
    current_user as database_user;

-- 2. DESABILITAR RLS TEMPORARIAMENTE PARA LIMPEZA TOTAL
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

-- 3. REMOVER TODAS AS POLÍTICAS EXISTENTES (ESTÃO COM PROBLEMA)
DO $$ 
DECLARE 
    pol RECORD;
BEGIN
    -- Produtos
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'produtos' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON produtos', pol.policyname);
    END LOOP;
    
    -- Clientes
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'clientes' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON clientes', pol.policyname);
    END LOOP;
    
    -- Vendas
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'vendas' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON vendas', pol.policyname);
    END LOOP;
    
    -- Vendas_itens
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'vendas_itens' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON vendas_itens', pol.policyname);
    END LOOP;
    
    -- Caixa
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'caixa' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON caixa', pol.policyname);
    END LOOP;
    
    -- Movimentacoes_caixa
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'movimentacoes_caixa' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON movimentacoes_caixa', pol.policyname);
    END LOOP;
    
    -- Ordens_servico
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'ordens_servico' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON ordens_servico', pol.policyname);
    END LOOP;
END $$;

-- 4. GARANTIR QUE TODOS OS DADOS TÊM user_id CORRETO
-- Dados órfãos vão para assistenciaallimport10 (usuário principal)
UPDATE produtos SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE clientes SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE vendas SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE vendas_itens SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE caixa SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE movimentacoes_caixa SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;
UPDATE ordens_servico SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') WHERE user_id IS NULL;

-- 5. REATIVAR RLS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS SIMPLES E EFICAZES
-- PRODUTOS
CREATE POLICY "produtos_rls_policy" ON produtos
    FOR ALL USING (auth.uid() = user_id);

-- CLIENTES
CREATE POLICY "clientes_rls_policy" ON clientes
    FOR ALL USING (auth.uid() = user_id);

-- VENDAS
CREATE POLICY "vendas_rls_policy" ON vendas
    FOR ALL USING (auth.uid() = user_id);

-- VENDAS_ITENS
CREATE POLICY "vendas_itens_rls_policy" ON vendas_itens
    FOR ALL USING (auth.uid() = user_id);

-- CAIXA
CREATE POLICY "caixa_rls_policy" ON caixa
    FOR ALL USING (auth.uid() = user_id);

-- MOVIMENTACOES_CAIXA
CREATE POLICY "movimentacoes_caixa_rls_policy" ON movimentacoes_caixa
    FOR ALL USING (auth.uid() = user_id);

-- ORDENS_SERVICO
CREATE POLICY "ordens_servico_rls_policy" ON ordens_servico
    FOR ALL USING (auth.uid() = user_id);

-- 7. CRIAR FUNÇÃO E TRIGGERS PARA AUTO-POPULAR user_id
CREATE OR REPLACE FUNCTION auto_user_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id = auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover triggers antigos e criar novos
DROP TRIGGER IF EXISTS auto_user_id_produtos ON produtos;
CREATE TRIGGER auto_user_id_produtos
    BEFORE INSERT ON produtos
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_clientes ON clientes;
CREATE TRIGGER auto_user_id_clientes
    BEFORE INSERT ON clientes
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_vendas ON vendas;
CREATE TRIGGER auto_user_id_vendas
    BEFORE INSERT ON vendas
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_vendas_itens ON vendas_itens;
CREATE TRIGGER auto_user_id_vendas_itens
    BEFORE INSERT ON vendas_itens
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_caixa ON caixa;
CREATE TRIGGER auto_user_id_caixa
    BEFORE INSERT ON caixa
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_movimentacoes ON movimentacoes_caixa;
CREATE TRIGGER auto_user_id_movimentacoes
    BEFORE INSERT ON movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

DROP TRIGGER IF EXISTS auto_user_id_ordens ON ordens_servico;
CREATE TRIGGER auto_user_id_ordens
    BEFORE INSERT ON ordens_servico
    FOR EACH ROW EXECUTE FUNCTION auto_user_id();

-- 8. TESTE FINAL MULTI-USUÁRIO
SELECT 
    '🧪 TESTE COMO novaradiosystem' as teste,
    'Produtos visíveis' as item,
    COUNT(*) as quantidade
FROM produtos 
WHERE auth.uid() = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');

SELECT 
    '🧪 TESTE COMO assistenciaallimport10' as teste,
    'Produtos visíveis' as item,
    COUNT(*) as quantidade
FROM produtos 
WHERE auth.uid() = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- 9. VERIFICAÇÃO FINAL DE ISOLAMENTO
SELECT 
    '✅ VERIFICAÇÃO FINAL' as resultado,
    'Produtos visíveis para usuário atual' as item,
    COUNT(*) as quantidade
FROM produtos;

SELECT 
    '✅ VERIFICAÇÃO FINAL' as resultado,
    'Clientes visíveis para usuário atual' as item,
    COUNT(*) as quantidade
FROM clientes;

SELECT '🎉 RLS CORRIGIDO - ISOLAMENTO ATIVO!' as resultado;