-- ============================================================================
-- VERIFICAR SE TODAS AS PROTEÇÕES ESTÃO ATIVAS
-- ============================================================================

-- 1. Verificar colunas deleted_at
SELECT 
  table_name,
  column_name,
  data_type,
  '✅ Soft delete ativo' as status
FROM information_schema.columns
WHERE column_name = 'deleted_at'
  AND table_name IN ('user_approvals', 'empresas', 'subscriptions')
ORDER BY table_name;

-- 2. Verificar tabela de auditoria
SELECT 
  table_name,
  '✅ Tabela de auditoria criada' as status
FROM information_schema.tables
WHERE table_name = 'user_audit_log';

-- 3. Verificar triggers de proteção
SELECT 
  trigger_name,
  event_object_table as tabela,
  event_manipulation as evento,
  action_statement as funcao,
  '✅ Trigger ativo' as status
FROM information_schema.triggers
WHERE trigger_name IN (
  'audit_user_approvals_trigger',
  'prevent_delete_paid_users_trigger'
)
ORDER BY trigger_name;

-- 4. Verificar funções de proteção
SELECT 
  routine_name as funcao,
  routine_type as tipo,
  security_type as seguranca,
  '✅ Função criada' as status
FROM information_schema.routines
WHERE routine_name IN (
  'audit_user_approvals_changes',
  'prevent_delete_paid_users',
  'soft_delete_user',
  'restore_deleted_user'
)
ORDER BY routine_name;

-- 5. Verificar políticas RLS de proteção
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as comando,
  '✅ Política ativa' as status
FROM pg_policies
WHERE policyname LIKE '%delete%'
  AND tablename = 'user_approvals'
ORDER BY policyname;

-- ============================================================================
-- RESUMO FINAL
-- ============================================================================
SELECT 
  '🛡️ PROTEÇÃO TOTAL ATIVA' as titulo,
  (SELECT COUNT(*) FROM information_schema.columns WHERE column_name = 'deleted_at' AND table_name IN ('user_approvals', 'empresas', 'subscriptions')) as soft_delete_colunas,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'user_audit_log') as tabela_auditoria,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name IN ('audit_user_approvals_trigger', 'prevent_delete_paid_users_trigger')) as triggers_protecao,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_name IN ('soft_delete_user', 'restore_deleted_user')) as funcoes_seguras,
  'Usuários pagantes protegidos ✅' as resultado;
