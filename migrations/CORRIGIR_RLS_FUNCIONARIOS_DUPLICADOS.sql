-- 🔒 CORRIGIR POLÍTICAS RLS DUPLICADAS E PERMISSIVAS EM FUNCIONARIOS

-- ⚠️ PROBLEMA IDENTIFICADO:
-- 1. Políticas duplicadas (allow_all_* + funcionarios_*_policy)
-- 2. Políticas PUBLIC muito permissivas (qualquer um pode acessar)
-- 3. Falta isolamento por empresa_id ou user_id

-- 📋 PASSO 1: REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "allow_all_authenticated_delete_funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "allow_all_authenticated_insert_funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "allow_all_authenticated_select_funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "allow_all_authenticated_update_funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_acesso_basico" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_select_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_policy" ON funcionarios;

-- 📋 PASSO 2: VERIFICAR SE RLS ESTÁ HABILITADO
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

-- 📋 PASSO 3: CRIAR POLÍTICAS CORRETAS E SEGURAS

-- 🔍 SELECT: Ver funcionários da mesma empresa
CREATE POLICY "funcionarios_select_empresa"
ON funcionarios FOR SELECT
TO authenticated
USING (
  -- Opção 1: Sou dono da empresa (empresas.user_id = auth.uid())
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
  OR
  -- Opção 2: Sou funcionário dessa empresa
  empresa_id IN (SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid())
);

-- ➕ INSERT: Criar funcionários na minha empresa
CREATE POLICY "funcionarios_insert_empresa"
ON funcionarios FOR INSERT
TO authenticated
WITH CHECK (
  -- Só posso criar funcionários na minha empresa
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- ✏️ UPDATE: Atualizar funcionários da minha empresa
CREATE POLICY "funcionarios_update_empresa"
ON funcionarios FOR UPDATE
TO authenticated
USING (
  -- Só posso atualizar funcionários da minha empresa
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
)
WITH CHECK (
  -- E não posso mover para outra empresa
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- 🗑️ DELETE: Remover funcionários da minha empresa
CREATE POLICY "funcionarios_delete_empresa"
ON funcionarios FOR DELETE
TO authenticated
USING (
  -- Só posso deletar funcionários da minha empresa
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- 📋 PASSO 4: VERIFICAR POLÍTICAS CRIADAS
SELECT 
  '✅ Políticas Aplicadas' as status,
  policyname,
  cmd,
  roles,
  CASE 
    WHEN roles = '{authenticated}' THEN '✅ Seguro'
    WHEN roles = '{public}' THEN '⚠️ PÚBLICO (verificar)'
    ELSE '❓ Verificar'
  END as nivel_seguranca
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY cmd, policyname;

-- 📋 PASSO 5: TESTE DE ACESSO
-- Execute com um usuário autenticado no sistema web
SELECT 
  '🧪 Teste de Acesso' as teste,
  COUNT(*) as total_funcionarios_visiveis
FROM funcionarios;

-- 🎯 RESULTADO ESPERADO:
-- ✅ Apenas 4 políticas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Todas com role 'authenticated'
-- ✅ Isolamento por empresa_id
-- ✅ Usuários só veem funcionários da própria empresa
