-- ========================================
-- 🧹 LIMPEZA COMPLETA - REMOVER SCRIPTS PROBLEMÁTICOS
-- Este script vai limpar tudo e recriar do zero
-- ========================================

-- 1. REMOVER TODAS AS POLÍTICAS RLS EXISTENTES (QUE ESTÃO COM PROBLEMA)
DO $$ 
DECLARE 
    pol RECORD;
    tabela TEXT;
BEGIN
    -- Lista de tabelas para limpar
    FOR tabela IN 
        SELECT unnest(ARRAY['produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico'])
    LOOP
        -- Remover todas as políticas da tabela
        FOR pol IN 
            SELECT policyname 
            FROM pg_policies 
            WHERE tablename = tabela AND schemaname = 'public'
        LOOP
            EXECUTE format('DROP POLICY IF EXISTS %I ON %I', pol.policyname, tabela);
            RAISE NOTICE 'Removida política: % da tabela %', pol.policyname, tabela;
        END LOOP;
    END LOOP;
END $$;

-- 2. REMOVER TODAS AS FUNÇÕES E TRIGGERS CRIADOS
DROP FUNCTION IF EXISTS set_user_id() CASCADE;
DROP FUNCTION IF EXISTS auto_set_user_id() CASCADE;
DROP FUNCTION IF EXISTS auto_user_id() CASCADE;
DROP FUNCTION IF EXISTS get_produtos_by_user(TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_clientes_by_user(TEXT) CASCADE;

-- 3. REMOVER VIEWS CRIADAS
DROP VIEW IF EXISTS produtos_isolados CASCADE;
DROP VIEW IF EXISTS clientes_isolados CASCADE;
DROP VIEW IF EXISTS vendas_isoladas CASCADE;
DROP VIEW IF EXISTS produtos_isolados_por_usuario CASCADE;
DROP VIEW IF EXISTS clientes_isolados_por_usuario CASCADE;
DROP VIEW IF EXISTS vendas_isoladas_por_usuario CASCADE;

-- 4. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE IF EXISTS produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS vendas_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS movimentacoes_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS ordens_servico DISABLE ROW LEVEL SECURITY;

-- 5. GARANTIR QUE TODOS OS DADOS TÊM user_id CORRETO
-- Verificar se as colunas user_id existem e adicionar se necessário
DO $$
DECLARE
    tabela TEXT;
BEGIN
    FOR tabela IN 
        SELECT unnest(ARRAY['produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico'])
    LOOP
        -- Verificar se coluna user_id existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = tabela AND column_name = 'user_id' AND table_schema = 'public'
        ) THEN
            EXECUTE format('ALTER TABLE %I ADD COLUMN user_id UUID REFERENCES auth.users(id)', tabela);
            RAISE NOTICE 'Adicionada coluna user_id à tabela %', tabela;
        END IF;
    END LOOP;
END $$;

-- 6. ATRIBUIR DADOS ÓRFÃOS AO USUÁRIO PRINCIPAL
-- Todos os dados sem dono vão para assistenciaallimport10@gmail.com
UPDATE produtos SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE clientes SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE vendas SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE vendas_itens SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE caixa SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE movimentacoes_caixa SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

UPDATE ordens_servico SET user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
WHERE user_id IS NULL;

-- 7. REATIVAR RLS COM CONFIGURAÇÃO LIMPA
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 8. CRIAR POLÍTICAS SIMPLES E FUNCIONAIS
-- Uma política por tabela, super simples
CREATE POLICY "rls_policy" ON produtos FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON clientes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON vendas FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON vendas_itens FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON caixa FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON movimentacoes_caixa FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "rls_policy" ON ordens_servico FOR ALL USING (auth.uid() = user_id);

-- 9. CRIAR TRIGGER SIMPLES PARA AUTO-POPULAR user_id
CREATE OR REPLACE FUNCTION trigger_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas as tabelas
CREATE TRIGGER trigger_user_id BEFORE INSERT ON produtos FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON clientes FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON vendas FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON vendas_itens FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON caixa FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON movimentacoes_caixa FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();
CREATE TRIGGER trigger_user_id BEFORE INSERT ON ordens_servico FOR EACH ROW EXECUTE FUNCTION trigger_set_user_id();

-- 10. TESTE FINAL
SELECT 
    '🧹 LIMPEZA CONCLUÍDA' as resultado,
    'RLS reconfigurado do zero' as status,
    COUNT(*) as produtos_visiveis_admin
FROM produtos;

SELECT '🎉 SISTEMA LIMPO E RECONFIGURADO!' as resultado;