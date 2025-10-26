-- =====================================================
-- DIAGNÓSTICO E CORREÇÃO: ERRO 400 AO INSERIR VENDAS_ITENS
-- =====================================================
-- Data: 2025-10-26
-- Problema: Erro 400 ao inserir itens de venda
-- =====================================================

-- 1️⃣ VERIFICAR ESTRUTURA COMPLETA
SELECT 
    '1. ESTRUTURA DA TABELA' as etapa,
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'vendas_itens'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2️⃣ VERIFICAR CONSTRAINTS (NOT NULL, FK, etc)
SELECT
    '2. CONSTRAINTS' as etapa,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'vendas_itens'
AND tc.table_schema = 'public';

-- 3️⃣ VERIFICAR RLS (Row Level Security)
SELECT
    '3. RLS STATUS' as etapa,
    schemaname,
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename = 'vendas_itens'
AND schemaname = 'public';

-- 4️⃣ VERIFICAR POLÍTICAS RLS
SELECT
    '4. POLÍTICAS RLS' as etapa,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual as usando,
    with_check
FROM pg_policies 
WHERE tablename = 'vendas_itens'
AND schemaname = 'public';

-- 5️⃣ VERIFICAR ÚLTIMOS REGISTROS INSERIDOS COM SUCESSO
SELECT 
    '5. ÚLTIMOS REGISTROS' as etapa,
    id,
    venda_id,
    produto_id,
    quantidade,
    preco_unitario,
    subtotal,
    user_id,
    created_at
FROM vendas_itens 
ORDER BY created_at DESC 
LIMIT 5;

-- 6️⃣ VERIFICAR TRIGGERS
SELECT
    '6. TRIGGERS' as etapa,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'vendas_itens'
AND trigger_schema = 'public';

-- =====================================================
-- 🔧 CORREÇÕES BASEADAS NA ANÁLISE
-- =====================================================
-- IMPORTANTE: Já existem registros com produto_id NULL,
-- então o problema é RLS ou trigger, NÃO constraint!
-- =====================================================

-- CORREÇÃO 1: 🎯 MAIS PROVÁVEL - RLS COM WITH CHECK RESTRITIVO
-- O problema comum é tentar validar user_id ANTES do trigger preencher

-- Remover TODAS as políticas antigas de INSERT
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_policy" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem inserir itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Users can insert vendas_itens" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_isolamento_total" ON vendas_itens;
DROP POLICY IF EXISTS "rls_isolamento_vendas_itens" ON vendas_itens;

-- Criar política CORRETA que valida a venda, não o item diretamente
CREATE POLICY "vendas_itens_insert_via_venda" 
ON vendas_itens 
FOR INSERT 
TO authenticated
WITH CHECK (
    -- Valida se a venda pertence ao usuário
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- CORREÇÃO 2: Se falta coluna produto_nome, adicionar
ALTER TABLE vendas_itens 
ADD COLUMN IF NOT EXISTS produto_nome TEXT;

-- CORREÇÃO 3: Garantir política de SELECT também funciona
DROP POLICY IF EXISTS "vendas_itens_select_policy" ON vendas_itens;
CREATE POLICY "vendas_itens_select_policy" 
ON vendas_itens 
FOR SELECT 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- CORREÇÃO 4: Garantir que user_id seja preenchido automaticamente
CREATE OR REPLACE FUNCTION set_user_id_vendas_itens()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger
DROP TRIGGER IF EXISTS trigger_set_user_id_vendas_itens ON vendas_itens;
CREATE TRIGGER trigger_set_user_id_vendas_itens
  BEFORE INSERT ON vendas_itens
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id_vendas_itens();

-- =====================================================
-- 📋 INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute as queries de VERIFICAÇÃO (1️⃣ a 6️⃣) primeiro
-- 2. Analise os resultados
-- 3. Execute apenas as CORREÇÕES necessárias
-- 4. Teste a inserção novamente no frontend
-- =====================================================

-- ✅ TESTE MANUAL DE INSERÇÃO
-- Após correções, teste com:
/*
INSERT INTO vendas_itens (
    venda_id,
    produto_id,
    quantidade,
    preco_unitario,
    subtotal
) VALUES (
    'UUID_DE_UMA_VENDA_EXISTENTE',
    NULL, -- Testando com NULL
    1,
    10.00,
    10.00
)
RETURNING *;
*/
