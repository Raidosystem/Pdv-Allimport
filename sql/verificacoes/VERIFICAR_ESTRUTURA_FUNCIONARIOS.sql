-- ============================================
-- VERIFICAR ESTRUTURA DA TABELA FUNCIONARIOS
-- ============================================
-- Este script verifica se a coluna 'status' existe
-- e as políticas RLS relacionadas
-- ============================================

-- 1. VERIFICAR COLUNAS DA TABELA FUNCIONARIOS
SELECT 
    '📋 ESTRUTURA DA TABELA FUNCIONARIOS' as info,
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 2. VERIFICAR SE EXISTE COLUNA STATUS
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'funcionarios' 
            AND column_name = 'status'
        ) THEN '✅ Coluna STATUS existe'
        ELSE '❌ Coluna STATUS NÃO existe'
    END as resultado;

-- 3. VERIFICAR POLÍTICAS RLS NA TABELA FUNCIONARIOS
SELECT 
    '🔒 POLÍTICAS RLS' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'funcionarios';

-- 4. VERIFICAR SE RLS ESTÁ ATIVADO
SELECT 
    '🔒 STATUS RLS' as info,
    schemaname,
    tablename,
    rowsecurity as rls_ativado
FROM pg_tables
WHERE tablename = 'funcionarios';

-- 5. TESTAR UPDATE MANUAL (SIMULAR O QUE O CÓDIGO FAZ)
-- Substitua 'ID_DO_FUNCIONARIO' por um ID real
/*
UPDATE funcionarios 
SET status = 'pausado' 
WHERE id = 'ID_DO_FUNCIONARIO';

SELECT 
    '✅ TESTE DE UPDATE' as info,
    id,
    nome,
    status
FROM funcionarios
WHERE id = 'ID_DO_FUNCIONARIO';
*/

-- 6. VERIFICAR CONSTRAINTS DA COLUNA STATUS
SELECT
    '⚙️ CONSTRAINTS DA COLUNA STATUS' as info,
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'funcionarios'::regclass
  AND conname LIKE '%status%';

-- 7. VERIFICAR VALORES PERMITIDOS
SELECT
    '📝 VALORES ATUAIS DE STATUS' as info,
    status,
    COUNT(*) as quantidade
FROM funcionarios
GROUP BY status
ORDER BY quantidade DESC;
