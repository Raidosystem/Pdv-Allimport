-- ============================================
-- DIAGNÓSTICO COMPLETO - TABELA VENDAS
-- ============================================

-- 1️⃣ Ver estrutura completa da tabela vendas
SELECT 
    '📋 ESTRUTURA DA TABELA VENDAS' as info,
    column_name as coluna,
    data_type as tipo,
    is_nullable as pode_ser_nulo,
    column_default as valor_padrao
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'vendas'
ORDER BY ordinal_position;

-- 2️⃣ Ver constraints e chaves estrangeiras
SELECT 
    '🔑 CONSTRAINTS E FOREIGN KEYS' as info,
    constraint_name as nome_constraint,
    constraint_type as tipo
FROM information_schema.table_constraints
WHERE table_schema = 'public' 
AND table_name = 'vendas';

-- 3️⃣ Verificar se empresa_id existe
SELECT 
    '🏢 VERIFICAR EMPRESA_ID' as info,
    EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'vendas' 
        AND column_name = 'empresa_id'
    ) as empresa_id_existe;

-- 4️⃣ Verificar RLS policies
SELECT 
    '🔒 POLÍTICAS RLS' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd as comando,
    qual as usando_expressao,
    with_check as com_check_expressao
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'vendas';

-- 5️⃣ Verificar se trigger auto_fill existe
SELECT 
    '⚡ TRIGGERS ATIVOS' as info,
    trigger_name,
    event_manipulation as evento,
    action_timing as quando,
    action_statement as acao
FROM information_schema.triggers
WHERE event_object_schema = 'public'
AND event_object_table = 'vendas';

-- 6️⃣ Testar INSERT mínimo (descomente para testar)
-- IMPORTANTE: Isso vai tentar inserir uma venda de teste
/*
INSERT INTO vendas (
    total,
    desconto,
    status,
    metodo_pagamento
) VALUES (
    100.00,
    0,
    'concluida',
    'dinheiro'
)
RETURNING *;
*/

SELECT '✅ DIAGNÓSTICO COMPLETO!' as resultado;
