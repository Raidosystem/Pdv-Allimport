-- ============================================
-- CORRIGIR TABELA FUNCOES E RLS
-- ============================================

-- 1. Adicionar coluna 'nivel' se não existir (alguns códigos esperavam essa coluna)
ALTER TABLE funcoes 
  ADD COLUMN IF NOT EXISTS nivel INTEGER DEFAULT 1;

COMMENT ON COLUMN funcoes.nivel IS 'Nível hierárquico da função (1=Administrador, 2=Gerente, 3=Vendedor, etc.)';

-- 2. Atualizar nível das funções existentes
UPDATE funcoes 
SET nivel = 1 
WHERE nome = 'Administrador' AND nivel IS NULL;

UPDATE funcoes 
SET nivel = 2 
WHERE nome = 'Gerente' AND nivel IS NULL;

UPDATE funcoes 
SET nivel = 3 
WHERE nome IN ('Vendedor', 'Caixa', 'Estoquista') AND nivel IS NULL;

-- 3. CORRIGIR RLS DA TABELA FUNCOES
-- Permitir que admins da empresa criem funções

-- Dropar policies antigas se existirem
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes;

-- CRIAR POLICIES CORRETAS
-- SELECT: Usuário pode ver funções da sua empresa
CREATE POLICY "funcoes_select_policy" ON funcoes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcoes.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- INSERT: Admin da empresa pode criar funções
CREATE POLICY "funcoes_insert_policy" ON funcoes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.user_id = auth.uid()
        AND f.empresa_id = funcoes.empresa_id
        AND f.tipo_admin IN ('admin_empresa', 'super_admin')
        AND f.status = 'ativo'
    )
  );

-- UPDATE: Admin da empresa pode atualizar funções
CREATE POLICY "funcoes_update_policy" ON funcoes
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.user_id = auth.uid()
        AND f.empresa_id = funcoes.empresa_id
        AND f.tipo_admin IN ('admin_empresa', 'super_admin')
        AND f.status = 'ativo'
    )
  );

-- DELETE: Admin da empresa pode deletar funções
CREATE POLICY "funcoes_delete_policy" ON funcoes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.user_id = auth.uid()
        AND f.empresa_id = funcoes.empresa_id
        AND f.tipo_admin IN ('admin_empresa', 'super_admin')
        AND f.status = 'ativo'
    )
  );

-- 4. Verificar estrutura final
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcoes'
ORDER BY ordinal_position;

-- 5. Verificar policies
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
WHERE tablename = 'funcoes';

-- 6. Testar SELECT (deve funcionar)
SELECT 
  f.id,
  f.empresa_id,
  f.nome,
  f.descricao,
  f.nivel,
  e.nome as empresa_nome
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
ORDER BY f.nivel, f.nome;
