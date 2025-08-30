-- ===================================================
-- 🚨 CORREÇÃO URGENTE - PERMISSÕES USER_APPROVALS
-- ===================================================
-- VERSÃO SIMPLIFICADA SEM COMENTÁRIOS

-- 1. Verificar se a tabela existe
SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE tablename = 'user_approvals';

-- 2. Desabilitar RLS temporariamente
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. Dar permissões completas
GRANT ALL ON TABLE user_approvals TO anon;
GRANT ALL ON TABLE user_approvals TO authenticated;
GRANT ALL ON TABLE user_approvals TO service_role;

-- 4. Remover políticas antigas
DROP POLICY IF EXISTS "user_approvals_select_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_insert_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_update_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_delete_policy" ON user_approvals;

-- 5. Criar políticas permissivas
CREATE POLICY "user_approvals_select_policy" ON user_approvals
    FOR SELECT USING (true);

CREATE POLICY "user_approvals_insert_policy" ON user_approvals
    FOR INSERT WITH CHECK (true);

CREATE POLICY "user_approvals_update_policy" ON user_approvals
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "user_approvals_delete_policy" ON user_approvals
    FOR DELETE USING (true);

-- 6. Reabilitar RLS
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 7. Criar constraint UNIQUE no email se não existir
ALTER TABLE user_approvals ADD CONSTRAINT user_approvals_email_unique UNIQUE (email);

-- 8. Remover admin existente e inserir novamente
DELETE FROM user_approvals WHERE email = 'novaradiosystem@outlook.com';

-- 9. Inserir o admin
INSERT INTO user_approvals (email, status, created_at, updated_at)
VALUES (
    'novaradiosystem@outlook.com',
    'approved',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 10. Verificar resultado
SELECT email, status, created_at FROM user_approvals WHERE email = 'novaradiosystem@outlook.com';
