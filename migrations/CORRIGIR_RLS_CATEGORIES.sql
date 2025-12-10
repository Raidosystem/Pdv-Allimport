-- ============================================
-- CORRIGIR POLÍTICAS RLS DA TABELA CATEGORIES
-- ============================================
-- Problema: Usuário não consegue criar categorias
-- Causa: Políticas RLS bloqueando INSERT
-- Solução: Criar políticas permitindo CRUD por user_id
-- ============================================

-- 1. REMOVER políticas antigas (se existirem)
DROP POLICY IF EXISTS "categories_select_policy" ON categories;
DROP POLICY IF EXISTS "categories_insert_policy" ON categories;
DROP POLICY IF EXISTS "categories_update_policy" ON categories;
DROP POLICY IF EXISTS "categories_delete_policy" ON categories;

-- Políticas antigas com empresa_id (se existirem)
DROP POLICY IF EXISTS "Usuarios podem ver suas categorias" ON categories;
DROP POLICY IF EXISTS "Usuarios podem criar categorias" ON categories;
DROP POLICY IF EXISTS "Usuarios podem atualizar suas categorias" ON categories;
DROP POLICY IF EXISTS "Usuarios podem deletar suas categorias" ON categories;

-- 2. GARANTIR que RLS está habilitado
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR políticas corretas usando user_id
-- SELECT: Usuário vê apenas suas próprias categorias
CREATE POLICY "categories_select_policy"
ON categories
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- INSERT: Usuário pode criar categorias vinculadas ao seu user_id
CREATE POLICY "categories_insert_policy"
ON categories
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- UPDATE: Usuário pode atualizar apenas suas próprias categorias
CREATE POLICY "categories_update_policy"
ON categories
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- DELETE: Usuário pode deletar apenas suas próprias categorias
CREATE POLICY "categories_delete_policy"
ON categories
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- 4. VERIFICAR a estrutura da tabela
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- 5. VERIFICAR as políticas aplicadas
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
WHERE tablename = 'categories';

-- 6. TESTAR: Contar categorias do usuário atual
SELECT COUNT(*) as total_categorias
FROM categories
WHERE user_id = auth.uid();
