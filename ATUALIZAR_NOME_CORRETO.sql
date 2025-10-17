-- ============================================
-- ATUALIZAR NOME DA EMPRESA PARA O USER_ID CORRETO
-- ============================================

-- 1. Verificar o nome atual
SELECT 
  id,
  nome,
  cnpj,
  email,
  user_id
FROM empresas
WHERE user_id = '28230691-00a7-45e7-a6d6-ff79fd0fac89';

-- 2. Atualizar o nome da empresa
UPDATE empresas
SET nome = 'Assistência All-Import'  -- MUDE AQUI PARA O NOME DA SUA EMPRESA
WHERE user_id = '28230691-00a7-45e7-a6d6-ff79fd0fac89';

-- 3. Verificar se foi atualizado
SELECT 
  id,
  nome,
  cnpj,
  email,
  user_id,
  updated_at
FROM empresas
WHERE user_id = '28230691-00a7-45e7-a6d6-ff79fd0fac89';
