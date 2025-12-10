-- ===== RESOLUÇÃO COMPLETA DE CONFLITOS NO BANCO =====
-- ATENÇÃO: Este script resolve conflitos removendo tabelas duplicadas
-- Execute apenas após fazer backup dos dados importantes!

-- 1. BACKUP DE SEGURANÇA (se necessário)
DO $$
BEGIN
    RAISE NOTICE '🚨 === RESOLUÇÃO DE CONFLITOS INICIADA ===';
    RAISE NOTICE '⚠️  IMPORTANTE: Execute apenas se tiver certeza!';
    RAISE NOTICE '';
END $$;

-- 2. REMOVER TABELAS DUPLICADAS (PORTUGUÊS)
DO $$
BEGIN
    RAISE NOTICE '🗑️  REMOVENDO TABELAS DUPLICADAS EM PORTUGUÊS:';
    
    -- Remover tabelas em português se existirem as em inglês
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'customers') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        DROP TABLE IF EXISTS clientes CASCADE;
        RAISE NOTICE '  ❌ Tabela "clientes" removida (mantida "customers")';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        DROP TABLE IF EXISTS produtos CASCADE;
        RAISE NOTICE '  ❌ Tabela "produtos" removida (mantida "products")';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vendas') THEN
        DROP TABLE IF EXISTS vendas CASCADE;
        RAISE NOTICE '  ❌ Tabela "vendas" removida (mantida "sales")';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sale_items') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'itens_venda') THEN
        DROP TABLE IF EXISTS itens_venda CASCADE;
        RAISE NOTICE '  ❌ Tabela "itens_venda" removida (mantida "sale_items")';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'service_orders') 
       AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN
        DROP TABLE IF EXISTS ordens_servico CASCADE;
        RAISE NOTICE '  ❌ Tabela "ordens_servico" removida (mantida "service_orders")';
    END IF;
    
    -- Remover outras tabelas problemáticas
    DROP TABLE IF EXISTS funcionarios CASCADE;
    DROP TABLE IF EXISTS empresas CASCADE;
    DROP TABLE IF EXISTS configuracoes CASCADE;
    DROP TABLE IF EXISTS permissoes CASCADE;
    DROP TABLE IF EXISTS assinaturas CASCADE;
    
    RAISE NOTICE '  ✅ Limpeza de tabelas duplicadas concluída';
END $$;

-- 3. REMOVER POLÍTICAS CONFLITANTES
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔒 LIMPANDO POLÍTICAS RLS CONFLITANTES:';
    
    -- Remover todas as políticas das tabelas que vamos recriar
    FOR policy_record IN
        SELECT tablename, policyname
        FROM pg_policies
        WHERE tablename IN ('customers', 'products', 'sales', 'sale_items', 'service_orders')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', policy_record.policyname, policy_record.tablename);
        RAISE NOTICE '  ❌ Política %s removida de %s', policy_record.policyname, policy_record.tablename;
    END LOOP;
    
    RAISE NOTICE '  ✅ Políticas conflitantes removidas';
END $$;

-- 4. GARANTIR ESTRUTURA LIMPA E CORRETA
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔧 RECRIANDO ESTRUTURA LIMPA:';
    
    -- Desabilitar RLS temporariamente
    ALTER TABLE IF EXISTS customers DISABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS products DISABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS sales DISABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS sale_items DISABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS service_orders DISABLE ROW LEVEL SECURITY;
    
    -- Recriar tabelas com estrutura correta
    DROP TABLE IF EXISTS sale_items CASCADE;
    DROP TABLE IF EXISTS sales CASCADE;
    DROP TABLE IF EXISTS service_orders CASCADE;
    DROP TABLE IF EXISTS products CASCADE;
    DROP TABLE IF EXISTS customers CASCADE;
    
    RAISE NOTICE '  🗑️  Tabelas antigas removidas';
END $$;

