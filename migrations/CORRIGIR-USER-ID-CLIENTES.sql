-- =====================================================
-- VERIFICAR E CORRIGIR USER_ID DOS CLIENTES
-- =====================================================

-- 1. VERIFICAR SE CLIENTES TÊM USER_ID
SELECT 
  COUNT(*) as total_clientes,
  COUNT(user_id) as com_user_id,
  COUNT(*) - COUNT(user_id) as sem_user_id
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 2. VER AMOSTRA DE CLIENTES SEM USER_ID
SELECT 
  id,
  nome,
  user_id,
  empresa_id,
  created_at
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND user_id IS NULL
LIMIT 5;

-- 3. ATUALIZAR USER_ID DE TODOS OS CLIENTES
-- (Preencher com o empresa_id = user_id do dono)
UPDATE clientes 
SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND (user_id IS NULL OR user_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 4. VERIFICAR CORREÇÃO
SELECT 
  COUNT(*) as total_clientes,
  COUNT(user_id) as com_user_id,
  COUNT(*) - COUNT(user_id) as sem_user_id
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 5. TESTAR SE AGORA A APLICAÇÃO CONSEGUE VER
SELECT 
  id,
  nome,
  telefone,
  cpf_cnpj,
  user_id,
  empresa_id
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Todos os 98 clientes agora têm user_id preenchido
-- - RLS vai permitir acesso porque auth.uid() = user_id
-- - Aplicação vai mostrar os 98 clientes!
-- =====================================================
