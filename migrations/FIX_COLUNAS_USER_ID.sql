-- 🔧 CORRIGIR COLUNAS USER_ID NAS TABELAS
-- Execute este script ANTES do BACKUP_COMPLETO_SQL.sql

-- 1. VERIFICAR ESTRUTURA ATUAL DAS TABELAS
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('categories', 'products', 'clients', 'service_orders')
ORDER BY table_name, ordinal_position;

-- 2. ADICIONAR COLUNA user_id NA TABELA categories (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE categories ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE 'Coluna user_id adicionada à tabela categories';
    ELSE
        RAISE NOTICE 'Coluna user_id já existe na tabela categories';
    END IF;
END $$;

-- 3. ADICIONAR COLUNA user_id NA TABELA products (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE products ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE 'Coluna user_id adicionada à tabela products';
    ELSE
        RAISE NOTICE 'Coluna user_id já existe na tabela products';
    END IF;
END $$;

-- 4. ADICIONAR COLUNA user_id NA TABELA clients (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clients' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE clients ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE 'Coluna user_id adicionada à tabela clients';
    ELSE
        RAISE NOTICE 'Coluna user_id já existe na tabela clients';
    END IF;
END $$;

-- 5. ADICIONAR COLUNA user_id NA TABELA service_orders (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'service_orders' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE service_orders ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE 'Coluna user_id adicionada à tabela service_orders';
    ELSE
        RAISE NOTICE 'Coluna user_id já existe na tabela service_orders';
    END IF;
END $$;

-- 6. VERIFICAR ESTRUTURA APÓS AS ALTERAÇÕES
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('categories', 'products', 'clients', 'service_orders')
  AND column_name = 'user_id'
ORDER BY table_name;

-- 7. CONFIGURAR RLS (Row Level Security) PARA ISOLAMENTO DE DADOS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;

-- 8. CRIAR POLÍTICAS RLS PARA ISOLAMENTO POR USUÁRIO
-- Categories
DROP POLICY IF EXISTS "Users can only see own categories" ON categories;
CREATE POLICY "Users can only see own categories" ON categories
    FOR ALL USING (user_id = auth.uid());

-- Products  
DROP POLICY IF EXISTS "Users can only see own products" ON products;
CREATE POLICY "Users can only see own products" ON products
    FOR ALL USING (user_id = auth.uid());

-- Clients
DROP POLICY IF EXISTS "Users can only see own clients" ON clients;
CREATE POLICY "Users can only see own clients" ON clients
    FOR ALL USING (user_id = auth.uid());

-- Service Orders
DROP POLICY IF EXISTS "Users can only see own service orders" ON service_orders;
CREATE POLICY "Users can only see own service orders" ON service_orders
    FOR ALL USING (user_id = auth.uid());

-- ✅ PRONTO! Agora execute o BACKUP_COMPLETO_SQL.sql

SELECT 'FIX APLICADO COM SUCESSO! Tabelas prontas para receber o backup.' as status;
