-- ============================================
-- DIAGNÓSTICO E CORREÇÃO - EMPRESAS SEM USER_ID
-- ============================================

-- 1. Ver todas as empresas e seus user_ids
SELECT 
    '🏢 EMPRESAS CADASTRADAS' as info,
    e.id as empresa_id,
    e.nome as empresa_nome,
    e.user_id,
    au.email as email_dono
FROM empresas e
LEFT JOIN auth.users au ON au.id = e.user_id
ORDER BY e.nome;

-- 2. Ver se há empresas sem user_id
SELECT 
    '⚠️ EMPRESAS SEM USER_ID' as info,
    id,
    nome
FROM empresas
WHERE user_id IS NULL;

-- 3. Ver clientes órfãos (sem empresa_id)
SELECT 
    '👥 CLIENTES ÓRFÃOS (SEM EMPRESA)' as info,
    COUNT(*) as total
FROM clientes
WHERE empresa_id IS NULL;

-- 4. Associar clientes órfãos à primeira empresa disponível
-- (Execute apenas se houver clientes órfãos)
UPDATE clientes
SET empresa_id = (SELECT id FROM empresas ORDER BY criado_em LIMIT 1),
    user_id = (SELECT user_id FROM empresas ORDER BY criado_em LIMIT 1)
WHERE empresa_id IS NULL;

-- 5. Verificar resultado
SELECT 
    '✅ RESULTADO' as info,
    COUNT(*) as total_clientes_com_empresa
FROM clientes
WHERE empresa_id IS NOT NULL;

SELECT '🎯 CORREÇÃO APLICADA! Agora teste novamente a busca de clientes no sistema.' as resultado;
