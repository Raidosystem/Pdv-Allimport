-- =============================================
-- VERIFICAR ESTRUTURA DA TABELA BACKUPS
-- =============================================

-- Ver todas as colunas da tabela backups
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'backups'
ORDER BY ordinal_position;

-- Ver a tabela existe?
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_name = 'backups'
) as tabela_existe;
