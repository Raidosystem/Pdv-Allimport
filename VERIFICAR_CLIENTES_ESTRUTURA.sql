-- CONSULTA SQL SIMPLES: Verificar estrutura da tabela clientes
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'clientes'
AND table_schema = 'public'
ORDER BY ordinal_position;
