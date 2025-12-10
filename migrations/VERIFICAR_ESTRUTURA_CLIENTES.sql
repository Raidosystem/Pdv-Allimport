-- =============================================
-- VERIFICAR ESTRUTURA E DADOS DA TABELA CLIENTES
-- =============================================

-- Ver estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- Ver alguns clientes com endereço
SELECT 
    id,
    nome,
    endereco,
    rua,
    numero,
    cidade,
    estado,
    cep
FROM clientes
WHERE nome ILIKE '%cristiano%'
   OR nome ILIKE '%josliana%'
   OR nome ILIKE '%flavia%'
LIMIT 5;
