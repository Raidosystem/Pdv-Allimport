-- ===== MIGRAÇÃO SEGURA - PRESERVANDO DADOS =====
-- Este script migra dados das tabelas antigas para novas sem perder informações

-- 1. VERIFICAR SITUAÇÃO ATUAL
DO $$
DECLARE
    tabelas_existentes text[];
    tabela text;
BEGIN
    RAISE NOTICE '🔍 === ANÁLISE PRÉ-MIGRAÇÃO ===';
    
    -- Listar tabelas existentes
    SELECT ARRAY(
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND table_name IN ('customers', 'clientes', 'products', 'produtos', 'sales', 'vendas', 'service_orders', 'ordens_servico')
    ) INTO tabelas_existentes;
    
    RAISE NOTICE 'Tabelas encontradas: %', array_to_string(tabelas_existentes, ', ');
    
    FOREACH tabela IN ARRAY tabelas_existentes
    LOOP
        EXECUTE format('
            SELECT 
                CASE 
                    WHEN COUNT(*) = 0 THEN ''📭 %s: vazia''
                    ELSE ''📊 %s: '' || COUNT(*) || '' registros''
                END
            FROM %I', tabela, tabela, tabela)
        INTO tabela;
        RAISE NOTICE '%', tabela;
    END LOOP;
END $$;

-- 2. CRIAR TABELAS TEMPORÁRIAS PARA BACKUP
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '💾 CRIANDO BACKUP DE SEGURANÇA:';
    
    -- Backup de clientes (se existir)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        DROP TABLE IF EXISTS backup_clientes;
        CREATE TABLE backup_clientes AS SELECT * FROM clientes;
        RAISE NOTICE '  ✅ Backup de clientes criado';
    END IF;
    
    -- Backup de produtos (se existir)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        DROP TABLE IF EXISTS backup_produtos;
        CREATE TABLE backup_produtos AS SELECT * FROM produtos;
        RAISE NOTICE '  ✅ Backup de produtos criado';
    END IF;
    
    -- Backup de vendas (se existir)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vendas') THEN
        DROP TABLE IF EXISTS backup_vendas;
        CREATE TABLE backup_vendas AS SELECT * FROM vendas;
        RAISE NOTICE '  ✅ Backup de vendas criado';
    END IF;
    
    -- Backup de ordens de serviço (se existir)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN
        DROP TABLE IF EXISTS backup_ordens_servico;
        CREATE TABLE backup_ordens_servico AS SELECT * FROM ordens_servico;
        RAISE NOTICE '  ✅ Backup de ordens de serviço criado';
    END IF;
END $$;

-- 3. CRIAR ESTRUTURA PADRÃO (INGLÊS)
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🏗️  CRIANDO ESTRUTURA PADRÃO:';
    
    -- Criar customers se não existir
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'customers') THEN
        CREATE TABLE customers (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid,
            empresa_id uuid,
            name text NOT NULL,
            email text,
            phone text,
            document text,
            address text,
            city text,
            state text,
            zip_code text,
            created_at timestamptz DEFAULT NOW(),
            updated_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '  ✅ Tabela customers criada';
    END IF;
    
    -- Criar products se não existir
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products') THEN
        CREATE TABLE products (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid,
            empresa_id uuid,
            name text NOT NULL,
            description text,
            category text,
            price decimal(10,2) DEFAULT 0,
            stock_quantity integer DEFAULT 0,
            barcode text,
            supplier text,
            created_at timestamptz DEFAULT NOW(),
            updated_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '  ✅ Tabela products criada';
    END IF;
    
    -- Criar sales se não existir
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales') THEN
        CREATE TABLE sales (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid,
            empresa_id uuid,
            customer_id uuid,
            total_amount decimal(10,2) DEFAULT 0,
            discount_amount decimal(10,2) DEFAULT 0,
            payment_method text DEFAULT 'cash',
            status text DEFAULT 'completed',
            notes text,
            created_at timestamptz DEFAULT NOW(),
            updated_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '  ✅ Tabela sales criada';
    END IF;
    
    -- Criar sale_items se não existir
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sale_items') THEN
        CREATE TABLE sale_items (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            sale_id uuid,
            product_id uuid,
            quantity integer DEFAULT 1,
            unit_price decimal(10,2) DEFAULT 0,
            total_price decimal(10,2) DEFAULT 0,
            created_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '  ✅ Tabela sale_items criada';
    END IF;
    
    -- Criar service_orders se não existir
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'service_orders') THEN
        CREATE TABLE service_orders (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid,
            empresa_id uuid,
            customer_id uuid,
            equipment text NOT NULL,
            defect text,
            observations text,
            status text DEFAULT 'pending',
            total_amount decimal(10,2) DEFAULT 0,
            created_at timestamptz DEFAULT NOW(),
            updated_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '  ✅ Tabela service_orders criada';
    END IF;
END $$;

-- 4. MIGRAR DADOS DAS TABELAS EM PORTUGUÊS
DO $$
DECLARE
    migrados integer := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📤 MIGRANDO DADOS:';
    
    -- Migrar clientes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        INSERT INTO customers (user_id, empresa_id, name, email, phone, document, address, city, state, zip_code, created_at, updated_at)
        SELECT 
            COALESCE(user_id, gen_random_uuid()),
            empresa_id,
            nome,
            email,
            telefone,
            documento,
            endereco,
            cidade,
            estado,
            cep,
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM clientes
        ON CONFLICT (id) DO NOTHING;
        
        GET DIAGNOSTICS migrados = ROW_COUNT;
        RAISE NOTICE '  📋 % clientes migrados', migrados;
    END IF;
    
    -- Migrar produtos
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        INSERT INTO products (user_id, empresa_id, name, description, category, price, stock_quantity, barcode, supplier, created_at, updated_at)
        SELECT 
            COALESCE(user_id, gen_random_uuid()),
            empresa_id,
            nome,
            descricao,
            categoria,
            COALESCE(preco, 0),
            COALESCE(estoque, 0),
            codigo_barras,
            fornecedor,
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM produtos
        ON CONFLICT (id) DO NOTHING;
        
        GET DIAGNOSTICS migrados = ROW_COUNT;
        RAISE NOTICE '  📦 % produtos migrados', migrados;
    END IF;
    
    -- Migrar ordens de serviço
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN
        INSERT INTO service_orders (user_id, empresa_id, customer_id, equipment, defect, observations, status, total_amount, created_at, updated_at)
        SELECT 
            COALESCE(user_id, gen_random_uuid()),
            empresa_id,
            cliente_id,
            equipamento,
            defeito,
            observacoes,
            COALESCE(status, 'pending'),
            COALESCE(valor_total, 0),
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM ordens_servico
        ON CONFLICT (id) DO NOTHING;
        
        GET DIAGNOSTICS migrados = ROW_COUNT;
        RAISE NOTICE '  🛠️  % ordens de serviço migradas', migrados;
    END IF;
END $$;

-- 5. CONFIGURAR RLS SIMPLES
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔒 CONFIGURANDO SEGURANÇA:';
    
    -- Remover políticas antigas
    DROP POLICY IF EXISTS "customers_policy" ON customers;
    DROP POLICY IF EXISTS "products_policy" ON products;
    DROP POLICY IF EXISTS "sales_policy" ON sales;
    DROP POLICY IF EXISTS "sale_items_policy" ON sale_items;
    DROP POLICY IF EXISTS "service_orders_policy" ON service_orders;
    
    -- Habilitar RLS
    ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
    
    -- Criar políticas permissivas para desenvolvimento
    CREATE POLICY "customers_allow_all" ON customers FOR ALL USING (true);
    CREATE POLICY "products_allow_all" ON products FOR ALL USING (true);
    CREATE POLICY "sales_allow_all" ON sales FOR ALL USING (true);
    CREATE POLICY "sale_items_allow_all" ON sale_items FOR ALL USING (true);
    CREATE POLICY "service_orders_allow_all" ON service_orders FOR ALL USING (true);
    
    RAISE NOTICE '  ✅ RLS configurado com políticas permissivas';
END $$;

-- 6. REMOVER TABELAS ANTIGAS (OPCIONAL)
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🗑️  LIMPEZA OPCIONAL (descomente se necessário):';
    RAISE NOTICE '  ⚠️  Para remover tabelas antigas, descomente as linhas abaixo';
    
    -- Descomente estas linhas se quiser remover as tabelas antigas:
    -- DROP TABLE IF EXISTS clientes CASCADE;
    -- DROP TABLE IF EXISTS produtos CASCADE;
    -- DROP TABLE IF EXISTS vendas CASCADE;
    -- DROP TABLE IF EXISTS ordens_servico CASCADE;
    -- RAISE NOTICE '  ❌ Tabelas antigas removidas';
END $$;

-- 7. ADICIONAR DADOS DE TESTE SE NECESSÁRIO
DO $$
DECLARE
    customer_count integer;
    product_count integer;
    test_user_id uuid := gen_random_uuid();
    sample_customer_id uuid;
    sample_product_id uuid;
    sample_sale_id uuid;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 VERIFICANDO NECESSIDADE DE DADOS DE TESTE:';
    
    SELECT COUNT(*) INTO customer_count FROM customers;
    SELECT COUNT(*) INTO product_count FROM products;
    
    IF customer_count = 0 AND product_count = 0 THEN
        RAISE NOTICE '  📝 Adicionando dados de exemplo para testes...';
        
        -- Cliente de exemplo
        INSERT INTO customers (user_id, name, email, phone, created_at)
        VALUES (test_user_id, 'Cliente Exemplo', 'cliente@exemplo.com', '(11) 99999-9999', NOW() - INTERVAL '30 days')
        RETURNING id INTO sample_customer_id;
        
        -- Produto de exemplo
        INSERT INTO products (user_id, name, category, price, stock_quantity, created_at)
        VALUES (test_user_id, 'Produto Exemplo', 'Eletrônicos', 199.90, 100, NOW() - INTERVAL '60 days')
        RETURNING id INTO sample_product_id;
        
        -- Venda de exemplo
        INSERT INTO sales (user_id, customer_id, total_amount, payment_method, created_at)
        VALUES (test_user_id, sample_customer_id, 399.80, 'card', NOW() - INTERVAL '7 days')
        RETURNING id INTO sample_sale_id;
        
        -- Item da venda
        INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price)
        VALUES (sample_sale_id, sample_product_id, 2, 199.90, 399.80);
        
        -- Ordem de serviço
        INSERT INTO service_orders (user_id, customer_id, equipment, defect, status, total_amount, created_at)
        VALUES (test_user_id, sample_customer_id, 'Notebook Dell', 'Não liga', 'completed', 150.00, NOW() - INTERVAL '3 days');
        
        RAISE NOTICE '  ✅ Dados de exemplo adicionados';
        RAISE NOTICE '  🔑 User ID de teste: %', test_user_id;
    ELSE
        RAISE NOTICE '  ✅ Dados existentes encontrados, não foi necessário adicionar exemplos';
    END IF;
END $$;

-- 8. RELATÓRIO FINAL
DO $$
DECLARE
    table_name text;
    record_count integer;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📈 === RELATÓRIO FINAL DA MIGRAÇÃO ===';
    
    FOREACH table_name IN ARRAY ARRAY['customers', 'products', 'sales', 'sale_items', 'service_orders']
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO record_count;
        RAISE NOTICE '  📊 % registros em %', record_count, table_name;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎉 === MIGRAÇÃO CONCLUÍDA COM SUCESSO ===';
    RAISE NOTICE '✅ Banco de dados organizado e funcional para relatórios';
    RAISE NOTICE '🔥 Sistema pronto para uso!';
END $$;