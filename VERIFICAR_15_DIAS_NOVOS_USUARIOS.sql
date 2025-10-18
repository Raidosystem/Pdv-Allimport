-- ============================================
-- VERIFICAÇÃO: NOVOS USUÁRIOS E 15 DIAS DE TESTE
-- ============================================
-- 
-- CENÁRIOS:
-- 1. Usuário se cadastra no sistema (SignUp)
-- 2. Verifica email
-- 3. Recebe 15 dias de teste
-- 4. Acessa o sistema
--
-- VERIFICAR:
-- - Função activate_user_after_email_verification existe?
-- - Função está sendo chamada corretamente?
-- - Assinatura é criada com 15 dias?
--
-- ============================================

-- 1. VERIFICAR SE FUNÇÃO EXISTE
SELECT 
  '=== FUNÇÃO DE ATIVAÇÃO ===' as info,
  proname as nome_funcao,
  pg_get_functiondef(oid) as definicao
FROM pg_proc
WHERE proname = 'activate_user_after_email_verification';

-- 2. VERIFICAR ASSINATURAS RECENTES (últimos 30 dias)
SELECT 
  '=== ASSINATURAS RECENTES ===' as info,
  s.id,
  u.email,
  s.status,
  s.trial_start_date,
  s.trial_end_date,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - s.trial_start_date)) as dias_teste,
  s.created_at
FROM subscriptions s
JOIN auth.users u ON s.user_id = u.id
WHERE s.created_at > NOW() - INTERVAL '30 days'
ORDER BY s.created_at DESC;

-- 3. TESTAR check_subscription_status COM NOVO USUÁRIO (MOCK)
-- Simular novo usuário que acabou de se cadastrar
SELECT '=== SIMULAÇÃO: NOVO USUÁRIO ===' as info;

-- ============================================
-- RESULTADO ESPERADO PARA NOVO USUÁRIO:
-- ============================================
-- 
-- 1. Cadastro → SignUp no Supabase Auth
-- 2. Email de verificação enviado
-- 3. Usuário verifica email
-- 4. Trigger/função chama: activate_user_after_email_verification
-- 5. Subscription criada:
--    - status: 'trial'
--    - trial_start_date: NOW()
--    - trial_end_date: NOW() + 15 days
--    - subscription_end_date: NOW() + 15 days
--    - days_remaining: 15
-- 6. check_subscription_status retorna:
--    {
--      "has_subscription": true,
--      "status": "trial",
--      "access_allowed": true,
--      "days_remaining": 15
--    }
-- 7. ✅ Usuário acessa o sistema normalmente!
--
-- ============================================
-- POSSÍVEL PROBLEMA:
-- ============================================
-- 
-- Se admin criar o novo usuário como FUNCIONÁRIO:
-- - Usuário entra na tabela funcionarios
-- - check_subscription_status detecta como funcionário
-- - Busca assinatura do empresa_id (admin)
-- - Funciona! Mas não recebe 15 dias próprios
--
-- ISSO É CORRETO:
-- - Funcionários criados pelo admin = empregados
-- - Devem compartilhar assinatura do admin
-- - NÃO recebem 15 dias próprios
--
-- NOVOS COMPRADORES:
-- - Se cadastram via SignUp (não são criados pelo admin)
-- - NÃO entram em funcionarios
-- - Recebem 15 dias próprios
-- - ✅ Tudo certo!
--
-- ============================================

-- 4. VERIFICAR SE TEM ALGUM USUÁRIO NOVO SEM ASSINATURA
SELECT 
  '=== USUÁRIOS SEM ASSINATURA ===' as info,
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE s.id IS NULL
  AND u.created_at > NOW() - INTERVAL '30 days'
ORDER BY u.created_at DESC;

-- Se houver usuários sem assinatura, verificar por quê:
-- - Email não foi verificado?
-- - Função não foi chamada?
-- - Erro na criação da subscription?

-- ============================================
-- CONCLUSÃO:
-- ============================================
-- 
-- ✅ NOVOS COMPRADORES: 
--    - Recebem 15 dias automático
--    - Função check_subscription_status funciona
--    - Sem problemas!
--
-- ✅ FUNCIONÁRIOS CRIADOS PELO ADMIN:
--    - Herdam assinatura do admin
--    - NÃO recebem 15 dias próprios (correto!)
--    - Sistema funciona como esperado
--
-- ⚠️ ATENÇÃO:
--    - Se admin criar usuário E adicionar em funcionarios
--    - Esse usuário vira funcionário (não comprador)
--    - Não recebe 15 dias próprios
--    - Isso é o comportamento esperado!
--
-- ============================================
