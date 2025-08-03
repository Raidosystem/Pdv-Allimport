-- Script para ajustar as políticas RLS para permitir usuário de teste
-- Execute este script no SQL Editor do Supabase Dashboard

-- 1. Remover políticas antigas
DROP POLICY IF EXISTS "Users can view all ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can insert ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can update ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can delete ordens_servico" ON public.ordens_servico;

-- 2. Criar políticas mais flexíveis que permitem tanto usuários autenticados quanto o usuário de teste
CREATE POLICY "Users can view ordens_servico" 
ON public.ordens_servico FOR SELECT 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can insert ordens_servico" 
ON public.ordens_servico FOR INSERT 
WITH CHECK (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can update ordens_servico" 
ON public.ordens_servico FOR UPDATE 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
)
WITH CHECK (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can delete ordens_servico" 
ON public.ordens_servico FOR DELETE 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

-- 3. Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'ordens_servico';
