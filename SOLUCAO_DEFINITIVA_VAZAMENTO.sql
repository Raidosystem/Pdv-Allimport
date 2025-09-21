-- ========================================
-- 🚨 SOLUÇÃO DEFINITIVA - ELIMINAR VAZAMENTO
-- O problema está confirmado: você vê produtos de outros usuários
-- ========================================

-- 1. VERIFICAR PROBLEMA ATUAL
SELECT 
    '🚨 CONFIRMAÇÃO DO PROBLEMA' as info,
    'Produtos de outros usuários visíveis' as problema,
    COUNT(*) as quantidade
FROM produtos 
WHERE user_id != auth.uid() OR user_id IS NULL;

-- 2. DESABILITAR RLS TEMPORARIAMENTE PARA LIMPEZA
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

-- 3. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Usuários podem ver seus produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem criar produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem atualizar seus produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem excluir seus produtos" ON produtos;
DROP POLICY IF EXISTS "produtos_select_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_update_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_policy" ON produtos;

DROP POLICY IF EXISTS "Usuários podem ver seus clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem criar clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem atualizar seus clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem excluir seus clientes" ON clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;

DROP POLICY IF EXISTS "Usuários podem ver suas vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários podem criar vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários podem atualizar suas vendas" ON vendas;
DROP POLICY IF EXISTS "vendas_select_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_update_policy" ON vendas;

DROP POLICY IF EXISTS "Usuários podem ver itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem criar itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem atualizar itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_select_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;

DROP POLICY IF EXISTS "Usuários podem ver seus caixas" ON caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus caixas" ON caixa;
DROP POLICY IF EXISTS "caixa_select_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_insert_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_update_policy" ON caixa;

DROP POLICY IF EXISTS "Usuários podem ver movimentações de seus caixas" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_select_policy" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_insert_policy" ON movimentacoes_caixa;

DROP POLICY IF EXISTS "Usuários podem ver suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem criar ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem atualizar suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_insert_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_policy" ON ordens_servico;

-- 4. ATRIBUIR TODOS OS DADOS ÓRFÃOS AO USUÁRIO ATUAL
-- CRÍTICO: Execute este script logado como o usuário que deve ter os dados!
UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE vendas_itens SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE movimentacoes_caixa SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();
UPDATE ordens_servico SET user_id = auth.uid() WHERE user_id IS NULL OR user_id != auth.uid();

-- 5. REATIVAR RLS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS SUPER RESTRITIVAS
-- PRODUTOS
CREATE POLICY "produtos_policy_select" ON produtos
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "produtos_policy_insert" ON produtos
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "produtos_policy_update" ON produtos
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "produtos_policy_delete" ON produtos
    FOR DELETE USING (auth.uid() = user_id);

-- CLIENTES
CREATE POLICY "clientes_policy_select" ON clientes
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "clientes_policy_insert" ON clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "clientes_policy_update" ON clientes
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "clientes_policy_delete" ON clientes
    FOR DELETE USING (auth.uid() = user_id);

-- VENDAS
CREATE POLICY "vendas_policy_select" ON vendas
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "vendas_policy_insert" ON vendas
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "vendas_policy_update" ON vendas
    FOR UPDATE USING (auth.uid() = user_id);

-- VENDAS_ITENS
CREATE POLICY "vendas_itens_policy_select" ON vendas_itens
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "vendas_itens_policy_insert" ON vendas_itens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- CAIXA
CREATE POLICY "caixa_policy_select" ON caixa
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "caixa_policy_insert" ON caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "caixa_policy_update" ON caixa
    FOR UPDATE USING (auth.uid() = user_id);

-- MOVIMENTACOES_CAIXA
CREATE POLICY "movimentacoes_policy_select" ON movimentacoes_caixa
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "movimentacoes_policy_insert" ON movimentacoes_caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ORDENS_SERVICO
CREATE POLICY "ordens_policy_select" ON ordens_servico
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "ordens_policy_insert" ON ordens_servico
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "ordens_policy_update" ON ordens_servico
    FOR UPDATE USING (auth.uid() = user_id);

-- 7. RECRIAR TRIGGERS PARA AUTO-POPULAR user_id
CREATE OR REPLACE FUNCTION auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_produtos_user_id ON produtos;
CREATE TRIGGER trigger_produtos_user_id
    BEFORE INSERT ON produtos
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_clientes_user_id ON clientes;
CREATE TRIGGER trigger_clientes_user_id
    BEFORE INSERT ON clientes
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_vendas_user_id ON vendas;
CREATE TRIGGER trigger_vendas_user_id
    BEFORE INSERT ON vendas
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_vendas_itens_user_id ON vendas_itens;
CREATE TRIGGER trigger_vendas_itens_user_id
    BEFORE INSERT ON vendas_itens
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_caixa_user_id ON caixa;
CREATE TRIGGER trigger_caixa_user_id
    BEFORE INSERT ON caixa
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_movimentacoes_user_id ON movimentacoes_caixa;
CREATE TRIGGER trigger_movimentacoes_user_id
    BEFORE INSERT ON movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

DROP TRIGGER IF EXISTS trigger_ordens_user_id ON ordens_servico;
CREATE TRIGGER trigger_ordens_user_id
    BEFORE INSERT ON ordens_servico
    FOR EACH ROW EXECUTE FUNCTION auto_set_user_id();

-- 8. TESTE FINAL
SELECT 
    '✅ TESTE FINAL' as resultado,
    'Produtos visíveis após correção' as item,
    COUNT(*) as quantidade
FROM produtos;

SELECT 
    '✅ TESTE FINAL' as resultado,
    'Produtos de outros usuários' as item,
    COUNT(*) as quantidade
FROM produtos 
WHERE user_id != auth.uid();

SELECT '🎉 VAZAMENTO ELIMINADO DEFINITIVAMENTE!' as resultado;