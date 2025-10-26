-- =============================================
-- REMOVER TRIGGER PROBLEMÁTICO COMPLETAMENTE
-- =============================================

-- 1. Remover o trigger
DROP TRIGGER IF EXISTS set_user_id_clientes_trigger ON clientes;

-- 2. Remover a função
DROP FUNCTION IF EXISTS set_user_id_clientes();

-- 3. Remover TODOS os outros triggers que possam existir
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS handle_new_user ON auth.users;
DROP TRIGGER IF EXISTS set_empresa_id_trigger ON clientes;

SELECT '✅ Triggers removidos!' as status;

-- 4. Verificar se ainda há triggers
SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('clientes', 'users');

-- 5. Tornar a coluna user_id NULLABLE (caso não seja)
ALTER TABLE clientes ALTER COLUMN user_id DROP NOT NULL;

SELECT '✅ Coluna user_id agora aceita NULL' as status;

-- 6. Verificar a estrutura da coluna user_id
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'clientes'
    AND column_name = 'user_id';
