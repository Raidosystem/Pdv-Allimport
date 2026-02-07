-- ============================================
-- VERIFICAR SE USUÁRIO FOI DELETADO COMPLETAMENTE
-- ============================================

-- Substitua 'EMAIL_DO_USUARIO' pelo email que você deletou

-- PASSO 1: Verificar em auth.users
SELECT 
  'auth.users' as tabela,
  COUNT(*) as registros
FROM auth.users
WHERE email = 'EMAIL_DO_USUARIO';

-- PASSO 2: Verificar em user_approvals
SELECT 
  'user_approvals' as tabela,
  COUNT(*) as registros
FROM user_approvals
WHERE email = 'EMAIL_DO_USUARIO';

-- PASSO 3: Verificar em empresas
SELECT 
  'empresas' as tabela,
  COUNT(*) as registros
FROM empresas
WHERE email = 'EMAIL_DO_USUARIO';

-- PASSO 4: Verificar em subscriptions
SELECT 
  'subscriptions' as tabela,
  COUNT(*) as registros
FROM subscriptions
WHERE email = 'EMAIL_DO_USUARIO';

-- PASSO 5: Verificar em funcionarios (se existir)
SELECT 
  'funcionarios' as tabela,
  COUNT(*) as registros
FROM funcionarios
WHERE email = 'EMAIL_DO_USUARIO';

-- PASSO 6: Resultado esperado
SELECT 
  '✅ RESULTADO ESPERADO:' as mensagem
UNION ALL
SELECT '  Todas as tabelas devem retornar 0 registros'
UNION ALL
SELECT '  Se alguma retornar > 0, o CASCADE não funcionou';
