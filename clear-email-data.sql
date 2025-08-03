-- Script SQL para limpeza completa do email assistenciaallimport10@gmail.com
-- Execute no SQL Editor do Dashboard do Supabase se necessário

-- 1. Verificar se existe o usuário na tabela auth.users
SELECT 
  id, 
  email, 
  email_confirmed_at, 
  created_at,
  updated_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. Remover da tabela clientes (se existir)
DELETE FROM public.clientes 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 3. Remover das vendas relacionadas (se houver)
DELETE FROM public.vendas 
WHERE cliente_email = 'assistenciaallimport10@gmail.com';

-- 4. Remover de ordens de serviço (se houver)
DELETE FROM public.ordens_servico 
WHERE cliente_email = 'assistenciaallimport10@gmail.com';

-- 5. IMPORTANTE: Remover da tabela de autenticação (CUIDADO!)
-- Descomente a linha abaixo APENAS se necessário
-- DELETE FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com';

-- 6. Verificar se foi removido
SELECT 
  'Usuário removido com sucesso' as status,
  COUNT(*) as usuarios_restantes
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 7. Verificar tabelas relacionadas
SELECT 
  'clientes' as tabela,
  COUNT(*) as registros
FROM public.clientes 
WHERE email = 'assistenciaallimport10@gmail.com'

UNION ALL

SELECT 
  'vendas' as tabela,
  COUNT(*) as registros
FROM public.vendas 
WHERE cliente_email = 'assistenciaallimport10@gmail.com'

UNION ALL

SELECT 
  'ordens_servico' as tabela,
  COUNT(*) as registros
FROM public.ordens_servico 
WHERE cliente_email = 'assistenciaallimport10@gmail.com';

-- Resultado esperado: todos os COUNTs devem ser 0
