-- SOLUÇÃO RLS - Permitir acesso público aos produtos
-- User ID: 28e56a69-90df-4852-b663-9b02f4358c6f

-- OPÇÃO 1: Desabilitar RLS temporariamente (TESTE)
-- ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;

-- OPÇÃO 2: Criar política pública para produtos (RECOMENDADO)
-- Remover políticas restritivas e criar uma pública

-- Remover políticas existentes
DROP POLICY IF EXISTS "users_select_own_data" ON public.produtos;
DROP POLICY IF EXISTS "users_insert_own_data" ON public.produtos;
DROP POLICY IF EXISTS "users_update_own_data" ON public.produtos;
DROP POLICY IF EXISTS "users_delete_own_data" ON public.produtos;
DROP POLICY IF EXISTS "Users can only see own produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can only insert own produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can only update own produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can only delete own produtos" ON public.produtos;
DROP POLICY IF EXISTS "rls_isolamento_produtos" ON public.produtos;

-- Criar políticas públicas (permite acesso sem login)
CREATE POLICY "public_select_produtos" ON public.produtos
    FOR SELECT USING (true);

CREATE POLICY "public_insert_produtos" ON public.produtos
    FOR INSERT WITH CHECK (true);

CREATE POLICY "public_update_produtos" ON public.produtos
    FOR UPDATE USING (true);

CREATE POLICY "public_delete_produtos" ON public.produtos
    FOR DELETE USING (true);

-- Verificar se funcionou
SELECT 'TESTE APÓS CORREÇÃO RLS' as status;
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';
SELECT nome, preco FROM public.produtos WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f' ORDER BY nome LIMIT 5;
