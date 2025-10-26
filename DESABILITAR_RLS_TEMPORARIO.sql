-- =============================================
-- DESABILITAR RLS TEMPORARIAMENTE
-- =============================================

-- 1. DESABILITAR RLS
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;

SELECT '⚠️ RLS DESABILITADO - Todos os usuários podem ver todos os clientes!' as status;

-- 2. Verificar
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'clientes';

-- 3. Contar clientes
SELECT COUNT(*) as total_clientes FROM clientes;

-- 4. Ver alguns clientes
SELECT 
    id,
    nome,
    telefone,
    cpf_cnpj,
    empresa_id,
    user_id
FROM clientes
ORDER BY nome
LIMIT 5;
