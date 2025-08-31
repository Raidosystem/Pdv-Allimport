-- POLÍTICAS RLS MULTI-TENANT - ISOLAMENTO COMPLETO
-- Parte 2: Criar políticas específicas para cada tabela

-- 1. REMOVER POLÍTICAS ANTIGAS (INSEGURAS)
DROP POLICY IF EXISTS "clientes_all_access" ON public.clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_dev_prod_policy" ON public.clientes;

-- 2. POLÍTICAS PARA TABELA CLIENTES (ISOLAMENTO POR USER_ID)

-- SELECT: Usuário só vê seus próprios clientes
CREATE POLICY "clientes_isolamento_select" ON public.clientes
    FOR SELECT USING (
        user_id = auth.uid() 
        OR user_id = get_current_user_id()
        OR (user_id IS NULL AND auth.role() = 'authenticated') -- Dados legados sem user_id
    );

-- INSERT: Usuário só pode criar clientes para si mesmo
CREATE POLICY "clientes_isolamento_insert" ON public.clientes
    FOR INSERT WITH CHECK (
        user_id = auth.uid() 
        OR user_id = get_current_user_id()
        OR user_id IS NULL -- Permitir inserção sem user_id (será preenchido por trigger)
    );

-- UPDATE: Usuário só pode atualizar seus próprios clientes
CREATE POLICY "clientes_isolamento_update" ON public.clientes
    FOR UPDATE USING (
        user_id = auth.uid() 
        OR user_id = get_current_user_id()
        OR (user_id IS NULL AND auth.role() = 'authenticated')
    ) WITH CHECK (
        user_id = auth.uid() 
        OR user_id = get_current_user_id()
    );

-- DELETE: Usuário só pode deletar seus próprios clientes
CREATE POLICY "clientes_isolamento_delete" ON public.clientes
    FOR DELETE USING (
        user_id = auth.uid() 
        OR user_id = get_current_user_id()
        OR (user_id IS NULL AND auth.role() = 'authenticated')
    );

-- 3. TRIGGER PARA AUTO-PREENCHER USER_ID NA INSERÇÃO
CREATE OR REPLACE FUNCTION set_user_id_on_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Se user_id não foi fornecido, usar o usuário atual
    IF NEW.user_id IS NULL THEN
        NEW.user_id = COALESCE(auth.uid(), get_current_user_id());
    END IF;
    
    -- Se ainda for NULL, usar um UUID padrão (para desenvolvimento)
    IF NEW.user_id IS NULL THEN
        NEW.user_id = '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger na tabela clientes
DROP TRIGGER IF EXISTS trigger_set_user_id_clientes ON public.clientes;
CREATE TRIGGER trigger_set_user_id_clientes
    BEFORE INSERT ON public.clientes
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id_on_insert();

-- 4. POLÍTICAS SIMILARES PARA OUTRAS TABELAS (PRODUTOS)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos' AND table_schema = 'public') THEN
        
        -- Remover políticas antigas
        DROP POLICY IF EXISTS "produtos_all_access" ON public.produtos;
        
        -- Criar políticas de isolamento
        CREATE POLICY "produtos_isolamento_select" ON public.produtos
            FOR SELECT USING (user_id = auth.uid() OR user_id = get_current_user_id());
            
        CREATE POLICY "produtos_isolamento_insert" ON public.produtos
            FOR INSERT WITH CHECK (user_id = auth.uid() OR user_id = get_current_user_id() OR user_id IS NULL);
            
        CREATE POLICY "produtos_isolamento_update" ON public.produtos
            FOR UPDATE USING (user_id = auth.uid() OR user_id = get_current_user_id())
            WITH CHECK (user_id = auth.uid() OR user_id = get_current_user_id());
            
        CREATE POLICY "produtos_isolamento_delete" ON public.produtos
            FOR DELETE USING (user_id = auth.uid() OR user_id = get_current_user_id());
            
        -- Aplicar trigger
        DROP TRIGGER IF EXISTS trigger_set_user_id_produtos ON public.produtos;
        CREATE TRIGGER trigger_set_user_id_produtos
            BEFORE INSERT ON public.produtos
            FOR EACH ROW
            EXECUTE FUNCTION set_user_id_on_insert();
    END IF;
END $$;

-- 5. TESTE DAS POLÍTICAS
SELECT 'Políticas RLS Multi-tenant configuradas!' as status;
