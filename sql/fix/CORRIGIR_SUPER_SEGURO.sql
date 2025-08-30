-- ===================================================
-- 🚨 CORREÇÃO SUPER SEGURA - USER_APPROVALS
-- ===================================================

-- 1. Verificar se a tabela existe
SELECT 'Tabela user_approvals encontrada' as status 
FROM pg_tables 
WHERE tablename = 'user_approvals';

-- 2. Desabilitar RLS
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. Dar permissões
GRANT ALL ON TABLE user_approvals TO anon;
GRANT ALL ON TABLE user_approvals TO authenticated;
GRANT ALL ON TABLE user_approvals TO service_role;

-- 4. Remover políticas antigas (ignorar se não existirem)
DROP POLICY IF EXISTS "user_approvals_select_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_insert_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_update_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_delete_policy" ON user_approvals;

-- 5. Criar políticas simples
CREATE POLICY "user_approvals_select_policy" ON user_approvals FOR SELECT USING (true);
CREATE POLICY "user_approvals_insert_policy" ON user_approvals FOR INSERT WITH CHECK (true);
CREATE POLICY "user_approvals_update_policy" ON user_approvals FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "user_approvals_delete_policy" ON user_approvals FOR DELETE USING (true);

-- 6. Reabilitar RLS
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 7. Tentar adicionar constraint UNIQUE (ignorar se já existir)
DO $$ 
BEGIN
    ALTER TABLE user_approvals ADD CONSTRAINT user_approvals_email_unique UNIQUE (email);
    RAISE NOTICE 'Constraint UNIQUE adicionada com sucesso';
EXCEPTION 
    WHEN duplicate_object THEN
        RAISE NOTICE 'Constraint UNIQUE já existe - continuando...';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao criar constraint: %', SQLERRM;
END $$;

-- 8. Verificar se admin já existe
DO $$
DECLARE
    admin_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO admin_exists 
    FROM user_approvals 
    WHERE email = 'novaradiosystem@outlook.com';
    
    IF admin_exists > 0 THEN
        -- Admin existe, atualizar
        UPDATE user_approvals 
        SET status = 'approved', updated_at = CURRENT_TIMESTAMP 
        WHERE email = 'novaradiosystem@outlook.com';
        RAISE NOTICE 'Admin atualizado com sucesso';
    ELSE
        -- Admin não existe, inserir
        INSERT INTO user_approvals (email, status, created_at, updated_at)
        VALUES ('novaradiosystem@outlook.com', 'approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        RAISE NOTICE 'Admin inserido com sucesso';
    END IF;
END $$;

-- 9. Verificar resultado final
SELECT 
    email, 
    status, 
    created_at,
    'SUCESSO - Admin configurado!' as resultado
FROM user_approvals 
WHERE email = 'novaradiosystem@outlook.com';
