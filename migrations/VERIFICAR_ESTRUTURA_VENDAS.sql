-- Verificar estrutura da tabela vendas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'vendas'
ORDER BY ordinal_position;
