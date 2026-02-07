-- =====================================================
-- DIAGNOSTICAR PRODUTO NÃO APARECE EM VENDAS
-- =====================================================

-- 1️⃣ VERIFICAR SE O PRODUTO FOI CRIADO
SELECT 
  id,
  nome,
  preco,
  estoque,
  ativo,
  user_id,
  created_at
FROM produtos
WHERE user_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73'
ORDER BY created_at DESC
LIMIT 5;

-- 2️⃣ VERIFICAR SE TEM PRODUTOS ATIVOS
SELECT 
  COUNT(*) as total_produtos,
  COUNT(CASE WHEN ativo = true THEN 1 END) as produtos_ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as produtos_inativos
FROM produtos
WHERE user_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73';

-- 3️⃣ VERIFICAR RLS DA TABELA PRODUTOS
SELECT 
  schemaname,
  tablename,
  rowsecurity as "RLS Habilitado"
FROM pg_tables 
WHERE tablename = 'produtos'
  AND schemaname = 'public';

-- 4️⃣ VER POLÍTICAS RLS ATUAIS DA TABELA PRODUTOS
SELECT 
  policyname as "Política",
  cmd as "Operação",
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN 'Permissiva'
    ELSE 'Restritiva'
  END as "Tipo"
FROM pg_policies
WHERE tablename = 'produtos'
ORDER BY policyname;

-- 5️⃣ TESTAR QUERY QUE O FRONTEND USA
-- Simular busca do ProductService
SELECT *
FROM produtos
WHERE user_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73'
  AND ativo = true
ORDER BY nome
LIMIT 50;
