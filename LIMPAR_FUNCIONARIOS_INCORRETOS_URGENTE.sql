-- =============================================
-- URGENTE: LIMPAR FUNCIONÁRIOS INCORRETOS
-- =============================================
-- Remove funcionários criados incorretamente (usuários de outras empresas)

BEGIN;

-- Ver todos os funcionários atuais
SELECT 
    '⚠️ FUNCIONÁRIOS ATUAIS (ANTES DA LIMPEZA)' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.user_id,
    e.nome as empresa,
    au.email as auth_email
FROM public.funcionarios f
LEFT JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN auth.users au ON f.user_id = au.id
ORDER BY f.created_at;

-- =============================================
-- DELETAR FUNCIONÁRIOS QUE NÃO SÃO DA EMPRESA
-- =============================================

-- Deletar funcionários onde user_id NÃO corresponde ao user_id da empresa
DELETE FROM public.funcionarios
WHERE id IN (
    SELECT f.id
    FROM public.funcionarios f
    INNER JOIN public.empresas e ON f.empresa_id = e.id
    WHERE f.user_id != e.user_id
);

-- =============================================
-- MANTER APENAS FUNCIONÁRIOS LEGÍTIMOS
-- =============================================
-- Cada empresa deve ter apenas funcionários cujo user_id = empresa.user_id
-- OU funcionários criados manualmente pela própria empresa

SELECT 
    '✅ FUNCIONÁRIOS APÓS LIMPEZA' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.user_id,
    e.nome as empresa,
    e.user_id as empresa_owner_user_id,
    CASE 
        WHEN f.user_id = e.user_id THEN '✓ CORRETO'
        ELSE '✗ INCORRETO'
    END as status
FROM public.funcionarios f
INNER JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, f.created_at;

COMMIT;

-- Resumo final
SELECT 
    '📊 RESUMO PÓS-LIMPEZA' as secao;

SELECT 
    e.nome as empresa,
    e.user_id as owner_user_id,
    COUNT(f.id) as total_funcionarios
FROM public.empresas e
LEFT JOIN public.funcionarios f ON e.id = f.empresa_id
GROUP BY e.nome, e.user_id
ORDER BY e.nome;

SELECT '✅ LIMPEZA CONCLUÍDA - APENAS FUNCIONÁRIOS LEGÍTIMOS MANTIDOS' as status;
