-- DIAGNÓSTICO COMPLETO DE CLIENTES - SISTEMA PDV ALLIMPORT
-- Verificar estrutura e dados de todas as tabelas relacionadas a clientes

-- 1. VERIFICAR EXISTÊNCIA E ESTRUTURA DAS TABELAS DE CLIENTES
SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name IN ('clientes', 'customers')
AND table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 2. VERIFICAR QUANTIDADE DE REGISTROS EM CADA TABELA
SELECT 
    'clientes' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
    COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM clientes
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes' AND table_schema = 'public')

UNION ALL

SELECT 
    'customers' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN active = true THEN 1 END) as ativos,
    COUNT(CASE WHEN active = false THEN 1 END) as inativos
FROM customers
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers' AND table_schema = 'public');

-- 3. VERIFICAR DADOS ESPECÍFICOS DA TABELA CLIENTES
SELECT 
    id,
    nome,
    telefone,
    cpf_cnpj,
    email,
    endereco,
    tipo,
    ativo,
    criado_em
FROM clientes
WHERE ativo = true
ORDER BY criado_em DESC
LIMIT 10;

-- 4. VERIFICAR POSSÍVEIS DUPLICATAS POR TELEFONE
SELECT 
    telefone,
    COUNT(*) as quantidade,
    STRING_AGG(nome, ', ') as nomes
FROM clientes
WHERE telefone IS NOT NULL 
AND telefone != ''
GROUP BY telefone
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 5. VERIFICAR POSSÍVEIS DUPLICATAS POR CPF/CNPJ
SELECT 
    cpf_cnpj,
    COUNT(*) as quantidade,
    STRING_AGG(nome, ', ') as nomes
FROM clientes
WHERE cpf_cnpj IS NOT NULL 
AND cpf_cnpj != ''
GROUP BY cpf_cnpj
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 6. VERIFICAR DADOS INCOMPLETOS
SELECT 
    'sem_nome' as problema,
    COUNT(*) as quantidade
FROM clientes
WHERE nome IS NULL OR nome = ''

UNION ALL

SELECT 
    'sem_telefone' as problema,
    COUNT(*) as quantidade
FROM clientes
WHERE telefone IS NULL OR telefone = ''

UNION ALL

SELECT 
    'sem_tipo' as problema,
    COUNT(*) as quantidade
FROM clientes
WHERE tipo IS NULL;

-- 7. VERIFICAR POLÍTICAS RLS ATIVAS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('clientes', 'customers');

-- 8. VERIFICAR ÍNDICES DAS TABELAS
SELECT 
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_name,
    ix.indisunique as is_unique
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid
WHERE t.relname IN ('clientes', 'customers')
AND a.attnum = ANY(ix.indkey)
AND t.relkind = 'r'
ORDER BY t.relname, i.relname;

-- 9. VERIFICAR FOREIGN KEYS RELACIONADAS A CLIENTES
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND (ccu.table_name IN ('clientes', 'customers')
     OR tc.table_name IN ('clientes', 'customers'));

-- 10. VERIFICAR TRIGGERS DAS TABELAS DE CLIENTES
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('clientes', 'customers')
ORDER BY event_object_table, trigger_name;
