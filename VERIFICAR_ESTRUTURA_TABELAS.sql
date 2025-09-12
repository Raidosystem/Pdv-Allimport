-- VERIFICAR ESTRUTURA DAS TABELAS EXISTENTES (CORRIGIDO)
-- Execute para ver como estão organizadas as tabelas

-- 1. Ver estrutura da tabela subscriptions
SELECT 
    'subscriptions' as tabela,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'subscriptions' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Ver dados existentes na subscriptions
SELECT 'Dados em subscriptions:' as info, COUNT(*) as total
FROM subscriptions;

-- 3. Ver algumas linhas de exemplo (se existir)
SELECT 
    'Exemplo subscriptions:' as info,
    id,
    user_id,
    status,
    created_at
FROM subscriptions 
LIMIT 3;