-- =============================================
-- REMOVER FOREIGN KEY PROBLEMÁTICA
-- =============================================

-- 1. Remover a foreign key clientes_usuario_id_fkey
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_usuario_id_fkey;

-- 2. Remover outras foreign keys relacionadas a user
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_user_id_fkey;
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS fk_user_id;
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS fk_usuario_id;

SELECT '✅ Foreign keys de usuario_id e user_id removidas!' as status;

-- 3. Verificar se foram removidas
SELECT 
    tc.constraint_name,
    tc.table_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'clientes'
    AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.constraint_name;

-- 4. Ver estrutura da coluna usuario_id (se existir)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'clientes'
    AND (column_name = 'usuario_id' OR column_name = 'user_id')
ORDER BY column_name;

-- 5. Tornar usuario_id nullable (se existir)
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'usuario_id'
    ) THEN
        ALTER TABLE clientes ALTER COLUMN usuario_id DROP NOT NULL;
    END IF;
END $$;

SELECT '✅ Colunas de usuário agora nullable!' as status;

-- 6. Verificar constraints finais
SELECT 
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name = 'clientes'
ORDER BY tc.constraint_type, tc.constraint_name;
