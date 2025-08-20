-- 🔧 ADICIONAR COLUNAS FALTANTES ÀS TABELAS EXISTENTES
-- Execute este se as tabelas já existem mas faltam colunas

-- ADICIONAR COLUNAS EM CLIENTS
DO $$ 
BEGIN
    -- birth_date
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='birth_date') THEN
        ALTER TABLE clients ADD COLUMN birth_date DATE;
    END IF;
    
    -- document
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='document') THEN
        ALTER TABLE clients ADD COLUMN document TEXT;
    END IF;
    
    -- notes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='notes') THEN
        ALTER TABLE clients ADD COLUMN notes TEXT;
    END IF;
    
    -- city (NOVA COLUNA FALTANTE)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='city') THEN
        ALTER TABLE clients ADD COLUMN city TEXT;
    END IF;
    
    -- state
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='state') THEN
        ALTER TABLE clients ADD COLUMN state TEXT;
    END IF;
    
    -- zip_code
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='zip_code') THEN
        ALTER TABLE clients ADD COLUMN zip_code TEXT;
    END IF;
    
    -- country
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='country') THEN
        ALTER TABLE clients ADD COLUMN country TEXT DEFAULT 'Brasil';
    END IF;
    
    -- gender
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='gender') THEN
        ALTER TABLE clients ADD COLUMN gender TEXT;
    END IF;
    
    -- profession
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='profession') THEN
        ALTER TABLE clients ADD COLUMN profession TEXT;
    END IF;
    
    -- company
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='company') THEN
        ALTER TABLE clients ADD COLUMN company TEXT;
    END IF;
    
    -- active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clients' AND column_name='active') THEN
        ALTER TABLE clients ADD COLUMN active BOOLEAN DEFAULT TRUE;
    END IF;
END $$;

-- ADICIONAR COLUNAS EM CATEGORIES
DO $$ 
BEGIN
    -- color
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='color') THEN
        ALTER TABLE categories ADD COLUMN color TEXT;
    END IF;
    
    -- icon
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='icon') THEN
        ALTER TABLE categories ADD COLUMN icon TEXT;
    END IF;
END $$;

-- ADICIONAR COLUNAS EM PRODUCTS
DO $$ 
BEGIN
    -- cost_price
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='cost_price') THEN
        ALTER TABLE products ADD COLUMN cost_price DECIMAL(10,2) DEFAULT 0;
    END IF;
    
    -- min_stock
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='min_stock') THEN
        ALTER TABLE products ADD COLUMN min_stock INTEGER DEFAULT 0;
    END IF;
    
    -- brand
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='brand') THEN
        ALTER TABLE products ADD COLUMN brand TEXT;
    END IF;
    
    -- model
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='model') THEN
        ALTER TABLE products ADD COLUMN model TEXT;
    END IF;
    
    -- unit
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='unit') THEN
        ALTER TABLE products ADD COLUMN unit TEXT DEFAULT 'un';
    END IF;
    
    -- active
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='active') THEN
        ALTER TABLE products ADD COLUMN active BOOLEAN DEFAULT TRUE;
    END IF;
    
    -- image_url
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='image_url') THEN
        ALTER TABLE products ADD COLUMN image_url TEXT;
    END IF;
END $$;

-- ADICIONAR COLUNAS EM SERVICE_ORDERS
DO $$ 
BEGIN
    -- brand
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='brand') THEN
        ALTER TABLE service_orders ADD COLUMN brand TEXT;
    END IF;
    
    -- model
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='model') THEN
        ALTER TABLE service_orders ADD COLUMN model TEXT;
    END IF;
    
    -- serial_number
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='serial_number') THEN
        ALTER TABLE service_orders ADD COLUMN serial_number TEXT;
    END IF;
    
    -- observation
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='observation') THEN
        ALTER TABLE service_orders ADD COLUMN observation TEXT;
    END IF;
    
    -- priority
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='priority') THEN
        ALTER TABLE service_orders ADD COLUMN priority TEXT DEFAULT 'Normal';
    END IF;
    
    -- estimated_date
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='estimated_date') THEN
        ALTER TABLE service_orders ADD COLUMN estimated_date DATE;
    END IF;
    
    -- completed_date
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='completed_date') THEN
        ALTER TABLE service_orders ADD COLUMN completed_date DATE;
    END IF;
    
    -- labor_cost
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='labor_cost') THEN
        ALTER TABLE service_orders ADD COLUMN labor_cost DECIMAL(10,2) DEFAULT 0;
    END IF;
    
    -- parts_cost
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='service_orders' AND column_name='parts_cost') THEN
        ALTER TABLE service_orders ADD COLUMN parts_cost DECIMAL(10,2) DEFAULT 0;
    END IF;
END $$;

-- ADICIONAR COLUNAS EM SALES
DO $$ 
BEGIN
    -- subtotal
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='subtotal') THEN
        ALTER TABLE sales ADD COLUMN subtotal DECIMAL(10,2) DEFAULT 0;
    END IF;
    
    -- discount
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='discount') THEN
        ALTER TABLE sales ADD COLUMN discount DECIMAL(10,2) DEFAULT 0;
    END IF;
    
    -- tax
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='tax') THEN
        ALTER TABLE sales ADD COLUMN tax DECIMAL(10,2) DEFAULT 0;
    END IF;
    
    -- payment_method
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='payment_method') THEN
        ALTER TABLE sales ADD COLUMN payment_method TEXT DEFAULT 'Dinheiro';
    END IF;
    
    -- notes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='sales' AND column_name='notes') THEN
        ALTER TABLE sales ADD COLUMN notes TEXT;
    END IF;
END $$;

-- VERIFICAR TODAS AS COLUNAS CRIADAS
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('clients', 'products', 'categories', 'service_orders', 'establishments', 'sales')
ORDER BY table_name, ordinal_position;

-- ✅ COLUNAS ADICIONADAS!
-- birth_date e outras colunas faltantes foram criadas
