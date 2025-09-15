-- Script para corrigir o status dos clientes baseado no backup original
-- TODOS os 141 clientes do backup estavam ativos

BEGIN;

-- 1. Primeiro, vamos verificar quantos clientes temos atualmente
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
  COUNT(CASE WHEN ativo IS NULL THEN 1 END) as sem_status
FROM clientes;

-- 2. Atualizar TODOS os clientes para ativo = true
-- (baseado no fato de que no backup original todos estavam ativos)
UPDATE clientes 
SET ativo = true, 
    atualizado_em = NOW()
WHERE ativo = false OR ativo IS NULL;

-- 3. Verificar o resultado
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM clientes;

-- 4. Mostrar alguns exemplos dos clientes atualizados
SELECT nome, ativo, atualizado_em 
FROM clientes 
ORDER BY atualizado_em DESC 
LIMIT 10;

COMMIT;