-- 🔍 DIAGNÓSTICO: Verificar estrutura da tabela ordens_servico
-- Execute no Supabase SQL Editor para verificar se a tabela tem todos os campos

-- 1. Verificar se a tabela existe e sua estrutura
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Verificar constraints
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  ccu.column_name
FROM information_schema.constraint_column_usage ccu
JOIN information_schema.table_constraints tc 
  ON ccu.constraint_name = tc.constraint_name
WHERE ccu.table_name = 'ordens_servico' 
  AND ccu.table_schema = 'public';

-- 3. Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'ordens_servico' AND schemaname = 'public';

-- 4. Listar políticas RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'ordens_servico' AND schemaname = 'public';

-- 5. Testar inserção simples (com campo obrigatório)
INSERT INTO public.ordens_servico (
  numero_os,
  cliente_id,
  status,
  descricao_problema
) VALUES (
  'OS-TEST-001',
  (SELECT id FROM public.clientes LIMIT 1), -- Usar um cliente existente
  'Aberta',
  'Teste de descrição do problema'
);

-- 6. Verificar se foi inserido
SELECT * FROM public.ordens_servico 
WHERE numero_os = 'OS-TEST-001';

-- 7. Limpar teste
DELETE FROM public.ordens_servico 
WHERE numero_os = 'OS-TEST-001';