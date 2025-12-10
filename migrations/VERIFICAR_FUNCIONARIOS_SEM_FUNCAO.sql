-- =============================================
-- VERIFICAR E ASSOCIAR FUNCIONÁRIOS ÀS FUNÇÕES
-- =============================================

-- Ver funcionários sem função atribuída
SELECT 
    '👤 FUNCIONÁRIOS SEM FUNÇÃO' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.empresa_id,
    e.nome as empresa,
    f.funcao_id,
    f.ativo,
    f.created_at
FROM public.funcionarios f
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, f.created_at;

-- Contar funcionários por empresa
SELECT 
    '📊 TOTAL DE FUNCIONÁRIOS POR EMPRESA' as secao;

SELECT 
    e.nome as empresa,
    COUNT(f.id) as total_funcionarios,
    COUNT(f.funcao_id) as com_funcao,
    COUNT(*) FILTER (WHERE f.funcao_id IS NULL) as sem_funcao
FROM public.empresas e
LEFT JOIN public.funcionarios f ON e.id = f.empresa_id
GROUP BY e.nome;

-- Ver funções disponíveis por empresa
SELECT 
    '🎯 FUNÇÕES DISPONÍVEIS POR EMPRESA' as secao;

SELECT 
    e.nome as empresa,
    f.nome as funcao,
    f.id as funcao_id,
    f.nivel
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, f.nivel;
