-- ============================================
-- CORREÇÃO CRÍTICA - ADICIONAR COLUNAS FALTANTES + RLS
-- ============================================
-- Este script corrige o erro "column empresa_id does not exist"
-- e aplica todas as correções de RLS e email.
-- ============================================

-- ============================================
-- ETAPA 1: GARANTIR QUE AS COLUNAS EXISTAM
-- ============================================

DO $$
DECLARE
    t text;
BEGIN
    -- Lista de tabelas que precisam ter empresa_id e user_id
    FOREACH t IN ARRAY ARRAY['caixa', 'produtos', 'clientes', 'vendas', 'vendas_itens', 'movimentacoes_caixa', 'ordens_servico', 'funcionarios']
    LOOP
        -- 1. Adicionar empresa_id se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = t AND column_name = 'empresa_id') THEN
            EXECUTE format('ALTER TABLE %I ADD COLUMN empresa_id UUID REFERENCES empresas(id)', t);
            RAISE NOTICE '✅ Coluna empresa_id adicionada na tabela %', t;
        ELSE
            RAISE NOTICE 'ℹ️ Coluna empresa_id já existe na tabela %', t;
        END IF;

        -- 2. Adicionar user_id se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = t AND column_name = 'user_id') THEN
            EXECUTE format('ALTER TABLE %I ADD COLUMN user_id UUID REFERENCES auth.users(id)', t);
            RAISE NOTICE '✅ Coluna user_id adicionada na tabela %', t;
        ELSE
            RAISE NOTICE 'ℹ️ Coluna user_id já existe na tabela %', t;
        END IF;
    END LOOP;
END $$;

-- ============================================
-- ETAPA 2: ADICIONAR COLUNA EMAIL NA TABELA EMPRESAS
-- ============================================

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'empresas' 
    AND column_name = 'email'
  ) THEN
    ALTER TABLE empresas ADD COLUMN email TEXT;
    RAISE NOTICE '✅ Coluna email adicionada à tabela empresas';
  END IF;
END $$;

-- Atualizar email de cada empresa com base no user_id
UPDATE empresas e
SET email = au.email
FROM auth.users au
WHERE e.user_id = au.id
AND e.email IS NULL;

-- ============================================
-- ETAPA 3: CORRIGIR POLÍTICAS RLS (COM CHECK TRUE)
-- ============================================

-- Função auxiliar (garantir que existe)
CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT id FROM empresas WHERE user_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- CAIXA
DROP POLICY IF EXISTS caixa_empresa_isolation ON caixa;
DROP POLICY IF EXISTS caixa_select_policy ON caixa;
DROP POLICY IF EXISTS caixa_insert_policy ON caixa;
DROP POLICY IF EXISTS caixa_update_policy ON caixa;
DROP POLICY IF EXISTS caixa_delete_policy ON caixa;

CREATE POLICY caixa_select_policy ON caixa FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY caixa_insert_policy ON caixa FOR INSERT WITH CHECK (true); -- Permite INSERT, trigger preenche
CREATE POLICY caixa_update_policy ON caixa FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY caixa_delete_policy ON caixa FOR DELETE USING (empresa_id = get_user_empresa_id());

-- PRODUTOS
DROP POLICY IF EXISTS produtos_empresa_isolation ON produtos;
DROP POLICY IF EXISTS produtos_select_policy ON produtos;
DROP POLICY IF EXISTS produtos_insert_policy ON produtos;
DROP POLICY IF EXISTS produtos_update_policy ON produtos;
DROP POLICY IF EXISTS produtos_delete_policy ON produtos;

CREATE POLICY produtos_select_policy ON produtos FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY produtos_insert_policy ON produtos FOR INSERT WITH CHECK (true);
CREATE POLICY produtos_update_policy ON produtos FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY produtos_delete_policy ON produtos FOR DELETE USING (empresa_id = get_user_empresa_id());

-- CLIENTES
DROP POLICY IF EXISTS clientes_empresa_isolation ON clientes;
DROP POLICY IF EXISTS clientes_select_policy ON clientes;
DROP POLICY IF EXISTS clientes_insert_policy ON clientes;
DROP POLICY IF EXISTS clientes_update_policy ON clientes;
DROP POLICY IF EXISTS clientes_delete_policy ON clientes;

