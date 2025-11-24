-- =============================================
-- DIAGNÓSTICO: POR QUE FUNCIONÁRIOS NÃO SÃO ASSOCIADOS?
-- =============================================

-- 1. Ver se existem funcionários
SELECT 
    '👥 TOTAL DE FUNCIONÁRIOS' as secao;

SELECT COUNT(*) as total_funcionarios FROM public.funcionarios;

-- 2. Ver estrutura da tabela funcionarios
SELECT 
    '📋 ESTRUTURA DA TABELA FUNCIONARIOS' as secao;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 3. Ver todos os funcionários e suas empresas
SELECT 
    '👤 FUNCIONÁRIOS DETALHADOS' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.empresa_id,
    f.funcao_id,
    f.ativo,
    f.created_at,
    e.nome as empresa_nome
FROM public.funcionarios f
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY f.empresa_id, f.created_at;

-- 4. Ver se existe coluna user_id em vez de empresa_id
SELECT 
    '🔍 VERIFICANDO COLUNAS ALTERNATIVAS' as secao;

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'funcionarios'
AND column_name LIKE '%empresa%'
   OR column_name LIKE '%user%'
ORDER BY table_name, column_name;

-- 5. Ver constraints e foreign keys
SELECT 
    '🔗 FOREIGN KEYS DA TABELA FUNCIONARIOS' as secao;

SELECT 
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name = 'funcionarios';
