-- TESTE COMPLETO: Identificar por que o botão "Verificar Status" não funciona

-- EMAIL DE TESTE: assistenciaallimport10@gmail.com
-- PAYMENT ID: 126096480102 (já aprovado e processado)

-- 1. VERIFICAR DADOS ATUAIS
SELECT 
  '=== DADOS ATUAIS DA ASSINATURA ===' as info,
  email,
  status,
  subscription_start_date,
  subscription_end_date,
  payment_status,
  payment_id,
  (subscription_end_date::date - CURRENT_DATE) as dias_restantes_real,
  NOW() as hora_atual,
  subscription_end_date as data_vencimento,
  (subscription_end_date > NOW()) as ainda_valida,
  created_at,
  updated_at
FROM public.subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. VERIFICAR PAGAMENTO PROCESSADO
SELECT 
  '=== PAGAMENTO PROCESSADO ===' as info,
  payment_id,
  processed_at
FROM public.payments_processed 
WHERE payment_id = '126096480102';

-- 3. TESTAR FUNÇÃO RPC ATUAL (pode dar erro se não existir)
SELECT '=== TESTE FUNÇÃO RPC ATUAL ===' as info;
DO $$
BEGIN
  RAISE NOTICE 'Testando função check_subscription_status...';
  PERFORM check_subscription_status('assistenciaallimport10@gmail.com');
  RAISE NOTICE 'Função existe e funciona!';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'ERRO na função: %', SQLERRM;
END $$;

-- 4. RECRIAR/ATUALIZAR A FUNÇÃO RPC PARA FUNCIONAR CORRETAMENTE
CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  days_left INTEGER;
BEGIN
  RAISE NOTICE 'check_subscription_status chamada para: %', user_email;
  
  -- Buscar assinatura por EMAIL (não por user_id como antes)
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email
  LIMIT 1;
  
  IF NOT FOUND THEN
    RAISE NOTICE 'Nenhuma assinatura encontrada para: %', user_email;
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
  
  RAISE NOTICE 'Assinatura encontrada: status=%, end_date=%', subscription_record.status, subscription_record.subscription_end_date;
  
  -- Calcular dias restantes
  IF subscription_record.subscription_end_date IS NOT NULL THEN
    days_left := (subscription_record.subscription_end_date::date - CURRENT_DATE);
  ELSE
    days_left := 0;
  END IF;
  
  RAISE NOTICE 'Dias restantes calculados: %', days_left;
  
  -- Verificar se está em período de teste
  IF subscription_record.status = 'trial' THEN
    IF subscription_record.trial_end_date IS NOT NULL AND subscription_record.trial_end_date > now() THEN
      days_left := (subscription_record.trial_end_date::date - CURRENT_DATE);
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', days_left
      );
    ELSE
      -- Trial expirado, atualizar status
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Verificar se tem assinatura ativa
  IF subscription_record.status = 'active' THEN
    IF subscription_record.subscription_end_date IS NOT NULL AND subscription_record.subscription_end_date > now() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', GREATEST(days_left, 0)
      );
    ELSE
      -- Assinatura expirada, atualizar status
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Status expirado ou outros - sempre retornar dias_remaining
  RETURN json_build_object(
    'has_subscription', true,
    'status', subscription_record.status,
    'access_allowed', false,
    'subscription_end_date', subscription_record.subscription_end_date,
    'days_remaining', GREATEST(days_left, 0)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TESTAR A FUNÇÃO ATUALIZADA
SELECT 
  '=== RESULTADO DA FUNÇÃO ATUALIZADA ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado_json;

-- 6. VERIFICAR SE OS DIAS MUDARAM
SELECT 
  '=== VERIFICAÇÃO FINAL ===' as info,
  (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer as dias_retornados_pela_funcao,
  (subscription_end_date::date - CURRENT_DATE) as dias_calculados_diretamente
FROM public.subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 7. EXPLICAÇÃO DO PROBLEMA
SELECT 
  '=== DIAGNÓSTICO ===' as info,
  CASE 
    WHEN (check_subscription_status('assistenciaallimport10@gmail.com')->>'days_remaining')::integer > 25 THEN
      'SUCCESS: Função retorna dias atualizados! O problema estava na função RPC.'
    ELSE
      'PROBLEMA: Função ainda retorna 25 dias. Verificar se dados foram salvos corretamente.'
  END as diagnostico
FROM public.subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';