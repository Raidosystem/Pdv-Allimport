-- ====================================================================
-- DIAGNÓSTICO E CORREÇÃO: ERRO 400 AO BUSCAR VENDAS_ITENS
-- ====================================================================
-- Problema: Query retorna erro 400 ao buscar itens de vendas
-- Causa: Possível problema na estrutura ou nas políticas RLS
-- ====================================================================

-- 1️⃣ VERIFICAR ESTRUTURA DA TABELA vendas_itens
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'vendas_itens'
ORDER BY ordinal_position;

-- 2️⃣ VERIFICAR RELAÇÃO COM TABELA produtos
SELECT
    tc.constraint_name,
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
WHERE tc.table_name = 'vendas_itens'
    AND tc.constraint_type = 'FOREIGN KEY';

-- 3️⃣ VERIFICAR POLÍTICAS RLS NA TABELA vendas_itens
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
WHERE tablename = 'vendas_itens';

-- 4️⃣ VERIFICAR SE A TABELA TEM RLS ATIVADO
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename = 'vendas_itens';

-- 5️⃣ TESTAR QUERY DIRETA (como admin)
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.venda_id IN (
    '002a33d0-4634-4ab5-9acc-c6223dd5e680',
    'e24c3c73-1e1c-4b10-8846-c1d4ac4e7902',
    'f5c01a10-1a04-4c2f-8814-7cd13ce12934',
    '43832b40-880d-4d6e-bfb4-7f939ef31fcb',
    '7c424b87-24f3-450d-b959-de5cab748b86',
    '34bc2c18-90e8-4c41-8fe1-3945e0fc2862'
)
LIMIT 50;

-- ====================================================================
-- CORREÇÕES NECESSÁRIAS
-- ====================================================================

-- 🔧 CORREÇÃO 1: Criar política RLS permissiva para vendas_itens
-- (Se não existir ou estiver muito restritiva)

-- Remover políticas antigas problemáticas
DROP POLICY IF EXISTS "Usuários podem ver itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_select" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_acesso_total_select" ON vendas_itens;

-- 🔧 CORREÇÃO 2: Garantir que a coluna user_id existe em vendas_itens
-- (Para facilitar as políticas RLS)
ALTER TABLE vendas_itens
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Atualizar user_id baseado na venda
UPDATE vendas_itens vi
SET user_id = v.user_id
FROM vendas v
WHERE vi.venda_id = v.id
AND vi.user_id IS NULL;

-- Criar política mais simples usando user_id direto
DROP POLICY IF EXISTS "vendas_itens_acesso_total_select" ON vendas_itens;

CREATE POLICY "vendas_itens_user_select"
ON vendas_itens
FOR SELECT
USING (
    -- Usuário é dono da venda (mesma empresa)
    user_id = auth.uid()
);

-- 🔧 CORREÇÃO 3: Criar políticas para INSERT, UPDATE, DELETE

CREATE POLICY "vendas_itens_user_insert"
ON vendas_itens
FOR INSERT
WITH CHECK (
    user_id = auth.uid()
);

CREATE POLICY "vendas_itens_user_update"
ON vendas_itens
FOR UPDATE
USING (
    user_id = auth.uid()
);

CREATE POLICY "vendas_itens_user_delete"
ON vendas_itens
FOR DELETE
USING (
    user_id = auth.uid()
);

-- 🔧 CORREÇÃO 4: Criar trigger para manter user_id sincronizado
CREATE OR REPLACE FUNCTION sync_vendas_itens_user_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Ao inserir item, pegar user_id da venda
    IF TG_OP = 'INSERT' THEN
        SELECT user_id INTO NEW.user_id
        FROM vendas
        WHERE id = NEW.venda_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_sync_vendas_itens_user_id ON vendas_itens;

CREATE TRIGGER trigger_sync_vendas_itens_user_id
BEFORE INSERT ON vendas_itens
FOR EACH ROW
EXECUTE FUNCTION sync_vendas_itens_user_id();

-- ====================================================================
-- VALIDAÇÃO FINAL
-- ====================================================================

-- Testar se a query agora funciona
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    vi.user_id,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.user_id = auth.uid()
LIMIT 10;

-- Verificar políticas aplicadas
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'vendas_itens';

-- ====================================================================
-- QUERY DE TESTE PARA O FRONTEND
-- ====================================================================

-- Esta é a query que o frontend deveria usar:
-- GET /rest/v1/vendas_itens?select=produto_id,quantidade,subtotal,produtos(nome)&venda_id=in.(id1,id2,id3)
-- 
-- Exemplo de teste direto:
SELECT 
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    json_build_object('nome', p.nome) as produtos
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.venda_id = ANY(ARRAY[
    '002a33d0-4634-4ab5-9acc-c6223dd5e680'::uuid,
    'e24c3c73-1e1c-4b10-8846-c1d4ac4e7902'::uuid
]);
