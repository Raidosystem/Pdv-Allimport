-- ==========================================
-- 🚨 CORREÇÃO URGENTE DO VAZAMENTO DE DADOS
-- Execute este script IMEDIATAMENTE no Supabase
-- ==========================================

-- 1. VERIFICAR STATUS ATUAL DAS TABELAS
SELECT 
    '🔍 STATUS ATUAL' as info,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ RLS ATIVO' ELSE '❌ RLS INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico', 'categorias')
ORDER BY tablename;

-- 2. VERIFICAR SE EXISTEM COLUNAS user_id
SELECT 
    '🔍 COLUNAS USER_ID' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
  AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name;

-- 3. ADICIONAR COLUNAS user_id ONDE NÃO EXISTEM
-- Para produtos
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE produtos ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela produtos';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela produtos';
    END IF;
END $$;

-- Para clientes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE clientes ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela clientes';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela clientes';
    END IF;
END $$;

-- Para vendas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendas' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE vendas ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela vendas';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela vendas';
    END IF;
END $$;

-- Para vendas_itens
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendas_itens' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE vendas_itens ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela vendas_itens';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela vendas_itens';
    END IF;
END $$;

-- Para caixa
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE caixa ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela caixa';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela caixa';
    END IF;
END $$;

-- Para movimentacoes_caixa
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'movimentacoes_caixa' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE movimentacoes_caixa ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela movimentacoes_caixa';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela movimentacoes_caixa';
    END IF;
END $$;

-- Para ordens_servico
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE ordens_servico ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela ordens_servico';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela ordens_servico';
    END IF;
END $$;

-- 4. POPULAR DADOS EXISTENTES COM O USUÁRIO ATUAL (SE HOUVER DADOS)
-- ATENÇÃO: Isso vai atribuir TODOS os dados existentes ao usuário que executar o script!
UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE vendas_itens SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE movimentacoes_caixa SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;
UPDATE ordens_servico SET user_id = auth.uid() WHERE user_id IS NULL AND auth.uid() IS NOT NULL;

-- 5. REATIVAR RLS EM TODAS AS TABELAS CRÍTICAS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS RLS PARA CADA TABELA
-- Políticas para produtos
DROP POLICY IF EXISTS "Usuários podem ver seus produtos" ON produtos;
CREATE POLICY "Usuários podem ver seus produtos" ON produtos
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar produtos" ON produtos;
CREATE POLICY "Usuários podem criar produtos" ON produtos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus produtos" ON produtos;
CREATE POLICY "Usuários podem atualizar seus produtos" ON produtos
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem excluir seus produtos" ON produtos;
CREATE POLICY "Usuários podem excluir seus produtos" ON produtos
    FOR DELETE USING (auth.uid() = user_id);

-- Políticas para clientes
DROP POLICY IF EXISTS "Usuários podem ver seus clientes" ON clientes;
CREATE POLICY "Usuários podem ver seus clientes" ON clientes
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar clientes" ON clientes;
CREATE POLICY "Usuários podem criar clientes" ON clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus clientes" ON clientes;
CREATE POLICY "Usuários podem atualizar seus clientes" ON clientes
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem excluir seus clientes" ON clientes;
CREATE POLICY "Usuários podem excluir seus clientes" ON clientes
    FOR DELETE USING (auth.uid() = user_id);

-- Políticas para vendas
DROP POLICY IF EXISTS "Usuários podem ver suas vendas" ON vendas;
CREATE POLICY "Usuários podem ver suas vendas" ON vendas
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar vendas" ON vendas;
CREATE POLICY "Usuários podem criar vendas" ON vendas
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar suas vendas" ON vendas;
CREATE POLICY "Usuários podem atualizar suas vendas" ON vendas
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para vendas_itens
DROP POLICY IF EXISTS "Usuários podem ver itens de suas vendas" ON vendas_itens;
CREATE POLICY "Usuários podem ver itens de suas vendas" ON vendas_itens
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar itens de venda" ON vendas_itens;
CREATE POLICY "Usuários podem criar itens de venda" ON vendas_itens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar itens de suas vendas" ON vendas_itens;
CREATE POLICY "Usuários podem atualizar itens de suas vendas" ON vendas_itens
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para caixa
DROP POLICY IF EXISTS "Usuários podem ver seus caixas" ON caixa;
CREATE POLICY "Usuários podem ver seus caixas" ON caixa
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar caixas" ON caixa;
CREATE POLICY "Usuários podem criar caixas" ON caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus caixas" ON caixa;
CREATE POLICY "Usuários podem atualizar seus caixas" ON caixa
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para movimentacoes_caixa
DROP POLICY IF EXISTS "Usuários podem ver movimentações de seus caixas" ON movimentacoes_caixa;
CREATE POLICY "Usuários podem ver movimentações de seus caixas" ON movimentacoes_caixa
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON movimentacoes_caixa;
CREATE POLICY "Usuários podem criar movimentações" ON movimentacoes_caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para ordens_servico
DROP POLICY IF EXISTS "Usuários podem ver suas ordens" ON ordens_servico;
CREATE POLICY "Usuários podem ver suas ordens" ON ordens_servico
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar ordens" ON ordens_servico;
CREATE POLICY "Usuários podem criar ordens" ON ordens_servico
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar suas ordens" ON ordens_servico;
CREATE POLICY "Usuários podem atualizar suas ordens" ON ordens_servico
    FOR UPDATE USING (auth.uid() = user_id);

-- 7. CRIAR TRIGGERS PARA AUTO-POPULAR user_id EM NOVOS REGISTROS
-- Função para popular user_id automaticamente
CREATE OR REPLACE FUNCTION set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers para cada tabela
DROP TRIGGER IF EXISTS set_user_id_produtos ON produtos;
CREATE TRIGGER set_user_id_produtos
    BEFORE INSERT ON produtos
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_clientes ON clientes;
CREATE TRIGGER set_user_id_clientes
    BEFORE INSERT ON clientes
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_vendas ON vendas;
CREATE TRIGGER set_user_id_vendas
    BEFORE INSERT ON vendas
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_vendas_itens ON vendas_itens;
CREATE TRIGGER set_user_id_vendas_itens
    BEFORE INSERT ON vendas_itens
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_caixa ON caixa;
CREATE TRIGGER set_user_id_caixa
    BEFORE INSERT ON caixa
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_movimentacoes ON movimentacoes_caixa;
CREATE TRIGGER set_user_id_movimentacoes
    BEFORE INSERT ON movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

DROP TRIGGER IF EXISTS set_user_id_ordens ON ordens_servico;
CREATE TRIGGER set_user_id_ordens
    BEFORE INSERT ON ordens_servico
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

-- 8. VERIFICAÇÃO FINAL
SELECT 
    '✅ VERIFICAÇÃO FINAL' as info,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ RLS ATIVO' ELSE '❌ RLS INATIVO' END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename;

SELECT '🎉 CORREÇÃO CONCLUÍDA - VAZAMENTO CORRIGIDO!' as resultado;