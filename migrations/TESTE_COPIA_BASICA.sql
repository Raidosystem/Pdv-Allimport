-- 🛠️ MÉTODO ULTRA SEGURO: CÓPIA PRODUTO POR PRODUTO

-- Este método copia apenas com colunas básicas que certamente existem

-- MÉTODO 1: Cópia básica (id, nome)
INSERT INTO produtos (id, nome)
SELECT id, name as nome
FROM products 
WHERE name LIKE 'ALLIMPORT%'
LIMIT 5; -- Apenas 5 para testar primeiro

-- VERIFICAR SE FUNCIONOU
SELECT 'TESTE COM 5 PRODUTOS:' as info, COUNT(*) as total 
FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- Se funcionou, execute o resto:
-- INSERT INTO produtos (id, nome)
-- SELECT id, name as nome
-- FROM products 
-- WHERE name LIKE 'ALLIMPORT%'
-- AND id NOT IN (SELECT id FROM produtos WHERE nome LIKE 'ALLIMPORT%');

-- MÉTODO 2: Se a tabela produtos tem estrutura diferente
-- Primeiro veja quais colunas existem com:
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'produtos';

-- ✅ EXECUTE ESTE TESTE PRIMEIRO E ME DIGA SE FUNCIONA!
