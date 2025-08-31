-- 🗑️ EXCLUSÃO DIRETA - TODAS AS ORDENS DE SERVIÇO
-- Execute este comando diretamente no Supabase SQL Editor

-- Verificar quantas existem ANTES da exclusão
SELECT 
    COUNT(*) as total_ordens_antes_exclusao,
    'Estas ordens serão TODAS excluídas agora' as aviso
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());

-- EXCLUSÃO DIRETA - SEM COMENTÁRIOS
DELETE FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());

-- Verificar se zerou APÓS a exclusão
SELECT 
    COUNT(*) as ordens_restantes_depois,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ SUCESSO! Base zerada completamente!'
        ELSE CONCAT('❌ ERRO! Ainda restam ', COUNT(*), ' ordens')
    END as resultado
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
