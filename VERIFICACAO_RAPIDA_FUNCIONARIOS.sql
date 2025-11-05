-- ===== VERIFICAÇÃO RÁPIDA DO SISTEMA DE FUNCIONÁRIOS =====

-- 1. Verificar tabelas essenciais
DO $$
BEGIN
    RAISE NOTICE '🔍 === VERIFICAÇÃO RÁPIDA ===';
    
    -- Funcionários
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionarios') THEN
        RAISE NOTICE '✅ Tabela funcionarios existe';
        EXECUTE 'SELECT COUNT(*) FROM funcionarios WHERE status = ''ativo''' INTO @count;
        RAISE NOTICE '👥 Funcionários ativos: %', @count;
    ELSE
        RAISE NOTICE '❌ Tabela funcionarios NÃO existe';
    END IF;
    
    -- Empresas
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'empresas') THEN
        RAISE NOTICE '✅ Tabela empresas existe';
        EXECUTE 'SELECT COUNT(*) FROM empresas' INTO @count;
        RAISE NOTICE '🏢 Empresas: %', @count;
    ELSE
        RAISE NOTICE '❌ Tabela empresas NÃO existe';
    END IF;
    
    -- RPC listar_usuarios_ativos
    IF EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') THEN
        RAISE NOTICE '✅ Função listar_usuarios_ativos existe';
    ELSE
        RAISE NOTICE '❌ Função listar_usuarios_ativos NÃO existe';
    END IF;
    
END $$;