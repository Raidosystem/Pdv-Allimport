-- ===== ESTRUTURA COMPLETA PARA RELATÓRIOS EM TEMPO REAL =====
-- Este arquivo garante que todas as tabelas necessárias existam com nomes corretos

-- 1. VERIFICAR E CRIAR TABELAS PRINCIPAIS
DO $$
BEGIN
    -- Tabela de Clientes (customers)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'customers') THEN
        CREATE TABLE customers (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
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
        RAISE NOTICE '✅ Tabela customers criada';
    END IF;

    -- Tabela de Produtos (products)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'products') THEN
        CREATE TABLE products (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
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
        RAISE NOTICE '✅ Tabela products criada';
    END IF;

    -- Tabela de Vendas (sales)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales') THEN
        CREATE TABLE sales (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
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
        RAISE NOTICE '✅ Tabela sales criada';
    END IF;

    -- Tabela de Itens de Venda (sale_items)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sale_items') THEN
        CREATE TABLE sale_items (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            sale_id uuid REFERENCES sales(id) ON DELETE CASCADE NOT NULL,
            product_id uuid REFERENCES products(id) NOT NULL,
            quantity integer DEFAULT 1,
            unit_price decimal(10,2) DEFAULT 0,
            total_price decimal(10,2) DEFAULT 0,
            created_at timestamptz DEFAULT NOW()
        );
        RAISE NOTICE '✅ Tabela sale_items criada';
    END IF;

    -- Tabela de Ordens de Serviço (service_orders)
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'service_orders') THEN
        CREATE TABLE service_orders (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
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
        RAISE NOTICE '✅ Tabela service_orders criada';
    END IF;

END $$;

-- 2. CONFIGURAR RLS (Row Level Security)
DO $$
BEGIN
    -- Habilitar RLS em todas as tabelas
    ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
    
    RAISE NOTICE '✅ RLS habilitado em todas as tabelas';
END $$;

-- 3. CRIAR POLÍTICAS RLS
DO $$
BEGIN
    -- Políticas para customers
    DROP POLICY IF EXISTS "users_can_manage_own_customers" ON customers;
    CREATE POLICY "users_can_manage_own_customers" ON customers
        FOR ALL USING (auth.uid() = user_id);

    -- Políticas para products
    DROP POLICY IF EXISTS "users_can_manage_own_products" ON products;
    CREATE POLICY "users_can_manage_own_products" ON products
        FOR ALL USING (auth.uid() = user_id);

    -- Políticas para sales
    DROP POLICY IF EXISTS "users_can_manage_own_sales" ON sales;
    CREATE POLICY "users_can_manage_own_sales" ON sales
        FOR ALL USING (auth.uid() = user_id);

    -- Políticas para sale_items (através da venda)
    DROP POLICY IF EXISTS "users_can_manage_own_sale_items" ON sale_items;
    CREATE POLICY "users_can_manage_own_sale_items" ON sale_items
        FOR ALL USING (EXISTS (
            SELECT 1 FROM sales WHERE sales.id = sale_items.sale_id AND sales.user_id = auth.uid()
        ));

    -- Políticas para service_orders
    DROP POLICY IF EXISTS "users_can_manage_own_service_orders" ON service_orders;
    CREATE POLICY "users_can_manage_own_service_orders" ON service_orders
        FOR ALL USING (auth.uid() = user_id);

    RAISE NOTICE '✅ Políticas RLS criadas';
END $$;

-- 4. INSERIR DADOS DE EXEMPLO PARA TESTES
DO $$
DECLARE
    sample_customer_id uuid;
    sample_product_id uuid;
    sample_sale_id uuid;
    current_user_id uuid;
BEGIN
    -- Verificar se existe usuário logado
    SELECT auth.uid() INTO current_user_id;
    
    IF current_user_id IS NOT NULL THEN
        -- Inserir cliente de exemplo
        INSERT INTO customers (user_id, name, email, phone, created_at)
        VALUES (current_user_id, 'Cliente Exemplo', 'cliente@exemplo.com', '(11) 99999-9999', NOW() - INTERVAL '30 days')
        ON CONFLICT DO NOTHING
        RETURNING id INTO sample_customer_id;

        -- Inserir produto de exemplo
        INSERT INTO products (user_id, name, category, price, stock_quantity, created_at)
        VALUES (current_user_id, 'Produto Exemplo', 'Eletrônicos', 99.90, 100, NOW() - INTERVAL '60 days')
        ON CONFLICT DO NOTHING
        RETURNING id INTO sample_product_id;

        -- Inserir venda de exemplo
        IF sample_customer_id IS NOT NULL AND sample_product_id IS NOT NULL THEN
            INSERT INTO sales (user_id, customer_id, total_amount, payment_method, created_at)
            VALUES (current_user_id, sample_customer_id, 199.80, 'cash', NOW() - INTERVAL '5 days')
            ON CONFLICT DO NOTHING
            RETURNING id INTO sample_sale_id;

            -- Inserir itens da venda
            IF sample_sale_id IS NOT NULL THEN
                INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price)
                VALUES (sample_sale_id, sample_product_id, 2, 99.90, 199.80)
                ON CONFLICT DO NOTHING;
            END IF;
        END IF;

        -- Inserir ordem de serviço de exemplo
        IF sample_customer_id IS NOT NULL THEN
            INSERT INTO service_orders (user_id, customer_id, equipment, defect, status, total_amount, created_at)
            VALUES (current_user_id, sample_customer_id, 'Smartphone Samsung', 'Tela quebrada', 'completed', 150.00, NOW() - INTERVAL '3 days')
            ON CONFLICT DO NOTHING;
        END IF;

        RAISE NOTICE '✅ Dados de exemplo inseridos para usuário %', current_user_id;
    ELSE
        RAISE NOTICE '⚠️ Nenhum usuário logado - dados de exemplo não inseridos';
    END IF;
END $$;

-- 5. VERIFICAR DADOS INSERIDOS
DO $$
DECLARE
    customer_count integer;
    product_count integer;
    sale_count integer;
    service_order_count integer;
BEGIN
    SELECT COUNT(*) INTO customer_count FROM customers WHERE user_id = auth.uid();
    SELECT COUNT(*) INTO product_count FROM products WHERE user_id = auth.uid();
    SELECT COUNT(*) INTO sale_count FROM sales WHERE user_id = auth.uid();
    SELECT COUNT(*) INTO service_order_count FROM service_orders WHERE user_id = auth.uid();

    RAISE NOTICE '📊 DADOS DISPONÍVEIS PARA RELATÓRIOS:';
    RAISE NOTICE '👥 Clientes: %', customer_count;
    RAISE NOTICE '📦 Produtos: %', product_count;
    RAISE NOTICE '💰 Vendas: %', sale_count;
    RAISE NOTICE '🛠️ Ordens de Serviço: %', service_order_count;
END $$;

-- ===== ESTRUTURA COMPLETA PARA RELATÓRIOS PRONTA! =====