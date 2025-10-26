-- =============================================
-- DIAGNÓSTICO COMPLETO DE RLS E PERMISSÕES
-- =============================================

-- 1. Verificar todas as políticas ativas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 2. Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'clientes';

-- 3. Verificar trigger atual
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'clientes';

-- 4. Verificar função do trigger
SELECT 
    proname,
    prosrc,
    prosecdef
FROM pg_proc
WHERE proname = 'set_user_id_clientes';

-- 5. Verificar estrutura da tabela clientes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 6. Testar permissões do usuário atual
SELECT 
    auth.uid() as current_user_id,
    auth.role() as current_role;

-- 7. TESTE DIRETO DE INSERT (comentado - descomente para testar)
-- INSERT INTO clientes (nome, telefone, cpf_cnpj, cpf_digits, tipo, ativo)
-- VALUES ('Teste Diagnóstico', '999999999', '282.196.188-09', '28219618809', 'fisica', true)
-- RETURNING *;
