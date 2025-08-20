-- 🚀 CRIAR TABELAS BÁSICAS SEM RLS PRIMEIRO
-- Este script cria tabelas simples sem user_id e depois adiciona RLS

-- 1. CRIAR TABELAS BÁSICAS (sem user_id)

-- TABELA CLIENTS
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA PRODUCTS
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    client_id UUID REFERENCES clients(id),
    total DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'completed',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ADICIONAR COLUNA user_id SE NÃO EXISTIR
DO $$ 
BEGIN
    -- Adicionar user_id em clients
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='user_id') THEN
        ALTER TABLE clients ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- Adicionar user_id em categories
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='user_id') THEN
        ALTER TABLE categories ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- Adicionar user_id em products
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='user_id') THEN
        ALTER TABLE products ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- Adicionar user_id em service_orders
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='user_id') THEN
        ALTER TABLE service_orders ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- Adicionar user_id em establishments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='establishments' AND column_name='user_id') THEN
        ALTER TABLE establishments ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
    
    -- Adicionar user_id em sales
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='user_id') THEN
        ALTER TABLE sales ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 3. VERIFICAR SE O USUÁRIO EXISTE
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 4. REMOVER POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can manage own clients" ON clients;
DROP POLICY IF EXISTS "Users can manage own products" ON products;  
DROP POLICY IF EXISTS "Users can manage own categories" ON categories;
DROP POLICY IF EXISTS "Users can manage own service_orders" ON service_orders;
DROP POLICY IF EXISTS "Users can manage own establishments" ON establishments;
DROP POLICY IF EXISTS "Users can manage own sales" ON sales;
DROP POLICY IF EXISTS "assistencia_full_access_clients" ON clients;
DROP POLICY IF EXISTS "assistencia_full_access_products" ON products;
DROP POLICY IF EXISTS "assistencia_full_access_categories" ON categories;
DROP POLICY IF EXISTS "assistencia_full_access_service_orders" ON service_orders;
DROP POLICY IF EXISTS "assistencia_full_access_establishments" ON establishments;
DROP POLICY IF EXISTS "assistencia_full_access_sales" ON sales;

-- 5. CRIAR POLÍTICAS SUPER PERMISSIVAS PARA assistenciaallimport10@gmail.com
-- Essas políticas permitem que este usuário acesse TUDO

-- CLIENTES
CREATE POLICY "super_access_clients" ON clients
    FOR ALL TO authenticated
    USING (TRUE)  -- Permite ver todos os registros
    WITH CHECK (TRUE);  -- Permite inserir/atualizar qualquer registro

-- PRODUTOS  
CREATE POLICY "super_access_products" ON products
    FOR ALL TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- CATEGORIAS
CREATE POLICY "super_access_categories" ON categories
    FOR ALL TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- ORDENS DE SERVIÇO
CREATE POLICY "super_access_service_orders" ON service_orders
    FOR ALL TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- ESTABELECIMENTOS
CREATE POLICY "super_access_establishments" ON establishments
    FOR ALL TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- VENDAS
CREATE POLICY "super_access_sales" ON sales
    FOR ALL TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- 6. HABILITAR RLS (mas com políticas permissivas)
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_service_orders_user_id ON service_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_establishments_user_id ON establishments(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_user_id ON sales(user_id);

-- 8. VERIFICAR ESTRUTURA DAS TABELAS
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'products', 'categories', 'service_orders', 'establishments', 'sales')
ORDER BY table_name, ordinal_position;

-- 9. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE policyname LIKE '%super_access%'
ORDER BY tablename, policyname;

-- ✅ SUCESSO! 
-- Tabelas criadas com políticas SUPER permissivas
-- QUALQUER usuário logado pode acessar TODOS os dados
-- Perfeito para importação sem restrições!
