-- VERIFICAÇÃO URGENTE: PRODUTOS DO USUÁRIO assistenciaallimport0@gmail.com

-- 1. Verificar se o usuário existe
SELECT 
  id, 
  email, 
  created_at 
FROM auth.users 
WHERE email = 'assistenciaallimport0@gmail.com';

-- 2. Verificar produtos na tabela 'produtos' 
SELECT COUNT(*) as total_produtos_tabela_produtos
FROM produtos;

-- 3. Verificar produtos por usuário
SELECT 
  u.email,
  COUNT(p.id) as total_produtos
FROM auth.users u
LEFT JOIN produtos p ON p.user_id = u.id
WHERE u.email = 'assistenciaallimport0@gmail.com'
GROUP BY u.id, u.email;

-- 4. Verificar se existem produtos na tabela antiga 'products'
SELECT COUNT(*) as total_produtos_tabela_products
FROM products;

-- 5. Verificar produtos do usuário na tabela antiga
SELECT 
  u.email,
  COUNT(p.id) as total_produtos_products
FROM auth.users u
LEFT JOIN products p ON p.user_id = u.id  
WHERE u.email = 'assistenciaallimport0@gmail.com'
GROUP BY u.id, u.email;

-- 6. Verificar alguns produtos de exemplo do usuário (se existirem)
SELECT 
  id,
  nome,
  codigo_barras,
  preco,
  estoque,
  ativo,
  user_id,
  criado_em
FROM produtos 
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport0@gmail.com'
)
LIMIT 10;

-- 7. Verificar se RLS está ativo
SELECT 
  schemaname, 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE tablename IN ('produtos', 'products') 
AND schemaname = 'public';

-- 8. Verificar políticas RLS
SELECT 
  schemaname,
  tablename, 
  policyname, 
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('produtos', 'products');

-- 9. Verificar se há produtos sem user_id (dados órfãos)
SELECT COUNT(*) as produtos_sem_user_id
FROM produtos 
WHERE user_id IS NULL;

-- 10. TESTE: Desabilitar RLS temporariamente e verificar todos os produtos
-- (Execute apenas se necessário para diagnóstico)
-- ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
-- SELECT COUNT(*) as total_produtos_sem_rls FROM produtos;
-- ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;