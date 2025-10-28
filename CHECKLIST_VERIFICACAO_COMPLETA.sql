-- =====================================================
-- CHECKLIST COMPLETO DE VERIFICAÇÃO
-- =====================================================

-- 1️⃣ Verificar se a função check_subscription_status existe
SELECT 
  routine_name,
  COUNT(*) as qtd_funcoes
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'check_subscription_status'
GROUP BY routine_name;

-- Se retornar 0 linhas = função NÃO EXISTE
-- Se retornar 1 linha = função EXISTE

-- 2️⃣ Testar a função manualmente
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Deve retornar:
-- {"has_subscription": true, "status": "active", "access_allowed": true, "days_remaining": 20, ...}

-- 3️⃣ Verificar dados brutos da subscription
SELECT 
  email,
  status,
  subscription_end_date,
  subscription_end_date > now() as ainda_valido,
  CASE 
    WHEN status = 'active' AND subscription_end_date > now() THEN '✅ DEVERIA TER ACESSO'
    ELSE '❌ SEM ACESSO'
  END as resultado_esperado
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';

-- 4️⃣ Se a função NÃO EXISTE, execute o script abaixo:
