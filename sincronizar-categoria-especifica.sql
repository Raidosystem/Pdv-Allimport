-- Sincronizar a categoria específica que está causando o erro
-- UUID: ba8e7253-6b02-4a1c-b3c8-77ff78618514

-- Verificar se existe em categories
SELECT 'Buscando em categories' as operacao;
SELECT id, name, empresa_id FROM categories WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- Verificar se existe em categorias  
SELECT 'Buscando em categorias' as operacao;
SELECT id, nome FROM categorias WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- Sincronizar a categoria para categorias (se não existir)
-- Ajustando para colunas corretas (sem timestamps que não existem)
INSERT INTO categorias (id, nome, descricao)
SELECT id, name, description
FROM categories 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'
AND NOT EXISTS (
  SELECT 1 FROM categorias WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'
);

-- Verificar resultado
SELECT 'Verificação final' as operacao;
SELECT id, nome FROM categorias WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';
