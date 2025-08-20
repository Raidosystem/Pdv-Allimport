-- 🎯 RLS SUPER SIMPLES PARA assistenciaallimport10@gmail.com
-- Cole este código no Supabase SQL Editor e execute

-- 1. VERIFICAR SE O USUÁRIO EXISTE
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. REMOVER POLÍTICAS EXISTENTES (se houver)
DROP POLICY IF EXISTS "Users can manage own clients" ON clients;
DROP POLICY IF EXISTS "Users can manage own products" ON products;  
DROP POLICY IF EXISTS "Users can manage own categories" ON categories;
DROP POLICY IF EXISTS "Users can manage own service_orders" ON service_orders;
DROP POLICY IF EXISTS "Users can manage own establishments" ON establishments;

-- 3. CRIAR POLÍTICAS PERMISSIVAS PARA ESTE USUÁRIO ESPECÍFICO
-- CLIENTES
CREATE POLICY "assistencia_full_access_clients" ON clients
    FOR ALL TO authenticated
    USING (auth.email() = 'assistenciaallimport10@gmail.com');

-- PRODUTOS  
CREATE POLICY "assistencia_full_access_products" ON products
    FOR ALL TO authenticated
    USING (auth.email() = 'assistenciaallimport10@gmail.com');

-- CATEGORIAS
CREATE POLICY "assistencia_full_access_categories" ON categories  
    FOR ALL TO authenticated
    USING (auth.email() = 'assistenciaallimport10@gmail.com');

-- ORDENS DE SERVIÇO
CREATE POLICY "assistencia_full_access_service_orders" ON service_orders
    FOR ALL TO authenticated
    USING (auth.email() = 'assistenciaallimport10@gmail.com');

-- ESTABELECIMENTOS
CREATE POLICY "assistencia_full_access_establishments" ON establishments
    FOR ALL TO authenticated  
    USING (auth.email() = 'assistenciaallimport10@gmail.com');

-- 4. GARANTIR QUE RLS ESTÁ HABILITADO
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE establishments ENABLE ROW LEVEL SECURITY;

-- 5. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE policyname LIKE '%assistencia%'
ORDER BY tablename;

-- 6. TESTAR ACESSO (execute quando logado como assistenciaallimport10@gmail.com)
-- SELECT count(*) as total_clients FROM clients;
-- SELECT count(*) as total_products FROM products;  
-- SELECT count(*) as total_categories FROM categories;
-- SELECT count(*) as total_service_orders FROM service_orders;

-- ✅ SUCESSO! Agora assistenciaallimport10@gmail.com tem acesso completo
