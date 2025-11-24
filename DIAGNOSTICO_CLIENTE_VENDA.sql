-- ============================================
-- DIAGNÓSTICO - CLIENTE DA VENDA
-- ============================================

-- 1. Procurar por clientes com nome parecido com "Cliente da Venda" ou "Consumidor Final"
SELECT 
    id, 
    nome, 
    empresa_id, 
    user_id 
FROM clientes 
WHERE nome ILIKE '%Cliente%' OR nome ILIKE '%Consumidor%';

-- 2. Verificar quantos clientes existem para cada empresa
SELECT 
    empresa_id, 
    COUNT(*) as total_clientes 
FROM clientes 
GROUP BY empresa_id;

-- 3. Verificar se existem clientes sem empresa_id (Orfãos)
SELECT 
    id, 
    nome, 
    user_id 
FROM clientes 
WHERE empresa_id IS NULL;
