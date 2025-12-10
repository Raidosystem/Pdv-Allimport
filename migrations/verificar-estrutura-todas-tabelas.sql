-- Verificar estrutura das tabelas relacionadas
SELECT 'vendas' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'vendas'
ORDER BY ordinal_position;

SELECT 'produtos' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

SELECT 'clientes' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

SELECT 'funcionarios' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

SELECT 'caixa' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'caixa'
ORDER BY ordinal_position;

SELECT 'ordens_servico' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;

SELECT 'funcoes' as tabela, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'funcoes'
ORDER BY ordinal_position;
