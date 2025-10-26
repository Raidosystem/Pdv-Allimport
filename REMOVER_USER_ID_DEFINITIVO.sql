-- =============================================
-- SOLUÇÃO EXTREMA: REMOVER COLUNA user_id
-- =============================================

-- Esta é a solução final se NADA mais funcionar
-- O erro "usuario_id" não existe está vindo de algum trigger oculto
-- que não conseguimos encontrar ou remover

-- REMOVER a coluna user_id completamente com CASCADE
ALTER TABLE clientes DROP COLUMN IF EXISTS user_id CASCADE;

SELECT '✅ Coluna user_id REMOVIDA completamente!' as status;

-- Verificar estrutura final
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- Contar clientes
SELECT COUNT(*) as total_clientes FROM clientes;

-- Ver alguns clientes
SELECT 
    id,
    nome,
    telefone,
    cpf_cnpj,
    empresa_id
FROM clientes
ORDER BY nome
LIMIT 5;
