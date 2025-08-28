-- VERIFICAR SE A CORREÇÃO FOI APLICADA CORRETAMENTE

-- 1. Verificar estrutura da tabela clientes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
AND column_name IN ('user_id', 'usuario_id')
ORDER BY column_name;

-- 2. Verificar se os triggers foram criados
SELECT 
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'clientes'
AND trigger_name LIKE '%user_id%';

-- 3. Verificar se as funções existem
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_name IN ('auto_set_user_id', 'set_default_user_id')
AND routine_schema = 'public';

-- 4. Contar clientes sem user_id/usuario_id
SELECT 
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
    COUNT(CASE WHEN usuario_id IS NULL THEN 1 END) as sem_usuario_id
FROM clientes;

-- 5. Teste de criação de cliente (remover após testar)
/*
INSERT INTO clientes (nome, email, telefone) 
VALUES ('Teste Correção', 'teste@exemplo.com', '11999999999');

-- Verificar se foi criado com user_id
SELECT id, nome, user_id, usuario_id 
FROM clientes 
WHERE nome = 'Teste Correção';

-- Limpar teste
DELETE FROM clientes WHERE nome = 'Teste Correção';
*/

SELECT 'Verificação concluída! Execute o teste de inserção comentado acima para validar.' as status;