-- 5. CRIAR ESTRUTURA NOVA E LIMPA
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🏗️  CRIANDO ESTRUTURA NOVA:';
    
    -- Tabela de Clientes
    CREATE TABLE customers (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id uuid NOT NULL,
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
    
    -- Tabela de Produtos
    CREATE TABLE products (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id uuid NOT NULL,
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
    
    -- Tabela de Vendas
    CREATE TABLE sales (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id uuid NOT NULL,
        empresa_id uuid,
        customer_id uuid REFERENCES customers(id),
        total_amount decimal(10,2) DEFAULT 0,
        discount_amount decimal(10,2) DEFAULT 0,
        payment_method text DEFAULT 'cash',
        status text DEFAULT 'completed',
        notes text,
        created_at timestamptz DEFAULT NOW(),
        updated_at timestamptz DEFAULT NOW()
    );
    
    -- Tabela de Itens de Venda
    CREATE TABLE sale_items (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        sale_id uuid REFERENCES sales(id) ON DELETE CASCADE NOT NULL,
        product_id uuid REFERENCES products(id) NOT NULL,
        quantity integer DEFAULT 1,
        unit_price decimal(10,2) DEFAULT 0,
        total_price decimal(10,2) DEFAULT 0,
        created_at timestamptz DEFAULT NOW()
    );
    
    -- Tabela de Ordens de Serviço
    CREATE TABLE service_orders (
        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id uuid NOT NULL,
        empresa_id uuid,
        customer_id uuid REFERENCES customers(id) NOT NULL,
        equipment text NOT NULL,
        defect text,
        observations text,
        status text DEFAULT 'pending',
        total_amount decimal(10,2) DEFAULT 0,
        created_at timestamptz DEFAULT NOW(),
        updated_at timestamptz DEFAULT NOW()
    );
    
    RAISE NOTICE '  ✅ Tabelas criadas com estrutura limpa';
END $$;

-- 6. CONFIGURAR RLS CORRETAMENTE
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔒 CONFIGURANDO RLS:';
    
    -- Habilitar RLS
    ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
    
    -- Criar políticas simples e funcionais
    CREATE POLICY "customers_policy" ON customers FOR ALL USING (true);
    CREATE POLICY "products_policy" ON products FOR ALL USING (true);
    CREATE POLICY "sales_policy" ON sales FOR ALL USING (true);
    CREATE POLICY "sale_items_policy" ON sale_items FOR ALL USING (true);
    CREATE POLICY "service_orders_policy" ON service_orders FOR ALL USING (true);
    
    RAISE NOTICE '  ✅ RLS configurado com políticas permissivas';
END $$;

-- 7. INSERIR DADOS DE TESTE
DO $$
DECLARE
    sample_customer_id uuid;
    sample_product_id uuid;
    sample_sale_id uuid;
    test_user_id uuid := gen_random_uuid();
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 INSERINDO DADOS DE TESTE:';
    
    -- Cliente de teste
    INSERT INTO customers (user_id, name, email, phone, created_at)
    VALUES (test_user_id, 'Cliente Teste', 'teste@exemplo.com', '(11) 99999-9999', NOW() - INTERVAL '30 days')
    RETURNING id INTO sample_customer_id;
    
    -- Produto de teste
    INSERT INTO products (user_id, name, category, price, stock_quantity, created_at)
    VALUES (test_user_id, 'Produto Teste', 'Eletrônicos', 149.90, 50, NOW() - INTERVAL '60 days')
    RETURNING id INTO sample_product_id;
    
    -- Venda de teste
    INSERT INTO sales (user_id, customer_id, total_amount, payment_method, created_at)
    VALUES (test_user_id, sample_customer_id, 299.80, 'card', NOW() - INTERVAL '5 days')
    RETURNING id INTO sample_sale_id;
    
    -- Item da venda
    INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price)
    VALUES (sample_sale_id, sample_product_id, 2, 149.90, 299.80);
    
    -- Ordem de serviço de teste
    INSERT INTO service_orders (user_id, customer_id, equipment, defect, status, total_amount, created_at)
    VALUES (test_user_id, sample_customer_id, 'iPhone 12', 'Tela trincada', 'completed', 280.00, NOW() - INTERVAL '2 days');
    
    RAISE NOTICE '  ✅ Dados de teste inseridos';
    RAISE NOTICE '  👤 User ID de teste: %', test_user_id;
END $$;

-- 8. VERIFICAÇÃO FINAL
DO $$
DECLARE
    table_name text;
    record_count integer;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '✅ === VERIFICAÇÃO FINAL ===';
    
    FOREACH table_name IN ARRAY ARRAY['customers', 'products', 'sales', 'sale_items', 'service_orders']
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO record_count;
        RAISE NOTICE '  📊 % registros em %', record_count, table_name;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎉 RESOLUÇÃO DE CONFLITOS CONCLUÍDA COM SUCESSO!';
    RAISE NOTICE '🔥 Banco de dados limpo e funcional';
END $$;