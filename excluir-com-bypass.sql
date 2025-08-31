-- 🔧 EXCLUSÃO COM BYPASS RLS (se o método normal não funcionar)
-- Execute no Supabase SQL Editor

-- Verificar quantas ordens existem
SELECT COUNT(*) as total_ordens FROM ordens_servico;

-- Método 1: Exclusão normal
DELETE FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());

-- SE NÃO FUNCIONAR, use o Método 2: Bypass RLS (descomente abaixo)
/*
-- MÉTODO 2: Bypass temporário do RLS
SET session_replication_role = replica;
DELETE FROM ordens_servico WHERE usuario_id = (SELECT auth.uid());
SET session_replication_role = DEFAULT;
*/

-- Verificar resultado final
SELECT 
    COUNT(*) as ordens_restantes,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Exclusão bem-sucedida!'
        ELSE '❌ Ainda existem ordens - usar método 2'
    END as status
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
