-- =========================================================================
-- SCRIPT SEGURO PARA CONFIGURAR MULTI-TENANT NOS PRODUTOS
-- Execute este SQL no SQL Editor do Supabase Dashboard
-- =========================================================================

-- 1. ADICIONAR COLUNA USER_ID NA TABELA PRODUTOS (SE NÃO EXISTIR)
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- 2. ASSOCIAR TODOS OS PRODUTOS EXISTENTES AO USUÁRIO ASSISTENCIA
UPDATE produtos 
SET user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid 
WHERE user_id IS NULL;

-- 3. VERIFICAR QUANTOS PRODUTOS FORAM ATUALIZADOS
SELECT COUNT(*) as total_produtos_associados 
FROM produtos 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- 4. REMOVER TODAS AS POLÍTICAS RLS EXISTENTES PARA PRODUTOS
DO $$
BEGIN
    -- Remove políticas de produtos
    DROP POLICY IF EXISTS "Usuários podem ver apenas seus produtos" ON produtos;
    DROP POLICY IF EXISTS "Usuários podem inserir seus próprios produtos" ON produtos;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios produtos" ON produtos;
    DROP POLICY IF EXISTS "Usuários podem deletar seus próprios produtos" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_SELECT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_INSERT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_UPDATE" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_DELETE" ON produtos;
    DROP POLICY IF EXISTS "produtos_select_policy" ON produtos;
    DROP POLICY IF EXISTS "produtos_insert_policy" ON produtos;
    DROP POLICY IF EXISTS "produtos_update_policy" ON produtos;
    DROP POLICY IF EXISTS "produtos_delete_policy" ON produtos;
    
    RAISE NOTICE 'Políticas de produtos removidas com sucesso';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao remover políticas de produtos: %', SQLERRM;
END
$$;

-- 5. HABILITAR RLS NA TABELA PRODUTOS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS RLS RESTRITIVAS PARA PRODUTOS
CREATE POLICY "Isolamento_produtos_SELECT_v2" ON produtos
FOR SELECT USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_produtos_INSERT_v2" ON produtos
FOR INSERT WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_produtos_UPDATE_v2" ON produtos
FOR UPDATE USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid)
WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_produtos_DELETE_v2" ON produtos
FOR DELETE USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

-- 7. REMOVER E RECRIAR POLÍTICAS DE CLIENTES
DO $$
BEGIN
    -- Remove políticas de clientes
    DROP POLICY IF EXISTS "Usuários podem ver apenas seus clientes" ON clientes;
    DROP POLICY IF EXISTS "Usuários podem inserir seus próprios clientes" ON clientes;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios clientes" ON clientes;
    DROP POLICY IF EXISTS "Usuários podem deletar seus próprios clientes" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_SELECT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_INSERT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_UPDATE" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_DELETE" ON clientes;
    DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
    DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
    DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
    DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;
    
    RAISE NOTICE 'Políticas de clientes removidas com sucesso';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao remover políticas de clientes: %', SQLERRM;
END
$$;

CREATE POLICY "Isolamento_clientes_SELECT_v2" ON clientes
FOR SELECT USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_clientes_INSERT_v2" ON clientes
FOR INSERT WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_clientes_UPDATE_v2" ON clientes
FOR UPDATE USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid)
WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

CREATE POLICY "Isolamento_clientes_DELETE_v2" ON clientes
FOR DELETE USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

-- 8. VERIFICAÇÃO FINAL
SELECT 
  'clientes' as tabela,
  COUNT(*) as total_registros
FROM clientes
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid

UNION ALL

SELECT 
  'produtos' as tabela,
  COUNT(*) as total_registros
FROM produtos
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- 9. LISTAR POLÍTICAS CRIADAS
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('produtos', 'clientes')
ORDER BY tablename, policyname;

-- =========================================================================
-- INSTRUÇÕES:
-- 1. Copie todo este SQL
-- 2. Acesse: https://kmcaaqetxtwkdcczdomw.supabase.co/project/default/sql/new
-- 3. Cole o SQL no editor
-- 4. Clique em "RUN" para executar
-- =========================================================================
