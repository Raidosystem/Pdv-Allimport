-- 🔥 DIAGNÓSTICO E CORREÇÃO COMPLETA - RECURSÃO INFINITA

-- 🔍 PASSO 1: VERIFICAR POLÍTICAS ATUAIS
SELECT 
  '🔍 Políticas Funcionarios' as tabela,
  policyname,
  cmd,
  roles,
  CASE 
    WHEN qual LIKE '%funcionarios%' THEN '⚠️ RECURSÃO DETECTADA'
    ELSE '✅ OK'
  END as status_recursao
FROM pg_policies
WHERE tablename = 'funcionarios'

UNION ALL

SELECT 
  '🔍 Políticas Empresas' as tabela,
  policyname,
  cmd,
  roles,
  CASE 
    WHEN qual LIKE '%empresas%' THEN '⚠️ RECURSÃO DETECTADA'
    ELSE '✅ OK'
  END as status_recursao
FROM pg_policies
WHERE tablename = 'empresas'
ORDER BY tabela, cmd;

-- 🔥 PASSO 2: REMOVER TODAS AS POLÍTICAS PROBLEMÁTICAS

-- Remover políticas de funcionarios
DROP POLICY IF EXISTS "funcionarios_select_simples" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_simples" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_simples" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_simples" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_select_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_empresa" ON funcionarios;

-- Remover políticas de empresas (se existirem políticas problemáticas)
DROP POLICY IF EXISTS "empresas_select_owner" ON empresas;
DROP POLICY IF EXISTS "empresas_insert_owner" ON empresas;
DROP POLICY IF EXISTS "empresas_update_owner" ON empresas;
DROP POLICY IF EXISTS "empresas_delete_owner" ON empresas;

-- 🔥 PASSO 3: CRIAR POLÍTICAS 100% SEM RECURSÃO

-- ✅ EMPRESAS: Políticas simples baseadas em user_id
CREATE POLICY "empresas_all_owner"
ON empresas FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ✅ FUNCIONARIOS: Acesso direto (SEM consultar funcionarios novamente!)
CREATE POLICY "funcionarios_all_access"
ON funcionarios FOR ALL
TO authenticated
USING (
  -- Busca direto em empresas (SEM recursão!)
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 🔍 PASSO 4: VERIFICAR RESULTADO
SELECT 
  '✅ Verificação Final' as status,
  tablename,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename IN ('funcionarios', 'empresas')
ORDER BY tablename, cmd;

-- 🧪 PASSO 5: TESTE SIMPLES
SELECT 
  '🧪 Teste Empresas' as teste,
  COUNT(*) as total
FROM empresas;

SELECT 
  '🧪 Teste Funcionarios' as teste,
  COUNT(*) as total
FROM funcionarios;
