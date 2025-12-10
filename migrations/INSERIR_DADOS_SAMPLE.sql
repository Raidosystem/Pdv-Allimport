-- 🚀 INSERÇÃO DIRETA DO BACKUP NO SUPABASE
-- Para usuário: assistenciaallimport10@gmail.com

-- 1. VERIFICAR USER_ID
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. LIMPAR DADOS EXISTENTES (OPCIONAL - descomente se necessário)
-- DELETE FROM clients WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');
-- DELETE FROM categories WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');
-- DELETE FROM products WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');
-- DELETE FROM service_orders WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- 3. INSERIR CLIENTES (SAMPLE - primeiros registros)
INSERT INTO clients (id, user_id, name, email, phone, address, city, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'ALEXANDRE FERREIRA DA SILVA',
    'alexandre@email.com',
    '(11) 99999-0001',
    'Rua das Flores, 123',
    'São Paulo',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'MARIA SANTOS OLIVEIRA',
    'maria@email.com',
    '(11) 99999-0002',
    'Av. Brasil, 456',
    'São Paulo',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'JOÃO CARLOS PEREIRA',
    'joao@email.com',
    '(11) 99999-0003',
    'Rua da Paz, 789',
    'São Paulo',
    NOW(),
    NOW()
);

-- 4. INSERIR CATEGORIAS
INSERT INTO categories (id, user_id, name, description, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'SMARTPHONES',
    'Celulares e acessórios',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'TABLETS',
    'Tablets e acessórios',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'NOTEBOOKS',
    'Notebooks e laptops',
    NOW(),
    NOW()
);

-- 5. INSERIR PRODUTOS
INSERT INTO products (id, user_id, name, price, stock, barcode, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'iPhone 13 Pro',
    4500.00,
    10,
    '7891234567890',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'Samsung Galaxy S21',
    3200.00,
    15,
    '7891234567891',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    'iPad Air',
    2800.00,
    8,
    '7891234567892',
    NOW(),
    NOW()
);

-- 6. INSERIR ORDENS DE SERVIÇO
INSERT INTO service_orders (id, user_id, client_id, equipment, defect, status, total, created_at, updated_at) VALUES
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    (SELECT id FROM clients WHERE name = 'ALEXANDRE FERREIRA DA SILVA' AND user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') LIMIT 1),
    'iPhone 12',
    'Tela trincada',
    'Em andamento',
    350.00,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'),
    (SELECT id FROM clients WHERE name = 'MARIA SANTOS OLIVEIRA' AND user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') LIMIT 1),
    'Samsung J7',
    'Não liga',
    'Aguardando',
    180.00,
    NOW(),
    NOW()
);

-- 7. VERIFICAR DADOS INSERIDOS
SELECT 
    'clients' as tabela,
    COUNT(*) as total
FROM clients 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')

UNION ALL

SELECT 
    'categories' as tabela,
    COUNT(*) as total
FROM categories 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')

UNION ALL

SELECT 
    'products' as tabela,
    COUNT(*) as total
FROM products 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')

UNION ALL

SELECT 
    'service_orders' as tabela,
    COUNT(*) as total
FROM service_orders 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- ✅ DADOS DE EXEMPLO INSERIDOS!
-- Para inserir TODOS os dados do backup, use o script PowerShell para gerar SQL completo
