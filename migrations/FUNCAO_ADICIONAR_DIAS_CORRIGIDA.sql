-- ========================================
-- 🔧 FUNÇÃO COMPLETA: ADICIONAR DIAS COM SOMA
-- ========================================
-- Esta versão SEMPRE soma os dias aos existentes
-- Trata casos:
-- 1. Assinatura nova (sem data)
-- 2. Assinatura ativa (soma à data futura)
-- 3. Assinatura expirada (soma a partir de hoje)
-- 4. Pagamento antecipado (acumula dias)
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
  v_subscription RECORD;
  v_base_date TIMESTAMPTZ;
  v_new_end_date TIMESTAMPTZ;
  v_dias_atuais INTEGER;
  v_dias_finais INTEGER;
BEGIN
  -- Buscar assinatura completa
  SELECT 
    id,
    subscription_end_date,
    subscription_start_date,
    status,
    plan_type
  INTO v_subscription
  FROM subscriptions
  WHERE user_id = p_user_id;

  -- ========================================
  -- CASO 1: NÃO EXISTE ASSINATURA
  -- ========================================
  IF v_subscription.id IS NULL THEN
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
    RETURNING id INTO v_subscription;

    RETURN json_build_object(
      'success', true,
      'message', '✅ Nova assinatura criada com ' || p_days || ' dias',
      'subscription_id', v_subscription.id,
      'end_date', v_new_end_date,
      'days_added', p_days,
      'total_days', p_days
    );
  END IF;

  -- ========================================
  -- CASO 2 e 3: ASSINATURA EXISTE
  -- ========================================
  
  -- Determinar a data base para adicionar dias
  IF v_subscription.subscription_end_date IS NULL THEN
    -- Sem data de vencimento: começa de hoje
    v_base_date := NOW();
    v_dias_atuais := 0;
    
  ELSIF v_subscription.subscription_end_date < NOW() THEN
    -- Assinatura EXPIRADA: começa de hoje
    v_base_date := NOW();
    v_dias_atuais := 0;
    
  ELSE
    -- Assinatura ATIVA: SOMA à data existente
    v_base_date := v_subscription.subscription_end_date;
    v_dias_atuais := EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::INTEGER;
    
  END IF;

  -- Calcular nova data (SEMPRE somando)
  v_new_end_date := v_base_date + (p_days || ' days')::INTERVAL;
  v_dias_finais := EXTRACT(DAY FROM (v_new_end_date - NOW()))::INTEGER;

  -- Atualizar assinatura
  UPDATE subscriptions
  SET 
    subscription_end_date = v_new_end_date,
    subscription_start_date = COALESCE(subscription_start_date, NOW()),
    status = CASE 
      WHEN p_plan_type = 'trial' THEN 'trial' 
      ELSE 'active' 
    END,
    plan_type = p_plan_type,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Retornar resultado detalhado
  RETURN json_build_object(
    'success', true,
    'message', '✅ ' || p_days || ' dias adicionados com sucesso!',
    'subscription_id', v_subscription.id,
    'previous_end_date', v_base_date,
    'new_end_date', v_new_end_date,
    'days_had', v_dias_atuais,
    'days_added', p_days,
    'total_days', v_dias_finais,
    'status', CASE 
      WHEN v_subscription.subscription_end_date IS NULL THEN 'Primeira ativação'
      WHEN v_subscription.subscription_end_date < NOW() THEN 'Renovação (estava expirada)'
      ELSE 'Extensão (estava ativa)'
    END
  );
END;
$$;

-- ========================================
-- ✅ TESTES E VERIFICAÇÃO
-- ========================================

-- Mostrar todas as assinaturas atuais
SELECT 
  '📊 ESTADO ATUAL DAS ASSINATURAS' as titulo;

SELECT 
  email,
  status,
  plan_type,
  TO_CHAR(subscription_end_date, 'DD/MM/YYYY HH24:MI') as vencimento,
  CASE 
    WHEN subscription_end_date IS NULL THEN '⚠️ SEM DATA'
    WHEN subscription_end_date < NOW() THEN '❌ EXPIRADA há ' || EXTRACT(DAY FROM (NOW() - subscription_end_date))::TEXT || ' dias'
    ELSE '✅ ATIVA - ' || EXTRACT(DAY FROM (subscription_end_date - NOW()))::TEXT || ' dias restantes'
  END as situacao,
  TO_CHAR(updated_at, 'DD/MM/YYYY HH24:MI') as ultima_atualizacao
FROM subscriptions
ORDER BY 
  CASE 
    WHEN subscription_end_date IS NULL THEN 1
    WHEN subscription_end_date < NOW() THEN 2
    ELSE 3
  END,
  subscription_end_date DESC;

-- ========================================
-- 📝 EXEMPLOS DE USO
-- ========================================

SELECT 
  '📝 EXEMPLOS DE COMPORTAMENTO' as titulo;

SELECT '
EXEMPLO 1: Assinatura com 100 dias + adicionar 365 dias
- Tinha: 100 dias (vence em 03/03/2026)
- Adiciona: 365 dias
- Resultado: 465 dias (vence em 03/03/2027)

EXEMPLO 2: Assinatura expirada + adicionar 30 dias
- Tinha: Expirou em 01/11/2025
- Adiciona: 30 dias
- Resultado: 30 dias (vence em 24/12/2025)

EXEMPLO 3: Pagamento antecipado
- Tinha: 200 dias restantes
- Paga mais 365 dias
- Resultado: 565 dias acumulados

EXEMPLO 4: Nova assinatura
- Não tinha assinatura
- Adiciona: 365 dias
- Resultado: 365 dias (vence em 24/11/2026)
' as explicacao;

-- ========================================
-- 🎯 PRÓXIMO PASSO
-- ========================================

SELECT 
  '🎯 PRÓXIMOS PASSOS' as titulo,
  '1. Execute este script no Supabase SQL Editor' as passo1,
  '2. Limpe o cache do navegador (Ctrl+Shift+Delete)' as passo2,
  '3. Recarregue a página com Ctrl+Shift+R' as passo3,
  '4. Teste adicionar dias no Admin Dashboard' as passo4,
  '5. Verifique se os dias foram SOMADOS e não substituídos' as passo5;
