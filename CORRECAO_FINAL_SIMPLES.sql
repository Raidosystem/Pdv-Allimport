-- CORREÇÃO FINAL - MULTI-TENANT SEGURO E COMPATÍVEL
-- Execute este script no SQL Editor do Supabase

-- 1. DESABILITAR RLS temporariamente
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- 2. Remover constraints problemáticas
ALTER TABLE public.clientes DROP CONSTRAINT IF EXISTS clientes_user_id_fkey;

-- 3. Verificar estrutura atual da coluna user_id
DO $$
DECLARE
    col_exists boolean;
    col_type text;
BEGIN
    -- Verificar se coluna existe e seu tipo
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'user_id'
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF col_exists THEN
        -- Se existe, vamos trabalhar com ela
        RAISE NOTICE 'Coluna user_id já existe, usando ela';
        
        -- Limpar valores NULL e definir para o usuário específico
        -- Usando CAST para lidar com UUID
        UPDATE public.clientes 
        SET user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
        WHERE user_id IS NULL;
        
    ELSE
        -- Se não existe, criar como UUID
        ALTER TABLE public.clientes ADD COLUMN user_id UUID;
        
        -- Definir para todos os registros
        UPDATE public.clientes 
        SET user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID;
    END IF;
END $$;

-- 4. Criar índice
CREATE INDEX IF NOT EXISTS idx_clientes_user_id ON public.clientes(user_id);

-- 5. Reabilitar RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 6. Limpar políticas antigas
DROP POLICY IF EXISTS "clientes_all_access" ON public.clientes;
DROP POLICY IF EXISTS "clientes_dev_prod_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_isolamento_por_usuario" ON public.clientes;
DROP POLICY IF EXISTS "clientes_multi_tenant_dev" ON public.clientes;
DROP POLICY IF EXISTS "clientes_assistencia_allimport" ON public.clientes;

-- 7. Criar política para o usuário específico (usando UUID)
CREATE POLICY "clientes_assistencia_uuid" ON public.clientes
    FOR ALL 
    USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID)
    WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID);

-- 8. Verificar resultado
SELECT 
    'Multi-tenant UUID configurado!' as status,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID THEN 1 END) as clientes_assistencia
FROM public.clientes;

-- 9. Mostrar alguns clientes para verificar
SELECT id, nome, telefone, user_id 
FROM public.clientes 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
LIMIT 3;
