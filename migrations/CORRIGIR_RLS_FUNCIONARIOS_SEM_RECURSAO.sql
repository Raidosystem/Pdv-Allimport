-- 🔥 CORRIGIR RECURSÃO INFINITA NAS POLÍTICAS RLS DE FUNCIONARIOS

-- ⚠️ PROBLEMA: As políticas criadas causam recursão infinita porque:
-- - A política SELECT busca funcionarios para verificar empresa_id
-- - Mas para buscar funcionarios, precisa executar SELECT novamente
-- - Isso cria um loop infinito: SELECT → funcionarios → SELECT → funcionarios...

-- 📋 PASSO 1: REMOVER POLÍTICAS COM RECURSÃO
DROP POLICY IF EXISTS "funcionarios_select_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_empresa" ON funcionarios;

-- 📋 PASSO 2: CRIAR POLÍTICAS SEM RECURSÃO

-- 🔍 SELECT: Acesso direto pela empresa (SEM subquery recursiva)
CREATE POLICY "funcionarios_select_simples"
ON funcionarios FOR SELECT
TO authenticated
USING (
  -- OPÇÃO 1: Sou dono da empresa (busca direta em empresas)
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- ➕ INSERT: Apenas na minha empresa
CREATE POLICY "funcionarios_insert_simples"
ON funcionarios FOR INSERT
TO authenticated
WITH CHECK (
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- ✏️ UPDATE: Apenas funcionários da minha empresa
CREATE POLICY "funcionarios_update_simples"
ON funcionarios FOR UPDATE
TO authenticated
USING (
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
)
WITH CHECK (
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- 🗑️ DELETE: Apenas funcionários da minha empresa
CREATE POLICY "funcionarios_delete_simples"
ON funcionarios FOR DELETE
TO authenticated
USING (
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
);

-- 📋 PASSO 3: VERIFICAR POLÍTICAS APLICADAS
SELECT 
  '✅ Políticas Corrigidas' as status,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY cmd, policyname;

-- 📋 PASSO 4: TESTE DE ACESSO (deve funcionar sem erro 500)
SELECT 
  '🧪 Teste' as label,
  COUNT(*) as total_funcionarios
FROM funcionarios;

-- 🎯 EXPLICAÇÃO DA CORREÇÃO:
-- ✅ ANTES (com recursão):
--    SELECT from funcionarios → precisa checar empresa_id
--    → busca em funcionarios (recursão!) → erro 500
--
-- ✅ DEPOIS (sem recursão):
--    SELECT from funcionarios → busca direto em empresas
--    → retorna empresa_id → sem recursão → funciona!
