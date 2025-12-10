-- 🔧 CORRIGIR TABELA FUNCIONARIOS (ERRO 500)

-- 1. Verificar políticas problemáticas
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'funcionarios'
AND (
  qual LIKE '%funcoes%' OR 
  qual LIKE '%funcao_permissoes%' OR
  qual LIKE '%JOIN%'
);

-- 2. REMOVER políticas que podem estar causando loop/erro
DROP POLICY IF EXISTS "users_can_read_own_funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "usuarios_podem_ler_proprios_dados" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_podem_ler_proprios_dados" ON funcionarios;

-- 3. CRIAR política simples e funcional
CREATE POLICY "funcionarios_acesso_basico"
ON funcionarios
FOR ALL
USING (
  -- Admin/empresa pode acessar funcionários da empresa
  empresa_id = auth.uid()
  OR
  -- Funcionário pode acessar próprios dados
  user_id = auth.uid()
);

-- 4. Verificar se funcionou
SELECT COUNT(*) as total FROM funcionarios;

-- 5. Testar query específica que estava falhando
SELECT id FROM funcionarios 
WHERE empresa_id = auth.uid() 
AND status = 'ativo' 
LIMIT 1;
