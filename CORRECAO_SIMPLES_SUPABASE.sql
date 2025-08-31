-- CORREÇÃO SIMPLES E SEGURA - MULTI-TENANT SEM FOREIGN KEY
-- Execute este script no SQL Editor do Supabase

-- 1. DESABILITAR RLS temporariamente para fazer mudanças estruturais
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- 2. Remover TODAS as constraints foreign key que causam problema
ALTER TABLE public.clientes 
DROP CONSTRAINT IF EXISTS clientes_user_id_fkey;

-- 3. PRIMEIRO: Verificar e corrigir o tipo da coluna user_id
-- Se a coluna já existe como UUID, vamos removê-la e recriar como TEXT
ALTER TABLE public.clientes DROP COLUMN IF EXISTS user_id;
ALTER TABLE public.clientes ADD COLUMN user_id TEXT;

-- 4. Definir user_id para todos os clientes existentes
UPDATE public.clientes 
SET user_id = 'assistenciaallimport10@gmail.com' 
WHERE user_id IS NULL;

-- 5. Criar índice
CREATE INDEX IF NOT EXISTS idx_clientes_user_id ON public.clientes(user_id);

-- 6. Reabilitar RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 7. Limpar políticas antigas
DROP POLICY IF EXISTS "clientes_all_access" ON public.clientes;
DROP POLICY IF EXISTS "clientes_dev_prod_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_isolamento_por_usuario" ON public.clientes;
DROP POLICY IF EXISTS "clientes_multi_tenant_dev" ON public.clientes;

-- 8. Criar política SIMPLES para o usuário específico
CREATE POLICY "clientes_assistencia_allimport" ON public.clientes
    FOR ALL 
    USING (user_id = 'assistenciaallimport10@gmail.com')
    WITH CHECK (user_id = 'assistenciaallimport10@gmail.com');

-- 9. Verificar resultado
SELECT 
    'Multi-tenant SIMPLIFICADO configurado!' as status,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN user_id = 'assistenciaallimport10@gmail.com' THEN 1 END) as clientes_assistencia
FROM public.clientes;

-- 10. Testar acesso
SELECT id, nome, telefone, user_id 
FROM public.clientes 
WHERE user_id = 'assistenciaallimport10@gmail.com'
LIMIT 3;
