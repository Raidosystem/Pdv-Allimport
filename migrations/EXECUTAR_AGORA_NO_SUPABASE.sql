-- =====================================================
-- ⚡ EXECUTAR ESTE SQL NO SUPABASE AGORA
-- =====================================================
-- Dashboard > SQL Editor > New Query > Cole isto e Execute (F5)
-- =====================================================

-- 1️⃣ PRIMEIRO: Verificar se a função já existe
SELECT 
  routine_name,
  'Função EXISTE' as status
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'check_subscription_status';

-- Se retornar 0 linhas = Função NÃO EXISTE (precisa criar)
-- Se retornar 1 linha = Função JÁ EXISTE (pode substituir)

-- =====================================================
-- 2️⃣ CRIAR OU SUBSTITUIR A FUNÇÃO
-- =====================================================

-- Remover função antiga se existir
DROP FUNCTION IF EXISTS check_subscription_status(text);

-- Criar função CORRIGIDA
CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription RECORD;
  v_days_remaining integer;
  v_access_allowed boolean;
  v_status text;
BEGIN
  -- Buscar assinatura do usuário
  SELECT *
  INTO v_subscription
  FROM subscriptions
  WHERE email = user_email
  ORDER BY created_at DESC
  LIMIT 1;

  -- Se não encontrou assinatura
  IF v_subscription IS NULL THEN
    RETURN jsonb_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;

  -- Inicializar valores
  v_status := v_subscription.status;
  v_access_allowed := false;
  v_days_remaining := 0;

  -- Verificar PREMIUM ATIVO
  IF v_subscription.status = 'active' 
     AND v_subscription.subscription_end_date IS NOT NULL 
     AND v_subscription.subscription_end_date > now() THEN
    
    -- Calcular dias restantes (arredondado para cima)
    v_days_remaining := CEIL(EXTRACT(EPOCH FROM (v_subscription.subscription_end_date - now())) / 86400)::integer;
    v_access_allowed := true;
    v_status := 'active';
    
    RAISE NOTICE '✅ Premium ativo: % dias restantes', v_days_remaining;

  -- Verificar TRIAL ATIVO
  ELSIF v_subscription.status = 'trial'
     AND v_subscription.trial_end_date IS NOT NULL
     AND v_subscription.trial_end_date > now() THEN
    
    -- Calcular dias restantes (arredondado para cima)
    v_days_remaining := CEIL(EXTRACT(EPOCH FROM (v_subscription.trial_end_date - now())) / 86400)::integer;
    v_access_allowed := true;
    v_status := 'trial';
    
    RAISE NOTICE '✅ Trial ativo: % dias restantes', v_days_remaining;

  -- Verificar EXPIRADO
  ELSIF (v_subscription.status = 'active' AND v_subscription.subscription_end_date <= now())
     OR (v_subscription.status = 'trial' AND v_subscription.trial_end_date <= now()) THEN
    
    v_status := 'expired';
    v_access_allowed := false;
    v_days_remaining := 0;
    
    RAISE NOTICE '❌ Assinatura expirada';

  ELSE
    -- Qualquer outro caso (pending, cancelled, etc)
    v_status := v_subscription.status;
    v_access_allowed := false;
    v_days_remaining := 0;
    
    RAISE NOTICE '⚠️ Status: %', v_status;
  END IF;

  -- Retornar resultado
  RETURN jsonb_build_object(
    'has_subscription', true,
    'status', v_status,
    'access_allowed', v_access_allowed,
    'days_remaining', v_days_remaining,
    'plan_type', v_subscription.plan_type,
    'subscription_end_date', v_subscription.subscription_end_date,
    'trial_end_date', v_subscription.trial_end_date
  );
END;
$$;

-- Dar permissões
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO anon;

-- Comentário
COMMENT ON FUNCTION check_subscription_status(text) IS 
  'Verifica o status da assinatura de um usuário e retorna se tem acesso permitido ao sistema';

-- =====================================================
-- 3️⃣ TESTAR A FUNÇÃO COM O USUÁRIO ESPECÍFICO
-- =====================================================

-- Executar e verificar resultado
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Deve retornar:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "access_allowed": true,     ← ESTE DEVE SER true!
--   "days_remaining": 20,
--   "plan_type": "yearly",
--   "subscription_end_date": "2025-11-17...",
--   "trial_end_date": null
-- }

-- =====================================================
-- 4️⃣ VERIFICAR DADOS BRUTOS
-- =====================================================

-- Conferir dados diretamente na tabela
SELECT 
  email,
  status,
  subscription_end_date,
  subscription_end_date > now() as ainda_valido,
  EXTRACT(EPOCH FROM (subscription_end_date - now())) / 86400 as dias_decimais,
  CEIL(EXTRACT(EPOCH FROM (subscription_end_date - now())) / 86400) as dias_inteiros,
  CASE 
    WHEN status = 'active' AND subscription_end_date > now() THEN '✅ DEVERIA TER ACESSO'
    ELSE '❌ SEM ACESSO'
  END as resultado_esperado
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- Se tudo estiver correto:
-- ✅ Função criada sem erros
-- ✅ Teste retorna access_allowed = true
-- ✅ Dados brutos mostram "DEVERIA TER ACESSO"
-- 
-- Depois de executar, faça:
-- 1. Aguarde 2 minutos para o novo deploy terminar
-- 2. Abra o site em aba anônima (Ctrl+Shift+N)
-- 3. Faça login com cris-ramos30@hotmail.com
-- 4. Abra Console (F12) e procure por:
--    📊 [SubscriptionGuard] Decisão JSON
-- 5. Verifique se "access_allowed": true
-- =====================================================
