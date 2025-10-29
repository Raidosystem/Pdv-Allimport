-- =====================================================
-- 🔧 CORRIGIR RLS DA TABELA FUNCIONARIO_FUNCOES
-- =====================================================
-- Erro 403: funcionario_funcoes precisa de policies
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR SE A TABELA EXISTE
-- =====================================================

SELECT 
  table_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_tables 
      WHERE schemaname = 'public' 
        AND tablename = 'funcionario_funcoes'
    ) THEN '✅ Tabela existe'
    ELSE '❌ Tabela não existe'
  END as status
FROM (SELECT 'funcionario_funcoes' as table_name) t;

-- =====================================================
-- 2️⃣ VER POLICIES ATUAIS
-- =====================================================

SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'funcionario_funcoes'
ORDER BY cmd;

-- =====================================================
-- 3️⃣ ATIVAR RLS NA TABELA
-- =====================================================

ALTER TABLE funcionario_funcoes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4️⃣ CRIAR POLICIES NECESSÁRIAS
-- =====================================================

-- Remover policies antigas se existirem
DROP POLICY IF EXISTS "select_own_funcionario_funcoes" ON funcionario_funcoes;
DROP POLICY IF EXISTS "insert_own_funcionario_funcoes" ON funcionario_funcoes;
DROP POLICY IF EXISTS "update_own_funcionario_funcoes" ON funcionario_funcoes;
DROP POLICY IF EXISTS "delete_own_funcionario_funcoes" ON funcionario_funcoes;

-- POLICY DE SELECT (Leitura)
CREATE POLICY "select_own_funcionario_funcoes"
ON funcionario_funcoes
FOR SELECT
TO authenticated
USING (
  -- Permitir se o funcionário pertence à empresa do usuário
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcionario_funcoes.funcionario_id
      AND (e.user_id = auth.uid() OR e.email = (auth.jwt()->>'email'))
  )
);

-- POLICY DE INSERT (Criação)
CREATE POLICY "insert_own_funcionario_funcoes"
ON funcionario_funcoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Permitir se o funcionário pertence à empresa do usuário
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcionario_funcoes.funcionario_id
      AND (e.user_id = auth.uid() OR e.email = (auth.jwt()->>'email'))
  )
);

-- POLICY DE UPDATE (Edição)
CREATE POLICY "update_own_funcionario_funcoes"
ON funcionario_funcoes
FOR UPDATE
TO authenticated
USING (
  -- Permitir se o funcionário pertence à empresa do usuário
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcionario_funcoes.funcionario_id
      AND (e.user_id = auth.uid() OR e.email = (auth.jwt()->>'email'))
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcionario_funcoes.funcionario_id
      AND (e.user_id = auth.uid() OR e.email = (auth.jwt()->>'email'))
  )
);

-- POLICY DE DELETE (Exclusão)
CREATE POLICY "delete_own_funcionario_funcoes"
ON funcionario_funcoes
FOR DELETE
TO authenticated
USING (
  -- Permitir se o funcionário pertence à empresa do usuário
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.id = funcionario_funcoes.funcionario_id
      AND (e.user_id = auth.uid() OR e.email = (auth.jwt()->>'email'))
  )
);

-- =====================================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- =====================================================

-- Ver policies criadas (deve ter 4)
SELECT 
  '✅ Policies configuradas' as status,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'funcionario_funcoes'
ORDER BY cmd;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ 4 policies criadas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Erro 403 em funcionario_funcoes deve desaparecer
-- ✅ Atribuição de funções aos funcionários deve funcionar
-- =====================================================
