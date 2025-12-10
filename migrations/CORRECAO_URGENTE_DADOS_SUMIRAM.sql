-- =============================================
-- CORREÇÃO URGENTE: DADOS SUMIRAM APÓS DEPLOY
-- =============================================
-- Problema: Políticas RLS bloqueando tudo porque empresa_id está NULL

-- =====================================
-- PASSO 1: DESABILITAR RLS TEMPORARIAMENTE
-- =====================================

ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes_impressao DISABLE ROW LEVEL SECURITY;

-- =====================================
-- PASSO 2: VERIFICAR DADOS EXISTENTES
-- =====================================

-- Verificar quantos registros existem sem empresa_id
SELECT 'clientes' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM clientes
UNION ALL
SELECT 'produtos' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM produtos
UNION ALL
SELECT 'vendas' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM vendas
UNION ALL
SELECT 'caixa' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM caixa
UNION ALL
SELECT 'ordens_servico' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM ordens_servico;

-- =====================================
-- PASSO 3: PREENCHER empresa_id NOS REGISTROS EXISTENTES
-- =====================================

DO $$
DECLARE
    v_empresa_id uuid;
    v_user_id uuid;
    v_count_clientes int;
    v_count_produtos int;
    v_count_vendas int;
    v_count_caixa int;
    v_count_ordens int;
BEGIN
    -- Buscar o primeiro usuário do sistema
    SELECT id INTO v_user_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION '❌ Nenhum usuário encontrado!';
    END IF;
    
    RAISE NOTICE '✅ Usuário encontrado: %', v_user_id;
    
    -- Buscar ou criar empresa para esse usuário
    SELECT id INTO v_empresa_id FROM empresas WHERE user_id = v_user_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE NOTICE '⚠️  Criando empresa para o usuário...';
        
        INSERT INTO empresas (user_id, nome, email)
        SELECT 
            v_user_id,
            COALESCE(raw_user_meta_data->>'nome', 'Minha Empresa'),
            email
        FROM auth.users WHERE id = v_user_id
        RETURNING id INTO v_empresa_id;
        
        RAISE NOTICE '✅ Empresa criada: %', v_empresa_id;
    ELSE
        RAISE NOTICE '✅ Empresa encontrada: %', v_empresa_id;
    END IF;
    
    -- Atualizar todos os registros NULL com empresa_id
    UPDATE clientes SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    GET DIAGNOSTICS v_count_clientes = ROW_COUNT;
    RAISE NOTICE '✅ % clientes atualizados', v_count_clientes;
    
    UPDATE produtos SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    GET DIAGNOSTICS v_count_produtos = ROW_COUNT;
    RAISE NOTICE '✅ % produtos atualizados', v_count_produtos;
    
    UPDATE vendas SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    GET DIAGNOSTICS v_count_vendas = ROW_COUNT;
    RAISE NOTICE '✅ % vendas atualizadas', v_count_vendas;
    
    UPDATE caixa SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    GET DIAGNOSTICS v_count_caixa = ROW_COUNT;
    RAISE NOTICE '✅ % registros de caixa atualizados', v_count_caixa;
    
    UPDATE ordens_servico SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    GET DIAGNOSTICS v_count_ordens = ROW_COUNT;
    RAISE NOTICE '✅ % ordens de serviço atualizadas', v_count_ordens;
    
    UPDATE configuracoes_impressao SET empresa_id = v_empresa_id WHERE empresa_id IS NULL;
    RAISE NOTICE '✅ Configurações de impressão atualizadas';
    
    RAISE NOTICE '🎉 TODOS OS DADOS RECUPERADOS!';
    
END $$;

-- =====================================
-- PASSO 4: REATIVAR RLS (após correção)
-- =====================================

ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- =====================================
-- VERIFICAÇÃO FINAL
-- =====================================

SELECT 'clientes' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM clientes
UNION ALL
SELECT 'produtos' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM produtos
UNION ALL
SELECT 'vendas' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM vendas
UNION ALL
SELECT 'caixa' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM caixa
UNION ALL
SELECT 'ordens_servico' as tabela, COUNT(*) as total, COUNT(empresa_id) as com_empresa_id FROM ordens_servico;

-- =====================================
-- ✅ DADOS RECUPERADOS!
-- =====================================

SELECT '🎉 CORREÇÃO CONCLUÍDA! Todos os dados devem estar visíveis agora!' as resultado;
