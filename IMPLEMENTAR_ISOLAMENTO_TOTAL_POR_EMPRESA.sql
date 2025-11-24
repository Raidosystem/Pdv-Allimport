-- =============================================
-- IMPLEMENTAR ISOLAMENTO TOTAL POR EMPRESA
-- Sistema Multi-tenant: Cada usuário vê apenas seus dados
-- =============================================

-- =====================================
-- PARTE 1: FUNÇÃO PARA OBTER EMPRESA_ID DO USUÁRIO
-- =====================================

CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT id FROM empresas WHERE user_id = auth.uid() LIMIT 1;
$$;

-- =====================================
-- PARTE 2: VERIFICAR E ADICIONAR COLUNA empresa_id EM TODAS AS TABELAS
-- =====================================

-- Adicionar empresa_id em clientes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE clientes ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela clientes';
    END IF;
END $$;

-- Adicionar empresa_id em produtos
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE produtos ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela produtos';
    END IF;
END $$;

-- NOTA: sales é uma VIEW, não uma tabela - não precisa de empresa_id

-- Adicionar empresa_id em caixa
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'caixa' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE caixa ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela caixa';
    END IF;
END $$;

-- Adicionar empresa_id em vendas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela vendas';
    END IF;
END $$;

-- Adicionar empresa_id em ordens_servico
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ordens_servico' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE ordens_servico ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela ordens_servico';
    END IF;
END $$;

-- Adicionar empresa_id em configuracoes_impressao
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'configuracoes_impressao' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE configuracoes_impressao ADD COLUMN empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE;
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela configuracoes_impressao';
    END IF;
END $$;

-- =====================================
-- PARTE 3: CRIAR TRIGGERS PARA AUTO-PREENCHER empresa_id
-- =====================================

-- Função genérica para auto-preencher empresa_id
CREATE OR REPLACE FUNCTION set_empresa_id_from_user()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.empresa_id IS NULL THEN
        NEW.empresa_id := get_user_empresa_id();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para clientes
DROP TRIGGER IF EXISTS set_empresa_id_clientes ON clientes;
CREATE TRIGGER set_empresa_id_clientes
    BEFORE INSERT ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- Trigger para produtos
DROP TRIGGER IF EXISTS set_empresa_id_produtos ON produtos;
CREATE TRIGGER set_empresa_id_produtos
    BEFORE INSERT ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- NOTA: sales é uma VIEW - não precisa de trigger

-- Trigger para caixa
DROP TRIGGER IF EXISTS set_empresa_id_caixa ON caixa;
CREATE TRIGGER set_empresa_id_caixa
    BEFORE INSERT ON caixa
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- Trigger para vendas
DROP TRIGGER IF EXISTS set_empresa_id_vendas ON vendas;
CREATE TRIGGER set_empresa_id_vendas
    BEFORE INSERT ON vendas
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- Trigger para ordens_servico
DROP TRIGGER IF EXISTS set_empresa_id_ordens ON ordens_servico;
CREATE TRIGGER set_empresa_id_ordens
    BEFORE INSERT ON ordens_servico
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- Trigger para configuracoes_impressao
DROP TRIGGER IF EXISTS set_empresa_id_config ON configuracoes_impressao;
CREATE TRIGGER set_empresa_id_config
    BEFORE INSERT ON configuracoes_impressao
    FOR EACH ROW
    EXECUTE FUNCTION set_empresa_id_from_user();

-- =====================================
-- PARTE 4: CRIAR POLÍTICAS RLS PARA ISOLAMENTO TOTAL
-- =====================================

-- ===== CLIENTES =====
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only see their own clientes" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;

CREATE POLICY "clientes_empresa_isolation" ON clientes
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- ===== PRODUTOS =====
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "produtos_select_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_update_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_policy" ON produtos;

CREATE POLICY "produtos_empresa_isolation" ON produtos
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- NOTA: sales é uma VIEW - o isolamento virá da tabela vendas subjacente

-- ===== CAIXA =====
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "caixa_select_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_insert_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_update_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_delete_policy" ON caixa;

CREATE POLICY "caixa_empresa_isolation" ON caixa
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- ===== VENDAS =====
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "vendas_select_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_update_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_delete_policy" ON vendas;

CREATE POLICY "vendas_empresa_isolation" ON vendas
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- ===== ORDENS_SERVICO =====
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ordens_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_insert_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_update_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_delete_policy" ON ordens_servico;

CREATE POLICY "ordens_servico_empresa_isolation" ON ordens_servico
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- ===== CONFIGURACOES_IMPRESSAO =====
ALTER TABLE configuracoes_impressao ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "config_select_policy" ON configuracoes_impressao;
DROP POLICY IF EXISTS "config_insert_policy" ON configuracoes_impressao;
DROP POLICY IF EXISTS "config_update_policy" ON configuracoes_impressao;
DROP POLICY IF EXISTS "config_delete_policy" ON configuracoes_impressao;

CREATE POLICY "configuracoes_impressao_empresa_isolation" ON configuracoes_impressao
    FOR ALL
    USING (empresa_id = get_user_empresa_id())
    WITH CHECK (empresa_id = get_user_empresa_id());

-- =====================================
-- PARTE 5: CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================

