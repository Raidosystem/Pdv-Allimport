-- =============================================
-- VERIFICAR ESTRUTURA DAS TABELAS
-- =============================================

-- Verificar colunas da tabela clientes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- Verificar colunas da tabela produtos
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- Verificar colunas da tabela ordens_servico
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;
