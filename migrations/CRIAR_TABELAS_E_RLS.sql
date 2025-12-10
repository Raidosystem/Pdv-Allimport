-- 🚀 CRIAR TABELAS E RLS PARA assistenciaallimport10@gmail.com
-- Este script cria as tabelas necessárias e configura RLS

-- 1. VERIFICAR SE O USUÁRIO EXISTE
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. CRIAR TABELAS SE NÃO EXISTIREM

-- TABELA CLIENTS
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA CATEGORIES  
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA PRODUCTS
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    price DECIMAL(10,2) DEFAULT 0,
    stock INTEGER DEFAULT 0,
    barcode TEXT,
    category_id UUID REFERENCES categories(id),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA SERVICE_ORDERS
CREATE TABLE IF NOT EXISTS service_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id),
    equipment TEXT NOT NULL,
    defect TEXT NOT NULL,
    status TEXT DEFAULT 'Aguardando',
    total DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA ESTABLISHMENTS
CREATE TABLE IF NOT EXISTS establishments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA SALES (opcional)
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id),
    total DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'completed',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. HABILITAR RLS EM TODAS AS TABELAS
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- 4. REMOVER POLÍTICAS EXISTENTES (se houver)
DROP POLICY IF EXISTS "Users can manage own clients" ON clients;
DROP POLICY IF EXISTS "Users can manage own products" ON products;  
DROP POLICY IF EXISTS "Users can manage own categories" ON categories;
DROP POLICY IF EXISTS "Users can manage own service_orders" ON service_orders;
DROP POLICY IF EXISTS "Users can manage own establishments" ON establishments;
DROP POLICY IF EXISTS "Users can manage own sales" ON sales;

-- Remover políticas antigas específicas também
DROP POLICY IF EXISTS "assistencia_full_access_clients" ON clients;
DROP POLICY IF EXISTS "assistencia_full_access_products" ON products;
DROP POLICY IF EXISTS "assistencia_full_access_categories" ON categories;
DROP POLICY IF EXISTS "assistencia_full_access_service_orders" ON service_orders;
DROP POLICY IF EXISTS "assistencia_full_access_establishments" ON establishments;
DROP POLICY IF EXISTS "assistencia_full_access_sales" ON sales;

-- 5. CRIAR POLÍTICAS PERMISSIVAS PARA assistenciaallimport10@gmail.com

-- CLIENTES - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_clients" ON clients
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- PRODUTOS - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_products" ON products
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- CATEGORIAS - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_categories" ON categories
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- ORDENS DE SERVIÇO - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_service_orders" ON service_orders
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- ESTABELECIMENTOS - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_establishments" ON establishments
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- VENDAS - Acesso completo para assistencia
CREATE POLICY "assistencia_full_access_sales" ON sales
    FOR ALL TO authenticated
    USING (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    )
    WITH CHECK (
        auth.email() = 'assistenciaallimport10@gmail.com' 
        OR user_id = auth.uid()
    );

-- 6. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_service_orders_user_id ON service_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_establishments_user_id ON establishments(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_user_id ON sales(user_id);

-- 7. VERIFICAR TABELAS CRIADAS
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'products', 'categories', 'service_orders', 'establishments', 'sales')
ORDER BY table_name;

-- 8. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE policyname LIKE '%assistencia%'
ORDER BY tablename, policyname;

-- ✅ SUCESSO! 
-- Tabelas criadas e RLS configurado para assistenciaallimport10@gmail.com
-- Este usuário agora pode acessar TODOS os dados de TODAS as tabelas
