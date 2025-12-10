-- ============================================================
-- Configurar Row-Level Security (RLS) para a tabela 'produtos'
-- Isso garante isolamento de dados por user_id
-- ============================================================

-- 1. Habilitar RLS na tabela produtos
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- 2. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "produtos_select_public" ON produtos;
DROP POLICY IF EXISTS "produtos_select" ON produtos;
DROP POLICY IF EXISTS "produtos_insert" ON produtos;
DROP POLICY IF EXISTS "produtos_update" ON produtos;
DROP POLICY IF EXISTS "produtos_delete" ON produtos;
DROP POLICY IF EXISTS "Enable read access for all users" ON produtos;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON produtos;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON produtos;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON produtos;

-- 3. Criar políticas de isolamento por user_id

-- Política SELECT: Usuários podem ver apenas seus próprios produtos
CREATE POLICY "produtos_select_own"
  ON produtos
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política INSERT: Usuários podem inserir apenas produtos com seu user_id
CREATE POLICY "produtos_insert_own"
  ON produtos
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política UPDATE: Usuários podem atualizar apenas seus próprios produtos
CREATE POLICY "produtos_update_own"
  ON produtos
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política DELETE: Usuários podem deletar apenas seus próprios produtos
CREATE POLICY "produtos_delete_own"
  ON produtos
  FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Verificar que as políticas foram criadas
SELECT
  schemaname,
  tablename,
  policyname,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'produtos'
ORDER BY policyname;