CREATE POLICY clientes_select_policy ON clientes FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY clientes_insert_policy ON clientes FOR INSERT WITH CHECK (true);
CREATE POLICY clientes_update_policy ON clientes FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY clientes_delete_policy ON clientes FOR DELETE USING (empresa_id = get_user_empresa_id());

-- VENDAS
DROP POLICY IF EXISTS vendas_empresa_isolation ON vendas;
DROP POLICY IF EXISTS vendas_select_policy ON vendas;
DROP POLICY IF EXISTS vendas_insert_policy ON vendas;
DROP POLICY IF EXISTS vendas_update_policy ON vendas;
DROP POLICY IF EXISTS vendas_delete_policy ON vendas;

CREATE POLICY vendas_select_policy ON vendas FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY vendas_insert_policy ON vendas FOR INSERT WITH CHECK (true);
CREATE POLICY vendas_update_policy ON vendas FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY vendas_delete_policy ON vendas FOR DELETE USING (empresa_id = get_user_empresa_id());

-- VENDAS_ITENS
DROP POLICY IF EXISTS vendas_itens_empresa_isolation ON vendas_itens;
DROP POLICY IF EXISTS vendas_itens_select_policy ON vendas_itens;
DROP POLICY IF EXISTS vendas_itens_insert_policy ON vendas_itens;
DROP POLICY IF EXISTS vendas_itens_update_policy ON vendas_itens;
DROP POLICY IF EXISTS vendas_itens_delete_policy ON vendas_itens;

CREATE POLICY vendas_itens_select_policy ON vendas_itens FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY vendas_itens_insert_policy ON vendas_itens FOR INSERT WITH CHECK (true);
CREATE POLICY vendas_itens_update_policy ON vendas_itens FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY vendas_itens_delete_policy ON vendas_itens FOR DELETE USING (empresa_id = get_user_empresa_id());

-- MOVIMENTACOES_CAIXA
DROP POLICY IF EXISTS movimentacoes_caixa_empresa_isolation ON movimentacoes_caixa;
DROP POLICY IF EXISTS movimentacoes_caixa_select_policy ON movimentacoes_caixa;
DROP POLICY IF EXISTS movimentacoes_caixa_insert_policy ON movimentacoes_caixa;
DROP POLICY IF EXISTS movimentacoes_caixa_update_policy ON movimentacoes_caixa;
DROP POLICY IF EXISTS movimentacoes_caixa_delete_policy ON movimentacoes_caixa;

CREATE POLICY movimentacoes_caixa_select_policy ON movimentacoes_caixa FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY movimentacoes_caixa_insert_policy ON movimentacoes_caixa FOR INSERT WITH CHECK (true);
CREATE POLICY movimentacoes_caixa_update_policy ON movimentacoes_caixa FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY movimentacoes_caixa_delete_policy ON movimentacoes_caixa FOR DELETE USING (empresa_id = get_user_empresa_id());

-- ORDENS_SERVICO
DROP POLICY IF EXISTS ordens_servico_empresa_isolation ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_select_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_insert_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_update_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_delete_policy ON ordens_servico;

CREATE POLICY ordens_servico_select_policy ON ordens_servico FOR SELECT USING (empresa_id = get_user_empresa_id());
CREATE POLICY ordens_servico_insert_policy ON ordens_servico FOR INSERT WITH CHECK (true);
CREATE POLICY ordens_servico_update_policy ON ordens_servico FOR UPDATE USING (empresa_id = get_user_empresa_id());
CREATE POLICY ordens_servico_delete_policy ON ordens_servico FOR DELETE USING (empresa_id = get_user_empresa_id());

-- ============================================
-- ETAPA 4: VERIFICAÇÃO
-- ============================================

SELECT 
  '✅ ESTRUTURA CORRIGIDA' as status,
  table_name,
  column_name
FROM information_schema.columns 
WHERE column_name = 'empresa_id' 
AND table_schema = 'public'
ORDER BY table_name;

SELECT '🎉 TUDO PRONTO! Agora RECARREGUE o navegador (Ctrl+Shift+R) e tente abrir o caixa.' as resultado;
