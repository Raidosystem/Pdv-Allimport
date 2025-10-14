-- ========================================
-- PASSO 3: CORRIGIR SEU USUÁRIO ATUAL
-- ========================================
-- Substitua 'SEU-EMAIL-AQUI' pelo email que você usou no cadastro

-- Ver seus dados atuais
SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- ATIVAR 15 DIAS PARA SEU USUÁRIO
-- Substitua o email abaixo pelo seu email real:
SELECT activate_user_after_email_verification('SEU-EMAIL-AQUI@exemplo.com');

-- Verificar se funcionou
SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
WHERE email = 'SEU-EMAIL-AQUI@exemplo.com';

-- Resultado esperado:
-- status: 'trial'
-- email_verified: true
-- dias_restantes: 15

-- ✅ PRONTO! Agora faça logout e login novamente no sistema
