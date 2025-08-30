-- ===================================================
-- 🚨 CORREÇÃO URGENTE - PERMISSÕES USER_APPROVALS
-- ===================================================
-- Execute este script no SQL Editor do Supabase Dashboard

-- 1. Verificar se a tabela existe
SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE tablename = 'user_approvals';

-- 2. Desabilitar RLS temporariamente para corrigir
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. Dar permissões completas para anon e authenticated
GRANT ALL ON TABLE user_approvals TO anon;
GRANT ALL ON TABLE user_approvals TO authenticated;
GRANT ALL ON TABLE user_approvals TO service_role;

-- 4. Criar políticas permissivas para o anon key poder acessar
DROP POLICY IF EXISTS "user_approvals_select_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_insert_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_update_policy" ON user_approvals;
DROP POLICY IF EXISTS "user_approvals_delete_policy" ON user_approvals;

-- 5. Criar políticas que permitem acesso total
CREATE POLICY "user_approvals_select_policy" ON user_approvals
    FOR SELECT 
    USING (true);

CREATE POLICY "user_approvals_insert_policy" ON user_approvals
    FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "user_approvals_update_policy" ON user_approvals
    FOR UPDATE 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "user_approvals_delete_policy" ON user_approvals
    FOR DELETE 
    USING (true);

-- 6. Reabilitar RLS (agora com políticas permissivas)
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 7. Inserir o admin se não existir
INSERT INTO user_approvals (email, status, created_at, updated_at)
VALUES (
    'novaradiosystem@outlook.com',
    'approved',
    now(),
    now()
)
ON CONFLICT (email) DO UPDATE SET
    status = 'approved',
    updated_at = now();

-- 8. Verificar se funcionou
SELECT * FROM user_approvals WHERE email = 'novaradiosystem@outlook.com';

-- 9. Testar permissões
SELECT 
    schemaname,
    tablename,
    grantee,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'user_approvals';

-- 10. Adicionar comentário na tabela (sintaxe corrigida)
COMMENT ON TABLE user_approvals IS 'Tabela de aprovação de usuários - Corrigida em ' || CURRENT_TIMESTAMP::text;
