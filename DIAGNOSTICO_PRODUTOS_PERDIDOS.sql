-- DIAGNÓSTICO DE PRODUTOS PERDIDOS
-- Usuario: assistenciaallimport0@gmail.com

-- 1. Verificar se existem produtos na tabela 'produtos'
SELECT COUNT(*) as total_produtos_tabela_produtos 
FROM produtos;

-- 2. Verificar produtos por usuário específico
SELECT user_id, COUNT(*) as total_produtos
FROM produtos 
WHERE user_id IS NOT NULL
GROUP BY user_id;

-- 3. Buscar especificamente pelo usuário problemático
SELECT COUNT(*) as produtos_usuario_problema
FROM produtos 
WHERE user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'assistenciaallimport0@gmail.com'
);

-- 4. Verificar se existem produtos sem user_id (podem estar "perdidos")
SELECT COUNT(*) as produtos_sem_user_id
FROM produtos 
WHERE user_id IS NULL;

-- 5. Verificar alguns exemplos de produtos para análise
SELECT id, nome, user_id, ativo, criado_em, atualizado_em
FROM produtos 
LIMIT 10;

-- 6. Verificar se há produtos na tabela 'products' (antiga)
SELECT COUNT(*) as produtos_tabela_products
FROM products;

-- 7. Verificar estrutura das tabelas
\d produtos;
\d products;

-- 8. Verificar políticas RLS ativas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN ('produtos', 'products');

-- 9. Verificar se RLS está habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('produtos', 'products') 
AND schemaname = 'public';