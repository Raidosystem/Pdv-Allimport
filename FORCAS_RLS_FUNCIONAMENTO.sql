-- ========================================
-- 🔧 CORREÇÃO FORÇADA - RLS NÃO ESTÁ FUNCIONANDO
-- Vai forçar o RLS a funcionar corretamente
-- ========================================

-- 1. PRIMEIRO, VERIFICAR O PROBLEMA EXATO
SELECT 
    '🔍 DIAGNÓSTICO RÁPIDO' as step,
    current_user as db_user,
    session_user as session_user,
    auth.uid() as auth_user_id,
    auth.email() as auth_email;

-- 2. VERIFICAR SE AS POLÍTICAS EXISTEM MAS NÃO ESTÃO FUNCIONANDO
SELECT 
    '📋 POLÍTICAS EXISTENTES' as step,
    tablename,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
GROUP BY tablename
ORDER BY tablename;

-- 3. REMOVER TODAS AS POLÍTICAS EXISTENTES E RECRIAR
-- PRODUTOS
DROP POLICY IF EXISTS "Usuários podem ver seus produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem criar produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem atualizar seus produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários podem excluir seus produtos" ON produtos;

-- CLIENTES  
DROP POLICY IF EXISTS "Usuários podem ver seus clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem criar clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem atualizar seus clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem excluir seus clientes" ON clientes;

-- VENDAS
DROP POLICY IF EXISTS "Usuários podem ver suas vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários podem criar vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários podem atualizar suas vendas" ON vendas;

-- VENDAS_ITENS
DROP POLICY IF EXISTS "Usuários podem ver itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem criar itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem atualizar itens de suas vendas" ON vendas_itens;

-- CAIXA
DROP POLICY IF EXISTS "Usuários podem ver seus caixas" ON caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus caixas" ON caixa;

-- MOVIMENTACOES_CAIXA
DROP POLICY IF EXISTS "Usuários podem ver movimentações de seus caixas" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON movimentacoes_caixa;

-- ORDENS_SERVICO
DROP POLICY IF EXISTS "Usuários podem ver suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem criar ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem atualizar suas ordens" ON ordens_servico;

-- 4. RECRIAR POLÍTICAS COM CONDIÇÕES MAIS ESPECÍFICAS
-- PRODUTOS - Políticas mais restritivas
CREATE POLICY "produtos_select_policy" ON produtos
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "produtos_insert_policy" ON produtos
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

CREATE POLICY "produtos_update_policy" ON produtos
    FOR UPDATE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    )
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "produtos_delete_policy" ON produtos
    FOR DELETE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

-- CLIENTES - Políticas mais restritivas
CREATE POLICY "clientes_select_policy" ON clientes
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "clientes_insert_policy" ON clientes
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

CREATE POLICY "clientes_update_policy" ON clientes
    FOR UPDATE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    )
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "clientes_delete_policy" ON clientes
    FOR DELETE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

-- VENDAS - Políticas mais restritivas
CREATE POLICY "vendas_select_policy" ON vendas
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "vendas_insert_policy" ON vendas
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

CREATE POLICY "vendas_update_policy" ON vendas
    FOR UPDATE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

-- VENDAS_ITENS - Políticas mais restritivas
CREATE POLICY "vendas_itens_select_policy" ON vendas_itens
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "vendas_itens_insert_policy" ON vendas_itens
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

-- CAIXA - Políticas mais restritivas
CREATE POLICY "caixa_select_policy" ON caixa
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "caixa_insert_policy" ON caixa
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

CREATE POLICY "caixa_update_policy" ON caixa
    FOR UPDATE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

-- MOVIMENTACOES_CAIXA - Políticas mais restritivas
CREATE POLICY "movimentacoes_caixa_select_policy" ON movimentacoes_caixa
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "movimentacoes_caixa_insert_policy" ON movimentacoes_caixa
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

-- ORDENS_SERVICO - Políticas mais restritivas
CREATE POLICY "ordens_servico_select_policy" ON ordens_servico
    FOR SELECT 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

CREATE POLICY "ordens_servico_insert_policy" ON ordens_servico
    FOR INSERT 
    TO authenticated
    WITH CHECK (
        auth.uid() IS NOT NULL 
        AND (user_id IS NULL OR user_id = auth.uid())
    );

CREATE POLICY "ordens_servico_update_policy" ON ordens_servico
    FOR UPDATE 
    TO authenticated
    USING (
        auth.uid() IS NOT NULL 
        AND user_id IS NOT NULL 
        AND auth.uid() = user_id
    );

-- 5. VERIFICAR SE RLS ESTÁ REALMENTE ATIVO
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. FORÇAR TODOS OS REGISTROS ÓRFÃOS PARA O USUÁRIO ATUAL
-- ATENÇÃO: Isso vai atribuir TODOS os dados sem dono para quem executar
UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE vendas_itens SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE movimentacoes_caixa SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE ordens_servico SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;

-- 7. TESTE FINAL
SELECT 
    '✅ TESTE FINAL' as step,
    'PRODUTOS' as tabela,
    COUNT(*) as registros_visiveis
FROM produtos;

SELECT 
    '✅ TESTE FINAL' as step,
    'CLIENTES' as tabela,
    COUNT(*) as registros_visiveis
FROM clientes;

SELECT 
    '✅ TESTE FINAL' as step,
    'VENDAS' as tabela,
    COUNT(*) as registros_visiveis
FROM vendas;

SELECT '🔒 RLS FORÇADO - DEVE FUNCIONAR AGORA!' as resultado;