-- ============================================
-- SCRIPT PARA REMOVER TABELA service_orders OBSOLETA
-- ============================================
-- Esta tabela não está sendo usada pelo sistema atual

-- 1. Verificar se a tabela existe e quantos registros tem
SELECT 
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_name = 'service_orders';

-- 2. Ver quantos registros existem (se houver)
SELECT COUNT(*) as total_registros FROM service_orders;

-- 3. Ver alguns registros para confirmar que não é importante (opcional)
SELECT * FROM service_orders LIMIT 5;

-- 4. DELETAR A TABELA (descomente quando tiver certeza)
-- DROP TABLE IF EXISTS service_orders;

-- 5. Verificar se foi removida (não deve aparecer mais)
-- SELECT table_name FROM information_schema.tables WHERE table_name = 'service_orders';