CREATE INDEX IF NOT EXISTS idx_clientes_empresa_id ON clientes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_produtos_empresa_id ON produtos(empresa_id);
-- NOTA: sales é uma VIEW - não precisa de índice
CREATE INDEX IF NOT EXISTS idx_vendas_empresa_id ON vendas(empresa_id);
CREATE INDEX IF NOT EXISTS idx_caixa_empresa_id ON caixa(empresa_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_empresa_id ON ordens_servico(empresa_id);
CREATE INDEX IF NOT EXISTS idx_configuracoes_impressao_empresa_id ON configuracoes_impressao(empresa_id);

-- =====================================
-- PARTE 6: ATUALIZAR REGISTROS EXISTENTES COM empresa_id
-- =====================================

-- IMPORTANTE: Este passo atualiza os registros existentes.
-- Vamos buscar o primeiro usuário real do sistema e atualizar todos os registros
-- para a empresa dele.

-- ATENÇÃO: Execute este bloco enquanto estiver logado no sistema!
DO $$
DECLARE
    v_empresa_id uuid;
    v_user_id uuid;
BEGIN
    -- Buscar o primeiro usuário autenticado no sistema
    SELECT id INTO v_user_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION '❌ Nenhum usuário encontrado no sistema! Crie um usuário primeiro.';
    END IF;
    
    RAISE NOTICE '📌 Usuário encontrado: %', v_user_id;
    
    -- Buscar empresa_id desse usuário
    SELECT id INTO v_empresa_id FROM empresas WHERE user_id = v_user_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE NOTICE '⚠️  Empresa não encontrada para user_id: %', v_user_id;
        RAISE NOTICE '⚠️  Criando empresa automaticamente...';
        
        -- Criar empresa se não existir
        INSERT INTO empresas (user_id, nome, cnpj, telefone, email)
        SELECT 
            v_user_id,
            COALESCE(raw_user_meta_data->>'nome', 'Minha Empresa'),
            NULL,
            NULL,
            email
        FROM auth.users WHERE id = v_user_id
        RETURNING id INTO v_empresa_id;
        
        RAISE NOTICE '✅ Empresa criada com ID: %', v_empresa_id;
    ELSE
        RAISE NOTICE '✅ Empresa já existe com ID: %', v_empresa_id;
    END IF;
    
    -- Atualizar clientes
    UPDATE clientes SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Clientes atualizados com empresa_id';
    
    -- Atualizar produtos
    UPDATE produtos SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Produtos atualizados com empresa_id';
    
    -- NOTA: sales é uma VIEW - não precisa de update
    
    -- Atualizar vendas
    UPDATE vendas SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Vendas atualizadas com empresa_id';
    
    -- Atualizar caixa
    UPDATE caixa SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Caixa atualizada com empresa_id';
    
    -- Atualizar ordens_servico
    UPDATE ordens_servico SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Ordens de serviço atualizadas com empresa_id';
    
    -- Atualizar configuracoes_impressao
    UPDATE configuracoes_impressao SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Configurações de impressão atualizadas com empresa_id';
    
END $$;

-- =====================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- =====================================

-- Verificar políticas criadas
SELECT 
    tablename,
    policyname,
    cmd,
    CASE 
        WHEN qual LIKE '%empresa_id%' OR with_check LIKE '%empresa_id%' THEN '✅ Com isolamento'
        ELSE '⚠️  Sem isolamento'
    END as status_isolamento
FROM pg_policies
WHERE tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'ordens_servico', 'configuracoes_impressao')
ORDER BY tablename, policyname;

-- Verificar se todos os registros têm empresa_id
SELECT 
    'clientes' as tabela,
    COUNT(*) as total,
    COUNT(empresa_id) as com_empresa_id,
    COUNT(*) - COUNT(empresa_id) as sem_empresa_id
FROM clientes
UNION ALL
SELECT 
    'produtos' as tabela,
    COUNT(*) as total,
    COUNT(empresa_id) as com_empresa_id,
    COUNT(*) - COUNT(empresa_id) as sem_empresa_id
FROM produtos
UNION ALL
SELECT 
    'vendas' as tabela,
    COUNT(*) as total,
    COUNT(empresa_id) as com_empresa_id,
    COUNT(*) - COUNT(empresa_id) as sem_empresa_id
FROM vendas
UNION ALL
SELECT 
    'caixa' as tabela,
    COUNT(*) as total,
    COUNT(empresa_id) as com_empresa_id,
    COUNT(*) - COUNT(empresa_id) as sem_empresa_id
FROM caixa
UNION ALL
SELECT 
    'ordens_servico' as tabela,
    COUNT(*) as total,
    COUNT(empresa_id) as com_empresa_id,
    COUNT(*) - COUNT(empresa_id) as sem_empresa_id
FROM ordens_servico;

-- =====================================
-- ✅ ISOLAMENTO TOTAL IMPLEMENTADO!
-- =====================================

SELECT '🎉 SISTEMA DE ISOLAMENTO POR EMPRESA IMPLEMENTADO COM SUCESSO!' as resultado;
SELECT '🔒 Cada usuário agora vê apenas seus próprios dados!' as resultado;
SELECT '✅ Clientes, Produtos, Vendas, Caixas, Ordens de Serviço isolados!' as resultado;
