-- 🔍 VERIFICAR ESTRUTURA DA TABELA lojas_online

-- 1. Verificar se a tabela existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'lojas_online'
) as tabela_existe;

-- 2. Ver estrutura completa da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'lojas_online'
ORDER BY ordinal_position;

-- 3. Verificar políticas RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'lojas_online';

-- 4. Verificar se há lojas cadastradas
SELECT 
    id,
    slug,
    nome,
    ativa,
    whatsapp,
    LEFT(empresa_id::text, 8) as empresa_id_prefix,
    created_at
FROM lojas_online
LIMIT 10;

-- 5. Contar total de lojas
SELECT COUNT(*) as total_lojas FROM lojas_online;

-- 6. Ver lojas ativas
SELECT 
    slug,
    nome,
    ativa,
    whatsapp
FROM lojas_online
WHERE ativa = true;
