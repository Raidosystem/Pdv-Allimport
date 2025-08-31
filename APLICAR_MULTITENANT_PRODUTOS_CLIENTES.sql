-- APLICAR MULTI-TENANT PARA PRODUTOS E CORRIGIR CLIENTES
-- Execute este script no SQL Editor do Supabase

-- ==================== PARTE 1: CORRIGIR PRODUTOS ====================

-- 1. DESABILITAR RLS temporariamente na tabela produtos
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;

-- 2. Remover constraints problemáticas
ALTER TABLE public.produtos DROP CONSTRAINT IF EXISTS produtos_user_id_fkey;

-- 3. Adicionar coluna user_id na tabela produtos
DO $$
DECLARE
    col_exists boolean;
BEGIN
    -- Verificar se coluna existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' 
        AND column_name = 'user_id'
        AND table_schema = 'public'
    ) INTO col_exists;
    
    IF col_exists THEN
        RAISE NOTICE 'Coluna user_id já existe na tabela produtos';
        -- Atualizar produtos existentes para o usuário específico
        UPDATE public.produtos 
        SET user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
        WHERE user_id IS NULL;
    ELSE
        -- Criar coluna user_id
        ALTER TABLE public.produtos ADD COLUMN user_id UUID;
        -- Definir para todos os produtos existentes
        UPDATE public.produtos 
        SET user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID;
        RAISE NOTICE 'Coluna user_id criada na tabela produtos';
    END IF;
END $$;

-- 4. Criar índice para produtos
CREATE INDEX IF NOT EXISTS idx_produtos_user_id ON public.produtos(user_id);

-- 5. Reabilitar RLS para produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

-- 6. Limpar políticas antigas de produtos
DROP POLICY IF EXISTS "produtos_all_access" ON public.produtos;
DROP POLICY IF EXISTS "produtos_dev_policy" ON public.produtos;
DROP POLICY IF EXISTS "produtos_isolamento" ON public.produtos;

-- 7. Criar política para produtos (usuário específico)
CREATE POLICY "produtos_assistencia_uuid" ON public.produtos
    FOR ALL 
    USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID)
    WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID);

-- ==================== PARTE 2: CORRIGIR CLIENTES (MAIS RESTRITIVO) ====================

-- 8. Reforçar política de clientes (remover política permissiva)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- 9. Limpar TODAS as políticas de clientes
DROP POLICY IF EXISTS "clientes_all_access" ON public.clientes;
DROP POLICY IF EXISTS "clientes_dev_prod_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_isolamento_por_usuario" ON public.clientes;
DROP POLICY IF EXISTS "clientes_multi_tenant_dev" ON public.clientes;
DROP POLICY IF EXISTS "clientes_assistencia_allimport" ON public.clientes;
DROP POLICY IF EXISTS "clientes_assistencia_uuid" ON public.clientes;

-- 10. Reabilitar RLS para clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 11. Criar política RESTRITIVA para clientes (apenas usuário específico)
CREATE POLICY "clientes_apenas_assistencia" ON public.clientes
    FOR ALL 
    USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID)
    WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID);

-- ==================== VERIFICAÇÕES FINAIS ====================

-- 12. Verificar produtos
SELECT 
    'Produtos configurados!' as status,
    COUNT(*) as total_produtos,
    COUNT(CASE WHEN user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID THEN 1 END) as produtos_assistencia
FROM public.produtos;

-- 13. Verificar clientes
SELECT 
    'Clientes reconfigurados!' as status,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID THEN 1 END) as clientes_assistencia
FROM public.clientes;

-- 14. Mostrar alguns registros para verificar
SELECT 'PRODUTOS:' as tipo, id, nome, preco, user_id 
FROM public.produtos 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
LIMIT 3

UNION ALL

SELECT 'CLIENTES:' as tipo, id, nome, telefone::text as preco, user_id 
FROM public.clientes 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
LIMIT 3;
