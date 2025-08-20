-- 🔍 DIAGNÓSTICO COMPLETO: POR QUE OS DADOS NÃO APARECEM NO PDV

-- 1. VERIFICAR SE OS DADOS FORAM INSERIDOS NO BANCO
SELECT 'TESTE 1 - DADOS INSERIDOS?' as diagnostico;
SELECT COUNT(*) as total_produtos FROM products;
SELECT COUNT(*) as produtos_allimport FROM products WHERE name LIKE 'ALLIMPORT%';

-- 2. VERIFICAR RLS (ROW LEVEL SECURITY)
SELECT 'TESTE 2 - RLS STATUS:' as diagnostico;
SELECT 
    tablename, 
    rowsecurity as rls_ativo,
    CASE WHEN rowsecurity THEN 'RLS ESTÁ BLOQUEANDO!' ELSE 'RLS OK' END as status
FROM pg_tables t
JOIN pg_class c ON c.relname = t.tablename 
WHERE t.tablename IN ('products', 'clients', 'categories');

-- 3. VERIFICAR POLÍTICAS RLS QUE PODEM ESTAR BLOQUEANDO
SELECT 'TESTE 3 - POLÍTICAS RLS:' as diagnostico;
SELECT 
    tablename,
    policyname,
    cmd as operacao,
    qual as condicao
FROM pg_policies 
WHERE tablename IN ('products', 'clients', 'categories');

-- 4. VERIFICAR USUÁRIO ATUAL
SELECT 'TESTE 4 - USUÁRIO ATUAL:' as diagnostico;
SELECT 
    current_user as usuario_sql,
    session_user as sessao,
    auth.uid() as auth_user_id;

-- 5. TENTAR DESABILITAR RLS TEMPORARIAMENTE (SE VOCÊ FOR OWNER)
-- DESCOMENTE AS LINHAS ABAIXO SE NECESSÁRIO:
-- ALTER TABLE products DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE clients DISABLE ROW LEVEL SECURITY;  
-- ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- 6. VERIFICAR SE EXISTE COLUNA USER_ID NAS TABELAS
SELECT 'TESTE 5 - ESTRUTURA DAS TABELAS:' as diagnostico;
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('products', 'clients', 'categories')
  AND column_name IN ('user_id', 'owner_id', 'created_by')
ORDER BY table_name, column_name;

-- 7. TESTE FINAL - LISTAR PRODUTOS SEM FILTROS
SELECT 'TESTE 6 - PRODUTOS VISÍVEIS AGORA:' as diagnostico;
SELECT name, created_at FROM products 
ORDER BY created_at DESC 
LIMIT 10;

-- ✅ EXECUTE ESTE SQL E ME ENVIE O RESULTADO COMPLETO
-- Vou identificar exatamente o que está bloqueando os dados!
