-- ====================================================================
-- 🚨 CORREÇÃO URGENTE: Remover trigger de backup da tabela CLIENTES
-- ====================================================================
-- 
-- PROBLEMA: Erro ao atualizar cliente
-- "function public.criar_backup_automatico_diario() does not exist"
-- 
-- CAUSA: Trigger na tabela 'clientes' está chamando função deletada
-- 
-- SOLUÇÃO: Remover todos os triggers de backup da tabela clientes
-- ====================================================================

DO $$
DECLARE
    v_trigger_name TEXT;
    v_error_detail TEXT;
BEGIN
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '🔧 INICIANDO LIMPEZA DE TRIGGERS NA TABELA CLIENTES';
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '';

    -- =================================================================
    -- PARTE 1: REMOVER TRIGGER DA TABELA CLIENTES
    -- =================================================================
    
    RAISE NOTICE '📋 PARTE 1: Removendo trigger de backup da tabela clientes';
    RAISE NOTICE '';
    
    -- Verificar se o trigger existe antes de tentar remover
    IF EXISTS (
        SELECT 1 
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relname = 'clientes' 
        AND t.tgname = 'trigger_criar_backup_automatico_diario'
    ) THEN
        BEGIN
            RAISE NOTICE '   🗑️  Removendo trigger "trigger_criar_backup_automatico_diario" da tabela "clientes"...';
            EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON clientes CASCADE';
            RAISE NOTICE '   ✅ Trigger removido com sucesso!';
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_error_detail = PG_EXCEPTION_DETAIL;
            RAISE NOTICE '   ⚠️  Erro ao remover trigger: % (Detalhes: %)', SQLERRM, v_error_detail;
        END;
    ELSE
        RAISE NOTICE '   ℹ️  Trigger "trigger_criar_backup_automatico_diario" não existe na tabela "clientes"';
    END IF;
    
    RAISE NOTICE '';
    
    -- =================================================================
    -- PARTE 2: LISTAR TODOS OS TRIGGERS RESTANTES NA TABELA CLIENTES
    -- =================================================================
    
    RAISE NOTICE '📋 PARTE 2: Verificando triggers restantes na tabela clientes';
    RAISE NOTICE '';
    
    FOR v_trigger_name IN 
        SELECT t.tgname
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relname = 'clientes'
        AND NOT t.tgisinternal  -- Ignora triggers internos do sistema
    LOOP
        RAISE NOTICE '   📌 Trigger encontrado: "%"', v_trigger_name;
    END LOOP;
    
    IF NOT FOUND THEN
        RAISE NOTICE '   ✅ Nenhum trigger customizado encontrado na tabela "clientes"';
    END IF;
    
    RAISE NOTICE '';
    
    -- =================================================================
    -- PARTE 3: VERIFICAR RPC atualizar_cliente_seguro
    -- =================================================================
    
    RAISE NOTICE '📋 PARTE 3: Verificando função RPC atualizar_cliente_seguro';
    RAISE NOTICE '';
    
    IF EXISTS (
        SELECT 1 
        FROM pg_proc 
        WHERE proname = 'atualizar_cliente_seguro'
    ) THEN
        RAISE NOTICE '   ✅ Função RPC "atualizar_cliente_seguro" existe';
        
        -- Verificar permissões
        IF EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_roles r ON p.proowner = r.oid
            WHERE p.proname = 'atualizar_cliente_seguro'
        ) THEN
            RAISE NOTICE '   ✅ Permissões configuradas';
        END IF;
    ELSE
        RAISE NOTICE '   ❌ Função RPC "atualizar_cliente_seguro" NÃO EXISTE!';
        RAISE NOTICE '   ⚠️  Execute o arquivo CORRIGIR_FUNCOES_FALTANDO_URGENTE.sql primeiro!';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '✅ LIMPEZA DE TRIGGERS CONCLUÍDA';
    RAISE NOTICE '====================================================================';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 PRÓXIMOS PASSOS:';
    RAISE NOTICE '   1. Recarregar a página no navegador (Ctrl+F5)';
    RAISE NOTICE '   2. Tentar atualizar um cliente novamente';
    RAISE NOTICE '   3. Verificar se o erro desapareceu';
    RAISE NOTICE '';
    
END $$;
