-- =============================================
-- REMOVER POLÍTICA RESTRITIVA QUE CAUSA SUMIÇO DE CLIENTES
-- =============================================

-- Problema: A política "Users can only see their own clientes" com cmd=ALL
-- está bloqueando acesso a clientes de outros user_ids (do backup)

-- Solução: Remover esta política restritiva
DROP POLICY IF EXISTS "Users can only see their own clientes" ON clientes;

-- As políticas permissivas já existentes (com true) continuam funcionando:
-- - clientes_insert_policy
-- - clientes_select_policy  
-- - clientes_update_policy
-- - clientes_delete_policy

-- Verificar políticas após remoção
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- Resultado esperado: Apenas as 4 políticas permissivas (sem a restritiva ALL)
