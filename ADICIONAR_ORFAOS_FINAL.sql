-- ============================================================================
-- ADICIONAR OS 4 USUÁRIOS ÓRFÃOS EM user_approvals
-- ============================================================================

-- IMPORTANTE: Estes usuários existem em auth.users mas não em user_approvals
-- Vamos adicionar com status='approved' e user_role='owner'

-- 1️⃣ Inserir apenas os órfãos que realmente não existem em user_approvals
INSERT INTO user_approvals (
  user_id,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
)
SELECT 
  au.id as user_id,
  au.email,
  'approved' as status,
  'owner' as user_role,
  TRUE as email_verified,
  NOW() as approved_at,
  au.created_at
FROM auth.users au
WHERE au.email IN (
    'smartcellinova@gmail.com',
    'sousajenifer895@gmail.com',
    'jennifer@teste.com',
    'cris-ramos1979@hotmail.com.REMOVIDO'
  )
  AND NOT EXISTS (
    SELECT 1 FROM user_approvals ua 
    WHERE ua.user_id = au.id
  );

SELECT '✅ Usuários órfãos adicionados em user_approvals!' as resultado;

-- 2️⃣ Verificar se foram inseridos
SELECT 
  '✅ VERIFICAÇÃO PÓS-INSERT:' as info,
  email,
  status,
  user_role,
  approved_at,
  created_at
FROM user_approvals
WHERE email IN (
  'smartcellinova@gmail.com',
  'sousajenifer895@gmail.com',
  'jennifer@teste.com',
  'cris-ramos1979@hotmail.com.REMOVIDO'
)
ORDER BY created_at DESC;

-- 3️⃣ Ativar trial de 15 dias para os órfãos (se não tiverem)
SELECT activate_trial_for_new_user('smartcellinova@gmail.com');
SELECT activate_trial_for_new_user('sousajenifer895@gmail.com');
SELECT activate_trial_for_new_user('jennifer@teste.com');

SELECT '✅ Trials ativados!' as resultado;

-- 4️⃣ Contar total de aprovados agora
SELECT 
  '📊 TOTAL APROVADOS AGORA:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE status = 'approved' AND user_role = 'owner';

-- 5️⃣ Listar TODOS que devem aparecer no admin
SELECT 
  '📋 TODOS QUE DEVEM APARECER NO ADMIN:' as info,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE status = 'approved' AND user_role = 'owner'
ORDER BY created_at DESC;
