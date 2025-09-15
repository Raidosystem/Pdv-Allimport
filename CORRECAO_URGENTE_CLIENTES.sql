-- ===================================================================
-- SCRIPT DE CORREÇÃO URGENTE - STATUS DOS CLIENTES
-- ===================================================================
-- PROBLEMA: Todos os clientes estão inativos mas no backup original 
--           todos os 141 clientes estavam ativos
--
-- SOLUÇÃO: Reativar todos os clientes baseado no estado original
-- ===================================================================

-- 1. VERIFICAR SITUAÇÃO ATUAL
SELECT 
    'ANTES DA CORREÇÃO' as momento,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
    COUNT(CASE WHEN ativo IS NULL THEN 1 END) as sem_status
FROM clientes;

-- 2. MOSTRAR ALGUNS CLIENTES INATIVOS (PARA CONFIRMAR O PROBLEMA)
SELECT 
    'EXEMPLOS DE CLIENTES INATIVOS' as info,
    nome, 
    ativo, 
    criado_em,
    atualizado_em
FROM clientes 
WHERE ativo = false 
ORDER BY nome 
LIMIT 10;

-- 3. CORREÇÃO: REATIVAR TODOS OS CLIENTES
-- (Baseado no backup original onde todos estavam ativos)
UPDATE clientes 
SET 
    ativo = true,
    atualizado_em = NOW()
WHERE ativo = false OR ativo IS NULL;

-- 4. VERIFICAR RESULTADO DA CORREÇÃO
SELECT 
    'APÓS A CORREÇÃO' as momento,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
    COUNT(CASE WHEN ativo IS NULL THEN 1 END) as sem_status
FROM clientes;

-- 5. MOSTRAR EXEMPLOS DOS CLIENTES REATIVADOS
SELECT 
    'CLIENTES REATIVADOS' as info,
    nome, 
    ativo, 
    atualizado_em
FROM clientes 
WHERE ativo = true 
AND atualizado_em > NOW() - INTERVAL '1 minute'
ORDER BY atualizado_em DESC 
LIMIT 10;

-- ===================================================================
-- INSTRUÇÕES PARA EXECUÇÃO:
-- ===================================================================
-- 1. Acesse: https://supabase.com/dashboard
-- 2. Vá em "SQL Editor" 
-- 3. Cole este script completo
-- 4. Clique em "Run" para executar
-- ===================================================================