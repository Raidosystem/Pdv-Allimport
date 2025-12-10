-- 🛡️ VERIFICAR RLS: Políticas de segurança da tabela clientes
-- Execute no Supabase SQL Editor para verificar políticas

-- 1. Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'clientes' AND schemaname = 'public';

-- 2. Listar todas as políticas da tabela clientes
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
WHERE tablename = 'clientes' AND schemaname = 'public';

-- 3. Verificar se há triggers que podem estar causando problemas
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'clientes';

-- 4. Testar inserção simples
INSERT INTO public.clientes (nome, tipo, ativo) 
VALUES ('Teste Simples', 'Física', true);

-- 5. Verificar se foi inserido
SELECT id, nome, created_at FROM public.clientes 
WHERE nome = 'Teste Simples';

-- 6. Limpar teste
DELETE FROM public.clientes WHERE nome = 'Teste Simples';