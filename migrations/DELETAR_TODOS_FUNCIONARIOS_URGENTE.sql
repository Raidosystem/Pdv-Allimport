-- =============================================
-- URGENTE: DELETAR TODOS OS FUNCIONÁRIOS CRIADOS INCORRETAMENTE
-- =============================================
-- Remove TODOS os funcionários que foram criados automaticamente pelo script

BEGIN;

-- Ver quantos funcionários serão deletados
SELECT 
    '⚠️ FUNCIONÁRIOS QUE SERÃO DELETADOS' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.user_id,
    e.nome as empresa,
    e.user_id as empresa_owner
FROM public.funcionarios f
INNER JOIN public.empresas e ON f.empresa_id = e.id;

-- =============================================
-- DELETAR TODOS OS FUNCIONÁRIOS
-- =============================================
-- Cada empresa deve criar seus próprios funcionários manualmente
-- através da interface do sistema

DELETE FROM public.funcionarios;

-- =============================================
-- VERIFICAR RESULTADO
-- =============================================

SELECT 
    '✅ FUNCIONÁRIOS DELETADOS' as secao;

SELECT 
    e.nome as empresa,
    COUNT(f.id) as total_funcionarios
FROM public.empresas e
LEFT JOIN public.funcionarios f ON e.id = f.empresa_id
GROUP BY e.nome;

COMMIT;

SELECT '✅ LIMPEZA COMPLETA - Agora cada empresa pode criar seus próprios funcionários' as status;
