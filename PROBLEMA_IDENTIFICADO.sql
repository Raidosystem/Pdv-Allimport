-- 🚀 SOLUÇÃO: DADOS ESTÃO NO BANCO, PROBLEMA É NO FRONTEND

-- OS DADOS ESTÃO LÁ! ✅
-- Produtos ALLIMPORT inseridos: 20
-- Horário: 2025-08-20 00:48:21
-- Status: Todos com prefixo "ALLIMPORT -"

-- POSSÍVEIS CAUSAS DO PDV NÃO MOSTRAR:

-- 1. CACHE DO BROWSER
-- Solução: Ctrl+F5 no PDV ou limpar cache

-- 2. FILTRO ATIVO NO FRONTEND
-- O PDV pode ter filtros que escondem produtos

-- 3. PAGINAÇÃO
-- Os produtos podem estar em páginas seguintes

-- 4. QUERY DO FRONTEND COM WHERE ESPECÍFICO
-- Frontend pode filtrar por categoria, status, etc.

-- VERIFICAR SE TODOS OS CAMPOS NECESSÁRIOS ESTÃO PREENCHIDOS:
SELECT 
    name,
    description,
    price,
    active,
    stock_quantity,
    category_id
FROM products 
WHERE name LIKE 'ALLIMPORT%'
LIMIT 5;

-- VERIFICAR SE CATEGORIAS EXISTEM (pode ser obrigatório):
SELECT 'CATEGORIAS ALLIMPORT:' as info, COUNT(*) FROM categories WHERE name LIKE 'ALLIMPORT%';

-- ✅ PRÓXIMOS PASSOS PARA RESOLVER:
-- 1. Limpar cache do browser (Ctrl+F5)
-- 2. Verificar filtros na tela de produtos do PDV  
-- 3. Procurar por "ALLIMPORT" na busca do PDV
-- 4. Verificar se há paginação ativa
