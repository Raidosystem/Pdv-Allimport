-- 🗑️ ZERAR TODAS AS ORDENS DE SERVIÇO
-- Execute no Supabase SQL Editor

-- PASSO 1: Contar quantas ordens serão excluídas
SELECT 
    COUNT(*) as total_ordens_para_excluir,
    'Todas as ordens de serviço serão removidas' as aviso
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());

-- PASSO 2: EXCLUSÃO TOTAL (descomente para executar)
-- ⚠️ ATENÇÃO: Isso vai excluir TODAS as ordens de serviço!
-- ⚠️ Só execute se tiver certeza!

/*
DELETE FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
*/

-- PASSO 3: Verificar se zerou tudo
SELECT 
    COUNT(*) as ordens_restantes,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Base zerada com sucesso!'
        ELSE '❌ Ainda existem ordens no banco'
    END as status
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
