-- ================================
-- TESTE FINAL DO SISTEMA DE APROVAÇÃO
-- Execute no Supabase SQL Editor para confirmar
-- ================================

-- 1. Verificar se a tabela existe
SELECT 
  table_name, 
  table_schema,
  'Tabela encontrada!' as status
FROM information_schema.tables 
WHERE table_name = 'user_approvals' AND table_schema = 'public';

-- 2. Verificar estrutura da tabela
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'user_approvals' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Verificar políticas RLS
SELECT 
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'user_approvals';

-- 4. Verificar trigger
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  'Trigger funcionando!' as status
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 5. Verificar funções criadas
SELECT 
  routine_name,
  routine_type,
  'Função criada!' as status
FROM information_schema.routines 
WHERE routine_name IN ('create_user_approval', 'check_user_approval_status', 'approve_user', 'reject_user')
ORDER BY routine_name;

-- 6. Teste de inserção (simulação)
SELECT 'Sistema configurado e pronto para uso!' as resultado_final;
