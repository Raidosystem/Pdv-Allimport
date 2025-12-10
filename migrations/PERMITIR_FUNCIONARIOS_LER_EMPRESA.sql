-- ✅ PERMITIR FUNCIONÁRIOS LEREM EMAIL DA EMPRESA
-- Problema: Após logout do admin, funcionário não consegue ler tabela empresas
-- Solução: RLS policy permitindo funcionários lerem dados básicos da empresa

-- 1. Verificar políticas existentes
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'empresas'
ORDER BY policyname;

-- 2. Criar política permitindo funcionários lerem empresa a que pertencem
CREATE POLICY "funcionarios_podem_ler_propria_empresa"
ON empresas
FOR SELECT
USING (
  -- Admin/empresa pode ler próprios dados
  id = auth.uid()
  OR
  -- Funcionário pode ler dados da empresa a que pertence
  EXISTS (
    SELECT 1 FROM funcionarios
    WHERE funcionarios.user_id = auth.uid()
    AND funcionarios.empresa_id = empresas.id
  )
);

-- 3. Verificar se a policy foi criada
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'empresas'
AND policyname = 'funcionarios_podem_ler_propria_empresa';
