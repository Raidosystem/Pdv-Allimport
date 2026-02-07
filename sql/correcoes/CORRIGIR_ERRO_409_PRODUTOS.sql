-- =====================================================
-- 🚨 SOLUÇÃO RÁPIDA: ERRO 409 AO SALVAR PRODUTOS
-- =====================================================
-- Execute este script para corrigir o erro 409
-- =====================================================

-- PROBLEMA PROVÁVEL: Tabela produtos tem campo empresa_id MAS o código está enviando apenas user_id
-- SOLUÇÃO: Garantir que user_id seja suficiente OU preencher empresa_id automaticamente

-- 1️⃣ VERIFICAR SE EXISTE CAMPO empresa_id
SELECT 
    '🔍 CAMPOS DA TABELA' AS info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
    AND column_name IN ('user_id', 'empresa_id')
ORDER BY column_name;

-- 2️⃣ SE EXISTE empresa_id, TORNAR NULLABLE OU ADICIONAR DEFAULT
-- (Execute APENAS se empresa_id existir e for NOT NULL)

-- Opção A: Tornar empresa_id NULLABLE
ALTER TABLE produtos 
ALTER COLUMN empresa_id DROP NOT NULL;

-- Opção B: Fazer empresa_id = user_id automaticamente via DEFAULT
-- (caso queira manter NOT NULL)
ALTER TABLE produtos 
ALTER COLUMN empresa_id SET DEFAULT auth.uid();

-- 3️⃣ ATUALIZAR PRODUTOS EXISTENTES SEM empresa_id
UPDATE produtos
SET empresa_id = user_id
WHERE empresa_id IS NULL AND user_id IS NOT NULL;

-- 4️⃣ AJUSTAR POLÍTICA RLS DE INSERT
-- Se a política estiver verificando empresa_id, ajustar para user_id

DROP POLICY IF EXISTS "produtos_insert_own_only" ON produtos;

CREATE POLICY "produtos_insert_own_only"
ON produtos FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 5️⃣ VERIFICAR SE FUNCIONOU
-- Deve retornar a política atualizada
SELECT 
    '✅ POLÍTICA INSERT' AS info,
    policyname,
    with_check
FROM pg_policies
WHERE tablename = 'produtos' 
    AND cmd = 'INSERT';

-- 6️⃣ VERIFICAR CONSTRAINTS UNIQUE QUE PODEM CAUSAR CONFLITO
SELECT 
    '🔍 CONSTRAINTS UNIQUE' AS info,
    conname AS nome_constraint,
    pg_get_constraintdef(oid) AS definicao
FROM pg_constraint
WHERE conrelid = 'produtos'::regclass
    AND contype = 'u';  -- u = UNIQUE

-- 7️⃣ SE HOUVER UNIQUE em codigo_barras ou sku, PODE SER O PROBLEMA
-- Solução: Permitir duplicatas OU garantir que o código seja único

-- Remover UNIQUE de codigo_barras (se existir)
-- ALTER TABLE produtos DROP CONSTRAINT IF EXISTS produtos_codigo_barras_key;

-- Remover UNIQUE de sku (se existir)
-- ALTER TABLE produtos DROP CONSTRAINT IF EXISTS produtos_sku_key;

-- Adicionar UNIQUE composto (user_id + codigo)
-- CREATE UNIQUE INDEX IF NOT EXISTS produtos_user_codigo_unique 
-- ON produtos(user_id, codigo_barras) 
-- WHERE codigo_barras IS NOT NULL;

-- =====================================================
-- ✅ TESTE APÓS CORREÇÃO
-- =====================================================

-- Testar INSERT manual (substitua USER_ID_AQUI)
/*
INSERT INTO produtos (
    nome, 
    preco, 
    estoque, 
    ativo, 
    user_id
) VALUES (
    'Teste Produto 409',
    19.99,
    10,
    true,
    'USER_ID_AQUI'  -- ⚠️ Substituir pelo seu user_id
) RETURNING id, nome, user_id;
*/

-- Se o INSERT acima funcionar, o problema está resolvido!

-- =====================================================
-- 📊 VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
    '📊 RESUMO' AS info,
    COUNT(*) AS total_produtos,
    COUNT(DISTINCT user_id) AS total_usuarios,
    COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) AS sem_empresa_id
FROM produtos;

-- =====================================================
-- ✅ O QUE FOI CORRIGIDO:
-- =====================================================
-- 1. Campo empresa_id tornado NULLABLE ou com DEFAULT
-- 2. Política RLS de INSERT ajustada para usar user_id
-- 3. Produtos existentes atualizados
-- 4. Constraints UNIQUE verificadas
-- =====================================================
