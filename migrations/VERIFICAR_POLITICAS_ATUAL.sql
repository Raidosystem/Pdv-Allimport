-- ========================================
-- VERIFICAÇÃO COMPLETA DAS POLÍTICAS RLS
-- ========================================

-- 1. Verificar todas as políticas na tabela ordens_servico
SELECT 
    policyname AS "Nome da Política",
    cmd AS "Comando",
    CASE 
        WHEN qual IS NOT NULL THEN substring(qual::text, 1, 100)
        ELSE 'N/A'
    END AS "Condição (primeiros 100 chars)"
FROM pg_policies 
WHERE tablename = 'ordens_servico'
ORDER BY cmd, policyname;

-- 2. Verificar se RLS está ativo
SELECT 
    tablename,
    rowsecurity AS "RLS Ativo"
FROM pg_tables
WHERE tablename = 'ordens_servico';

-- 3. Contar total de ordens (SQL Editor ignora RLS)
SELECT COUNT(*) AS total_ordens_sem_rls
FROM ordens_servico;

-- 4. Contar por status (SQL Editor ignora RLS)
SELECT 
    status,
    COUNT(*) as total
FROM ordens_servico
GROUP BY status
ORDER BY total DESC;

-- 5. Testar query JavaScript (simula RLS)
-- Esta query simula o que o JavaScript vê (com RLS)
SELECT COUNT(*) AS total_ordens_com_rls
FROM ordens_servico
WHERE empresa_id = auth.uid() OR user_id = auth.uid();

-- 6. Verificar seu user_id
SELECT 
    auth.uid() AS "Seu User ID";

-- 7. Verificar se as ordens têm empresa_id correto
SELECT 
    empresa_id,
    COUNT(*) as total,
    array_agg(DISTINCT status) as statuses
FROM ordens_servico
GROUP BY empresa_id
ORDER BY total DESC
LIMIT 5;
