-- 🔍 DIAGNÓSTICO: Verificar estrutura da tabela clientes
-- Execute no Supabase SQL Editor para verificar se a tabela tem todos os campos

-- 1. Verificar se a tabela existe e sua estrutura
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'clientes' 
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
WHERE ccu.table_name = 'clientes' 
  AND ccu.table_schema = 'public';

-- 3. Tentar inserir um cliente de teste (apenas campos que existem)
INSERT INTO public.clientes (
  nome,
  cpf_cnpj,
  cpf_digits,
  email,
  telefone,
  endereco,
  empresa_id,
  tipo,
  ativo
) VALUES (
  'Teste Cliente Sem CPF',
  NULL,
  NULL,
  'teste@email.com',
  '11999887766',
  'Rua Teste, 123 - São Paulo/SP',
  NULL,
  'Física',
  true
);

-- 4. Verificar se foi inserido
SELECT * FROM public.clientes 
WHERE nome = 'Teste Cliente Sem CPF';

-- 5. Limpar teste
DELETE FROM public.clientes 
WHERE nome = 'Teste Cliente Sem CPF';