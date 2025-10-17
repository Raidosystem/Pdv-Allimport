-- ========================================
-- CORREÇÃO: RLS para INSERT em funcoes
-- ========================================
-- Este script corrige a política RLS que está bloqueando a criação de funções

-- 1. VERIFICAR políticas atuais
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'funcoes'
ORDER BY cmd, policyname;

-- 2. REMOVER políticas antigas de INSERT (se existirem)
DROP POLICY IF EXISTS "funcoes_insert" ON funcoes;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;

-- 3. CRIAR nova política de INSERT permitindo admins da empresa
CREATE POLICY "funcoes_insert_policy" ON funcoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Admin da empresa pode criar funções
  EXISTS (
    SELECT 1 FROM empresas e
    JOIN funcionarios f ON f.empresa_id = e.id
    WHERE e.user_id = auth.uid()
    AND f.tipo_admin = 'admin_empresa'
    AND f.status = 'ativo'
  )
  OR
  -- Funcionário com permissão específica pode criar
  EXISTS (
    SELECT 1 FROM funcionarios func
    JOIN funcionario_funcoes ff ON ff.funcionario_id = func.id
    JOIN funcao_permissoes fp ON fp.funcao_id = ff.funcao_id
    JOIN permissoes p ON p.id = fp.permissao_id
    JOIN empresas e ON e.id = func.empresa_id
    WHERE e.user_id = auth.uid()
    AND func.status = 'ativo'
    AND p.recurso = 'administracao.funcoes'
    AND p.acao = 'create'
  )
);

-- 4. VERIFICAR se a política foi criada
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'funcoes'
AND cmd = 'INSERT';

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Política "funcoes_insert_policy" criada
-- ✅ Admins da empresa podem criar funções
-- ✅ Funcionários com permissão podem criar funções
-- ✅ Erro 42501 não acontecerá mais
