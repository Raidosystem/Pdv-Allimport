-- 🔍 VERIFICAÇÃO FINAL - ONDE ESTÃO OS DADOS?

-- 1. CONTAR TOTAL DE PRODUTOS
SELECT 'TOTAL PRODUTOS NO BANCO:' as info, COUNT(*) as quantidade FROM products;

-- 2. VERIFICAR SE PRODUTOS ALLIMPORT FORAM INSERIDOS
SELECT 'PRODUTOS ALLIMPORT:' as info, COUNT(*) as quantidade 
FROM products 
WHERE name LIKE 'ALLIMPORT%' OR name LIKE '%ALLIMPORT%';

-- 3. LISTAR TODOS OS PRODUTOS (para ver o que realmente existe)
SELECT 'LISTA DE TODOS OS PRODUTOS:' as info;
SELECT name, created_at FROM products ORDER BY created_at DESC;

-- 4. BUSCAR POR PALAVRAS-CHAVE DO BACKUP
SELECT 'BUSCA POR WIRELESS/MICROPHONE:' as info;
SELECT name FROM products 
WHERE UPPER(name) LIKE '%WIRELESS%' 
   OR UPPER(name) LIKE '%MICROPHONE%'
   OR UPPER(name) LIKE '%BATERIA%';

-- 5. VERIFICAR ERRO NA INSERÇÃO (se algum comando falhou)
SELECT 'PRODUTOS INSERIDOS HOJE:' as info;
SELECT name, created_at FROM products 
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at DESC;

-- ✅ EXECUTE ESTE SQL E ME MANDE O RESULTADO COMPLETO
-- Vou ver exatamente quantos produtos existem e se os da AllImport foram inseridos
