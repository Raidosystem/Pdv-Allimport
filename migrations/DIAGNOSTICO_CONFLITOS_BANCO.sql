-- ===== DIAGNÓSTICO DE CONFLITOS NO BANCO DE DADOS =====
-- Este script identifica e resolve conflitos entre tabelas

-- 1. VERIFICAR TABELAS EXISTENTES
DO $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE '🔍 === DIAGNÓSTICO COMPLETO DO BANCO ===';
    RAISE NOTICE '';
    
    RAISE NOTICE '📋 TABELAS EXISTENTES:';
    FOR table_record IN 
        SELECT table_name, table_schema 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        RAISE NOTICE '  ✓ %', table_record.table_name;
    END LOOP;
    
    RAISE NOTICE '';
END $$;

-- 2. VERIFICAR COLUNAS E CONFLITOS
DO $$
DECLARE
    table_name text;
    column_info RECORD;
BEGIN
    RAISE NOTICE '🔧 VERIFICANDO ESTRUTURAS:';
    
    -- Verificar cada tabela crítica
    FOREACH table_name IN ARRAY ARRAY['customers', 'products', 'sales', 'sale_items', 'service_orders', 
                                      'clientes', 'produtos', 'vendas', 'itens_venda', 'ordens_servico']
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = table_name) THEN
            RAISE NOTICE '';
            RAISE NOTICE '📊 Tabela: %', table_name;
            
            FOR column_info IN
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name = table_name
                ORDER BY ordinal_position
            LOOP
                RAISE NOTICE '  📝 % (%, nullable: %)', 
                    column_info.column_name, 
                    column_info.data_type,
                    column_info.is_nullable;
            END LOOP;
        END IF;
    END LOOP;
END $$;

-- 3. VERIFICAR RELACIONAMENTOS E FOREIGN KEYS
DO $$
DECLARE
    fk_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔗 FOREIGN KEYS EXISTENTES:';
    
    FOR fk_record IN
        SELECT 
            tc.table_name,
            kcu.column_name,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name,
            tc.constraint_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu 
            ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage ccu 
            ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY'
        ORDER BY tc.table_name, kcu.column_name
    LOOP
        RAISE NOTICE '  🔗 %.% → %.%', 
            fk_record.table_name,
            fk_record.column_name,
            fk_record.foreign_table_name,
            fk_record.foreign_column_name;
    END LOOP;
END $$;

-- 4. IDENTIFICAR CONFLITOS DE NOMENCLATURA
DO $$
DECLARE
    conflito_encontrado boolean := false;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IDENTIFICANDO CONFLITOS:';
    
    -- Verificar tabelas duplicadas (português vs inglês)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'customers') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        RAISE NOTICE '  ❌ CONFLITO: Tabelas "customers" E "clientes" existem';
        conflito_encontrado := true;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        RAISE NOTICE '  ❌ CONFLITO: Tabelas "products" E "produtos" existem';
        conflito_encontrado := true;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vendas') THEN
        RAISE NOTICE '  ❌ CONFLITO: Tabelas "sales" E "vendas" existem';
        conflito_encontrado := true;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'service_orders') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN
        RAISE NOTICE '  ❌ CONFLITO: Tabelas "service_orders" E "ordens_servico" existem';
        conflito_encontrado := true;
    END IF;
    
    IF NOT conflito_encontrado THEN
        RAISE NOTICE '  ✅ Nenhum conflito de nomenclatura encontrado';
    END IF;
END $$;

-- 5. VERIFICAR RLS E POLÍTICAS
DO $$
DECLARE
    table_name text;
    policy_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔒 VERIFICANDO RLS E POLÍTICAS:';
    
    FOREACH table_name IN ARRAY ARRAY['customers', 'products', 'sales', 'sale_items', 'service_orders']
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = table_name) THEN
            -- Verificar se RLS está habilitado
            IF EXISTS (
                SELECT 1 FROM pg_class 
                WHERE relname = table_name 
                AND relrowsecurity = true
            ) THEN
                RAISE NOTICE '  🔒 % - RLS ATIVO', table_name;
                
                -- Listar políticas
                FOR policy_record IN
                    SELECT policyname, permissive, roles, cmd, qual
                    FROM pg_policies
                    WHERE tablename = table_name
                LOOP
                    RAISE NOTICE '    📋 Política: %', policy_record.policyname;
                END LOOP;
            ELSE
                RAISE NOTICE '  ⚠️  % - RLS INATIVO', table_name;
            END IF;
        END IF;
    END LOOP;
END $$;

-- 6. CONTAR REGISTROS
DO $$
DECLARE
    table_name text;
    record_count integer;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 CONTAGEM DE REGISTROS:';
    
    FOREACH table_name IN ARRAY ARRAY['customers', 'products', 'sales', 'sale_items', 'service_orders']
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = table_name) THEN
            EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO record_count;
            RAISE NOTICE '  📈 % registros em %', record_count, table_name;
        END IF;
    END LOOP;
END $$;

RAISE NOTICE '';
RAISE NOTICE '🎯 === DIAGNÓSTICO CONCLUÍDO ===';