-- ========================================
-- REMOVER POLÍTICA DUPLICADA
-- ========================================
-- Problema: Duas políticas de UPDATE causando conflito
-- Solução: Remover a mais restritiva e manter apenas a simplificada
-- ========================================

-- 1. Remover a política duplicada/restritiva
DROP POLICY IF EXISTS "ordens_update_policy" ON ordens_servico;

-- 2. Verificar políticas restantes
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
WHERE tablename = 'ordens_servico' 
ORDER BY cmd, policyname;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- Deve mostrar apenas:
-- - ordens_servico_update_simple (UPDATE)
-- - Políticas para SELECT, INSERT, DELETE
-- ========================================
