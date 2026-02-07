-- =====================================================
-- 🔍 DIAGNÓSTICO ERRO 409 AO SALVAR PRODUTOS
-- =====================================================
-- Erro 409 = Conflict (geralmente constraints ou RLS)
-- =====================================================

-- 1️⃣ VERIFICAR CONSTRAINTS DA TABELA PRODUTOS
SELECT 
    '🔍 CONSTRAINTS' AS secao,
    conname AS nome_constraint,
    contype AS tipo,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'c' THEN 'CHECK'
        ELSE contype::text
    END AS tipo_descricao,
    pg_get_constraintdef(oid) AS definicao
FROM pg_constraint
WHERE conrelid = 'produtos'::regclass
ORDER BY contype, conname;

-- 2️⃣ VERIFICAR ÍNDICES UNIQUE
SELECT 
    '🔍 ÍNDICES UNIQUE' AS secao,
    indexname AS nome_indice,
    indexdef AS definicao
FROM pg_indexes
WHERE tablename = 'produtos'
    AND schemaname = 'public'
    AND indexdef LIKE '%UNIQUE%'
ORDER BY indexname;

-- 3️⃣ VERIFICAR POLÍTICA RLS DE INSERT
SELECT 
    '🔍 POLÍTICA INSERT' AS secao,
    policyname AS nome_politica,
    cmd AS comando,
    roles AS roles_aplicaveis,
    with_check AS expressao_check
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename = 'produtos'
    AND cmd = 'INSERT'
ORDER BY policyname;

-- 4️⃣ VERIFICAR SE HÁ PRODUTOS COM user_id DO USUÁRIO ATUAL
-- Execute como usuário autenticado
SELECT 
    '📊 MEUS PRODUTOS' AS secao,
    COUNT(*) AS total_produtos,
    user_id
FROM produtos
GROUP BY user_id;

-- 5️⃣ TESTAR INSERT DIRETO (para debug)
-- Substitua 'seu-user-id-aqui' pelo user_id real
/*
INSERT INTO produtos (
    nome, preco, estoque, ativo, user_id
) VALUES (
    'Teste 409',
    10.00,
    1,
    true,
    'seu-user-id-aqui'  -- ⚠️ SUBSTITUIR
);
*/

-- 6️⃣ VERIFICAR SE O CAMPO user_id ACEITA NULL
SELECT 
    '🔍 CAMPO user_id' AS secao,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
    AND column_name = 'user_id';

-- 7️⃣ VERIFICAR SE HÁ TRIGGERS QUE PODEM CAUSAR CONFLITO
SELECT 
    '🔍 TRIGGERS' AS secao,
    tgname AS nome_trigger,
    tgtype AS tipo,
    tgenabled AS habilitado,
    pg_get_triggerdef(oid) AS definicao
FROM pg_trigger
WHERE tgrelid = 'produtos'::regclass
    AND tgisinternal = false
ORDER BY tgname;

-- =====================================================
-- 📋 SOLUÇÕES COMUNS PARA ERRO 409:
-- =====================================================

/*
PROBLEMA 1: Constraint UNIQUE violada (ex: código duplicado)
SOLUÇÃO: Verificar se há produtos com mesmo código/SKU

SELECT codigo_barras, sku, COUNT(*) 
FROM produtos 
WHERE codigo_barras IS NOT NULL OR sku IS NOT NULL
GROUP BY codigo_barras, sku 
HAVING COUNT(*) > 1;


PROBLEMA 2: Política RLS de INSERT muito restritiva
SOLUÇÃO: Ajustar política para permitir INSERT

-- Ver política atual:
SELECT with_check FROM pg_policies 
WHERE tablename = 'produtos' AND cmd = 'INSERT';

-- Se estiver NULL ou muito restritiva, ajustar:
DROP POLICY IF EXISTS "produtos_insert_own_only" ON produtos;
CREATE POLICY "produtos_insert_own_only"
ON produtos FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);


PROBLEMA 3: Coluna obrigatória sem valor padrão
SOLUÇÃO: Verificar colunas NOT NULL

SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'produtos' 
    AND is_nullable = 'NO' 
    AND column_default IS NULL;


PROBLEMA 4: Trigger causando conflito
SOLUÇÃO: Desabilitar temporariamente para testar

-- Desabilitar todos os triggers:
ALTER TABLE produtos DISABLE TRIGGER ALL;

-- Testar INSERT

-- Reabilitar:
ALTER TABLE produtos ENABLE TRIGGER ALL;
*/

-- =====================================================
-- ✅ APÓS IDENTIFICAR O PROBLEMA:
-- =====================================================
-- 1. Execute a solução apropriada acima
-- 2. Teste o INSERT novamente
-- 3. Verifique os logs do navegador
-- 4. Confira se o produto foi criado com: SELECT * FROM produtos ORDER BY created_at DESC LIMIT 1;
-- =====================================================
