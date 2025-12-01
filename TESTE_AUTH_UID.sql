-- ========================================
-- TESTAR SE auth.uid() BATE COM empresa_id
-- ========================================

-- 1. Seu auth.uid() atual
SELECT auth.uid() AS "Meu User ID";

-- 2. empresa_id das ordens
SELECT DISTINCT empresa_id AS "Empresa ID nas Ordens"
FROM ordens_servico;

-- 3. Comparar: você consegue ver as ordens?
SELECT 
  COUNT(*) as total_visivel,
  CASE 
    WHEN COUNT(*) = 161 THEN '✅ VÊ TODAS (161)'
    WHEN COUNT(*) = 0 THEN '❌ NÃO VÊ NENHUMA'
    ELSE '⚠️ VÊ PARCIAL: ' || COUNT(*)
  END as status
FROM ordens_servico
WHERE empresa_id = auth.uid() OR user_id = auth.uid();

-- 4. Teste DIRETO: simular query JavaScript
SELECT COUNT(*) as "Total Via JavaScript"
FROM ordens_servico;

-- 5. Ver se a política está funcionando
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN substring(qual::text, 1, 150)
    ELSE 'N/A'
  END as condicao
FROM pg_policies
WHERE tablename = 'ordens_servico'
ORDER BY cmd;
