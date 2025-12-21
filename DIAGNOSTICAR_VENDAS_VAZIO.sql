-- =====================================================
-- DIAGNOSTICAR POR QUE RELATÓRIOS RETORNAM 0 VENDAS
-- =====================================================

-- 1️⃣ VERIFICAR SE EXISTEM VENDAS NA TABELA
SELECT 
  COUNT(*) as total_vendas,
  COUNT(DISTINCT user_id) as total_usuarios_distintos,
  MIN(data_venda) as primeira_venda,
  MAX(data_venda) as ultima_venda
FROM vendas;

-- 2️⃣ VER ALGUMAS VENDAS DE EXEMPLO
SELECT 
  id,
  user_id,
  cliente_id,
  total,
  data_venda,
  forma_pagamento
FROM vendas
ORDER BY data_venda DESC
LIMIT 5;

-- 3️⃣ VERIFICAR RLS DA TABELA VENDAS
SELECT 
  schemaname,
  tablename,
  rowsecurity as "RLS Habilitado"
FROM pg_tables 
WHERE tablename = 'vendas'
  AND schemaname = 'public';

-- 4️⃣ VER POLÍTICAS RLS ATUAIS DA TABELA VENDAS
SELECT 
  policyname as "Política",
  cmd as "Operação",
  qual as "Condição",
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN 'Permissiva'
    ELSE 'Restritiva'
  END as "Tipo"
FROM pg_policies
WHERE tablename = 'vendas'
ORDER BY policyname;

-- 5️⃣ VERIFICAR VENDAS DO USUÁRIO ATUAL
-- Substitua 'SEU_USER_ID' pelo user_id do console
SELECT 
  COUNT(*) as vendas_do_usuario,
  SUM(total) as valor_total,
  MIN(data_venda) as primeira,
  MAX(data_venda) as ultima
FROM vendas
WHERE user_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73';

-- 6️⃣ VER VENDAS RECENTES DO USUÁRIO
SELECT 
  id,
  total,
  data_venda,
  forma_pagamento,
  status
FROM vendas
WHERE user_id = '8adef71b-1cde-47f2-baa5-a4b25fd71b73'
ORDER BY data_venda DESC
LIMIT 10;

-- 7️⃣ VERIFICAR SE TABELA vendas_itens TAMBÉM TEM DADOS
SELECT 
  COUNT(*) as total_itens,
  COUNT(DISTINCT venda_id) as vendas_com_itens
FROM vendas_itens;
