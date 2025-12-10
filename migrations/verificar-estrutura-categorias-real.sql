-- Verificar estrutura REAL da tabela categorias
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'categorias'
ORDER BY ordinal_position;

-- Verificar estrutura da tabela categories (para comparação)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;
