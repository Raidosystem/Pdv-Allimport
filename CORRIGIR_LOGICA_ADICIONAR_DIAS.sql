-- ========================================
-- 🔧 CORRIGIR LÓGICA DE ADICIONAR DIAS
-- ========================================
-- PROBLEMA: Ao adicionar dias, estava substituindo a data
-- SOLUÇÃO: Sempre SOMAR os dias à data de vencimento atual
-- ========================================

CREATE OR REPLACE FUNCTION admin_add_subscription_days(
  p_user_id UUID,
  p_days INTEGER,
  p_plan_type TEXT DEFAULT 'premium'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription_id UUID;
  v_current_end_date TIMESTAMPTZ;
  v_new_end_date TIMESTAMPTZ;
  v_status TEXT;
  v_base_date TIMESTAMPTZ;
BEGIN
  -- Buscar assinatura existente
  SELECT 
    id, 
    subscription_end_date,
    status
  INTO v_subscription_id, v_current_end_date, v_status
  FROM subscriptions
  WHERE user_id = p_user_id;

  -- Se não existe assinatura, criar nova
  IF v_subscription_id IS NULL THEN
    v_new_end_date := NOW() + (p_days || ' days')::INTERVAL;
    
    INSERT INTO subscriptions (
      user_id,
      status,
      plan_type,
      subscription_start_date,
      subscription_end_date,
      created_at,
      updated_at
    ) VALUES (
      p_user_id,
      CASE WHEN p_plan_type = 'trial' THEN 'trial' ELSE 'active' END,
      p_plan_type,
      NOW(),
      v_new_end_date,
      NOW(),
      NOW()
    )
    RETURNING id INTO v_subscription_id;

    RETURN json_build_object(
      'success', true,
      'message', 'Nova assinatura criada com ' || p_days || ' dias',
      'subscription_id', v_subscription_id,
      'end_date', v_new_end_date,
      'days_added', p_days
    );
  END IF;

  -- LÓGICA CORRIGIDA: Sempre somar à data existente
  -- Se a data atual já passou (expirou), começa de HOJE
  -- Se a data ainda é futura, SOMA os dias à data futura
  IF v_current_end_date IS NULL OR v_current_end_date < NOW() THEN
    -- Assinatura expirada ou sem data: começa de hoje
    v_base_date := NOW();
    v_new_end_date := v_base_date + (p_days || ' days')::INTERVAL;
    
    RAISE NOTICE '⚠️ Assinatura expirada. Base: HOJE. Novo vencimento: %', v_new_end_date;
  ELSE
    -- Assinatura ativa: SOMA dias à data de vencimento atual
    v_base_date := v_current_end_date;
    v_new_end_date := v_current_end_date + (p_days || ' days')::INTERVAL;
    
    RAISE NOTICE '✅ Assinatura ativa. Base: % + %d dias = %', v_current_end_date, p_days, v_new_end_date;
  END IF;

  -- Atualizar assinatura
  UPDATE subscriptions
  SET 
    subscription_end_date = v_new_end_date,
    status = CASE 
      WHEN p_plan_type = 'trial' THEN 'trial' 
      ELSE 'active' 
    END,
    plan_type = p_plan_type,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN json_build_object(
    'success', true,
    'message', p_days || ' dias adicionados com sucesso',
    'subscription_id', v_subscription_id,
    'previous_end_date', v_base_date,
    'new_end_date', v_new_end_date,
    'days_added', p_days,
    'total_days', EXTRACT(DAY FROM (v_new_end_date - NOW()))
  );
END;
$$;

-- ========================================
-- 🧪 TESTES DE VALIDAÇÃO
-- ========================================

-- Teste 1: Verificar estrutura da função
SELECT 
  '✅ FUNÇÃO RECRIADA' as status,
  proname as nome_funcao,
  pg_get_functiondef(oid) LIKE '%SOMA%' as tem_logica_soma
FROM pg_proc
WHERE proname = 'admin_add_subscription_days';

-- Teste 2: Mostrar assinaturas atuais ANTES de adicionar dias
SELECT 
  '📊 ASSINATURAS ANTES DO TESTE' as titulo;

SELECT 
  email,
  status,
  plan_type,
  subscription_end_date as vencimento_atual,
  CASE 
    WHEN subscription_end_date IS NULL THEN 'SEM DATA'
    WHEN subscription_end_date < NOW() THEN 'EXPIRADA'
    ELSE EXTRACT(DAY FROM (subscription_end_date - NOW()))::TEXT || ' dias restantes'
  END as situacao
FROM subscriptions
ORDER BY created_at DESC;

-- ========================================
-- 📝 EXEMPLO DE USO
-- ========================================

SELECT 
  '📝 EXEMPLO: Adicionar 30 dias premium' as titulo;

-- Descomentar linha abaixo para testar (substituir UUID pelo real):
-- SELECT admin_add_subscription_days('f7fdf4cf-7101-45ab-86db-5248a7ac58c1', 30, 'premium');

SELECT 
  '🎯 COMPORTAMENTO ESPERADO' as info,
  'Se assinatura vence em 20/12/2025 e adicionar 30 dias = 19/01/2026' as exemplo1,
  'Se assinatura vence em 01/12/2025 (expirada) e adicionar 30 dias = HOJE + 30 dias' as exemplo2,
  'Se adicionar 365 dias a uma assinatura com 100 dias = vencimento + 365 dias' as exemplo3;

SELECT 
  '⚠️ IMPORTANTE' as aviso,
  'SEMPRE soma à data existente (se ativa) ou à data de hoje (se expirada)' as regra;
