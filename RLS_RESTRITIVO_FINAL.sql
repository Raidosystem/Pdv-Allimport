-- CORRIGIR RLS PARA ISOLAMENTO COMPLETO
-- Remover políticas existentes e criar políticas restritivas

DO $$
BEGIN
    -- Remover todas as políticas existentes
    DROP POLICY IF EXISTS "clientes_isolamento_simples" ON public.clientes;
    DROP POLICY IF EXISTS "produtos_isolamento_simples" ON public.produtos;
    
    -- Criar políticas realmente restritivas (apenas usuários autenticados)
    
    -- POLÍTICA PARA CLIENTES - Só vê os próprios clientes
    CREATE POLICY "clientes_usuario_autenticado" ON public.clientes
        FOR ALL 
        TO authenticated 
        USING (user_id = auth.uid());

    -- POLÍTICA PARA PRODUTOS - Só vê os próprios produtos  
    CREATE POLICY "produtos_usuario_autenticado" ON public.produtos
        FOR ALL
        TO authenticated
        USING (user_id = auth.uid());

    -- Garantir que RLS está ativado
    ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
    
    -- Remover acesso para usuários anônimos (não autenticados)
    REVOKE ALL ON public.clientes FROM anon;
    REVOKE ALL ON public.produtos FROM anon;
    
    RAISE NOTICE 'RLS RESTRITIVO APLICADO - Apenas usuários autenticados podem ver seus próprios dados';
    
END $$;
