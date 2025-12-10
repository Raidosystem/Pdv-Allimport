-- =============================================
-- CORRIGIR TRIGGER QUE ACESSA TABELA USERS
-- =============================================

-- 1. Remover trigger problemático
DROP TRIGGER IF EXISTS set_user_id_clientes_trigger ON clientes;
DROP FUNCTION IF EXISTS set_user_id_clientes();

-- 2. Criar função corrigida (SEM acessar tabela users)
CREATE OR REPLACE FUNCTION set_user_id_clientes()
RETURNS TRIGGER AS $$
BEGIN
    -- Se user_id não foi fornecido, pegar APENAS do contexto de autenticação
    -- SEM consultar a tabela users
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER; -- INVOKER ao invés de DEFINER

-- 3. Criar novo trigger
CREATE TRIGGER set_user_id_clientes_trigger
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION set_user_id_clientes();

-- 4. Testar se está funcionando
-- Execute este INSERT para testar:
-- INSERT INTO clientes (nome, telefone) VALUES ('Teste', '999999999');
-- Se funcionar, delete o registro de teste:
-- DELETE FROM clientes WHERE nome = 'Teste';

SELECT 'Trigger corrigido com sucesso!' as status;
