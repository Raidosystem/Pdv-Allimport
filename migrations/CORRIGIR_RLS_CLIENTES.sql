-- =============================================
-- CORRIGIR RLS DA TABELA CLIENTES
-- =============================================

-- 1. Remover políticas antigas
DROP POLICY IF EXISTS "Usuários podem inserir seus próprios clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem ver seus próprios clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários podem deletar seus próprios clientes" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;

-- 2. Garantir que RLS está ativado
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas PERMISSIVAS (sem user_id obrigatório)

-- INSERT: Permitir inserção para usuários autenticados
CREATE POLICY "clientes_insert_policy" ON clientes
FOR INSERT
TO authenticated
WITH CHECK (true);

-- SELECT: Permitir leitura para usuários autenticados
CREATE POLICY "clientes_select_policy" ON clientes
FOR SELECT
TO authenticated
USING (true);

-- UPDATE: Permitir atualização para usuários autenticados
CREATE POLICY "clientes_update_policy" ON clientes
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- DELETE: Permitir exclusão para usuários autenticados
CREATE POLICY "clientes_delete_policy" ON clientes
FOR DELETE
TO authenticated
USING (true);

-- 4. Verificar se a coluna user_id existe (caso precise adicionar depois)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE clientes ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE 'Coluna user_id adicionada à tabela clientes';
    END IF;
END $$;

-- 5. Criar trigger para auto-preencher user_id (se a coluna existir)
CREATE OR REPLACE FUNCTION set_user_id_clientes()
RETURNS TRIGGER AS $$
BEGIN
    -- Se user_id não foi fornecido, pegar do usuário autenticado
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS set_user_id_clientes_trigger ON clientes;

-- Criar novo trigger
CREATE TRIGGER set_user_id_clientes_trigger
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION set_user_id_clientes();

-- 6. Verificar políticas criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;
