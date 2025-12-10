-- ========================================
-- AJUSTAR TODAS AS POLÍTICAS RLS - ordens_servico
-- ========================================
-- Problema: Políticas SELECT, INSERT, DELETE muito restritivas
-- Solução: Permitir acesso por empresa_id OU usuario_id (consistente)
-- ========================================

-- 1. Remover políticas antigas
DROP POLICY IF EXISTS "ordens_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_insert_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_delete_policy" ON ordens_servico;

-- 2. Criar políticas consistentes com UPDATE

-- SELECT: Ver ordens da sua empresa ou criadas por você
CREATE POLICY "ordens_servico_select_simple" 
ON ordens_servico
FOR SELECT
USING (
  empresa_id = auth.uid() OR usuario_id = auth.uid()
);

-- INSERT: Criar ordens para sua empresa
CREATE POLICY "ordens_servico_insert_simple" 
ON ordens_servico
FOR INSERT
WITH CHECK (
  empresa_id = auth.uid() OR usuario_id = auth.uid()
);

-- DELETE: Deletar ordens da sua empresa ou criadas por você
CREATE POLICY "ordens_servico_delete_simple" 
ON ordens_servico
FOR DELETE
USING (
  empresa_id = auth.uid() OR usuario_id = auth.uid()
);

-- 3. Verificar todas as políticas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS "usando_condição",
  with_check AS "check_condição"
FROM pg_policies 
WHERE tablename = 'ordens_servico' 
ORDER BY cmd, policyname;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- Todas as 4 políticas devem ter:
-- USING/WITH CHECK: (empresa_id = auth.uid()) OR (usuario_id = auth.uid())
-- ========================================
