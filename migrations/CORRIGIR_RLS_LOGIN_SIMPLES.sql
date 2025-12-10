-- 🔧 CORRIGIR RLS de login_funcionarios - SIMPLIFICADO

-- ❌ PROBLEMA: A política atual usa EXISTS com subquery complexo
-- ✅ SOLUÇÃO: Usar função que retorna empresa_id do funcionario

-- 1️⃣ Criar função helper para pegar empresa_id do funcionario
CREATE OR REPLACE FUNCTION get_funcionario_empresa_id(funcionario_uuid UUID)
RETURNS UUID
LANGUAGE sql
STABLE
AS $$
  SELECT empresa_id FROM funcionarios WHERE id = funcionario_uuid LIMIT 1;
$$;

-- 2️⃣ Remover política antiga
DROP POLICY IF EXISTS "login_funcionarios_empresa_policy" ON login_funcionarios CASCADE;

-- 3️⃣ Criar política SIMPLIFICADA usando a função
CREATE POLICY "login_funcionarios_empresa_policy"
ON login_funcionarios
FOR ALL
TO authenticated
USING (
  -- Permitir se o funcionario pertence à empresa do usuário logado
  get_funcionario_empresa_id(funcionario_id) = auth.uid()
)
WITH CHECK (
  -- Mesmo check para INSERT/UPDATE
  get_funcionario_empresa_id(funcionario_id) = auth.uid()
);

-- 4️⃣ Verificar se funcionou
SELECT 
  '✅ Política recriada!' as status,
  policyname,
  qual as using_expression
FROM pg_policies
WHERE tablename = 'login_funcionarios';

-- 5️⃣ Testar query (deve retornar login da Maria Silva)
SELECT 
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  get_funcionario_empresa_id(lf.funcionario_id) as empresa_do_funcionario
FROM login_funcionarios lf
WHERE lf.funcionario_id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';
