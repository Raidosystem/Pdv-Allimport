-- =====================================================
-- VALIDAÇÃO DE CATEGORIA NO BANCO DE DADOS
-- Este é o SQL que o código TypeScript executa
-- =====================================================

-- Este comando valida se uma categoria existe
-- Substitua o UUID abaixo pelo que você quer testar

SELECT id 
FROM categories
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
LIMIT 1;

-- Se retornar 0 linhas = categoria não existe ❌
-- Se retornar 1 linha = categoria existe ✅

-- =====================================================
-- TESTE: Verifique uma categoria válida
-- =====================================================

SELECT id, name
FROM categories
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name
LIMIT 5;

-- Este comando deve retornar 5 categorias válidas
