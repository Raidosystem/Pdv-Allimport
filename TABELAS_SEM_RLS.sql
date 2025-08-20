-- 🎯 SCRIPT ULTRA SIMPLES - SÓ CRIAR TABELAS SEM RLS
-- Execute este primeiro para criar as tabelas básicas

-- TABELA CLIENTS
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    birth_date DATE,
    document TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA CATEGORIES  
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT,
    icon TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA PRODUCTS
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    name TEXT NOT NULL,
    price DECIMAL(10,2) DEFAULT 0,
    cost_price DECIMAL(10,2) DEFAULT 0,
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 0,
    barcode TEXT,
    category_id UUID,
    description TEXT,
    brand TEXT,
    model TEXT,
    unit TEXT DEFAULT 'un',
    active BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA SERVICE_ORDERS
CREATE TABLE IF NOT EXISTS service_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    client_id UUID,
    equipment TEXT NOT NULL,
    brand TEXT,
    model TEXT,
    serial_number TEXT,
    defect TEXT NOT NULL,
    observation TEXT,
    status TEXT DEFAULT 'Aguardando',
    priority TEXT DEFAULT 'Normal',
    estimated_date DATE,
    completed_date DATE,
    total DECIMAL(10,2) DEFAULT 0,
    labor_cost DECIMAL(10,2) DEFAULT 0,
    parts_cost DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA ESTABLISHMENTS
CREATE TABLE IF NOT EXISTS establishments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA SALES
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    client_id UUID,
    total DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) DEFAULT 0,
    discount DECIMAL(10,2) DEFAULT 0,
    tax DECIMAL(10,2) DEFAULT 0,
    payment_method TEXT DEFAULT 'Dinheiro',
    status TEXT DEFAULT 'completed',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- DESABILITAR RLS COMPLETAMENTE (mais permissivo)
ALTER TABLE clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE establishments DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales DISABLE ROW LEVEL SECURITY;

-- VERIFICAR TABELAS CRIADAS
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'products', 'categories', 'service_orders', 'establishments', 'sales')
ORDER BY table_name;

-- TESTAR INSERÇÃO SIMPLES
INSERT INTO clients (user_id, name, email) 
VALUES (gen_random_uuid(), 'Teste Cliente', 'teste@teste.com')
ON CONFLICT DO NOTHING;

-- VERIFICAR SE FUNCIONOU
SELECT count(*) as total_clients FROM clients;

-- ✅ PRONTO! Tabelas criadas sem RLS
-- Agora a importação deve funcionar perfeitamente!
