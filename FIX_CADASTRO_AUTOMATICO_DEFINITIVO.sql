-- ============================================================================
-- FIX DEFINITIVO: CADASTRO AUTOMÁTICO COM 15 DIAS DE TESTE
-- ============================================================================
-- 
-- PROBLEMA: Novos usuários não recebem 15 dias de teste automaticamente
-- SOLUÇÃO: Garantir que as funções RPC estão criadas e funcionando
--
-- EXECUTE ESTE SQL NO SUPABASE SQL EDITOR
-- ============================================================================

-- ============================================================================
-- PASSO 1: Criar função para ativar trial (SECURITY DEFINER bypassa RLS)
-- ============================================================================

CREATE OR REPLACE FUNCTION activate_trial_for_new_user(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- IMPORTANTE: Bypassa RLS
AS $$
DECLARE
  v_user_id UUID;
  v_trial_end_date TIMESTAMPTZ;
  v_existing_subscription RECORD;
BEGIN
  RAISE NOTICE '🎯 [TRIAL] Ativando trial para: %', user_email;
  
  -- Buscar user_id do usuário
  SELECT user_id INTO v_user_id
  FROM user_approvals
  WHERE email = user_email
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️ [TRIAL] Usuário não encontrado em user_approvals';
    RETURN json_build_object(
      'success', false, 
      'error', 'Usuário não encontrado',
      'trial_end_date', NULL,
      'days_remaining', 0
    );
  END IF;
  
  RAISE NOTICE '✅ [TRIAL] Usuário encontrado: %', v_user_id;
  
  -- Verificar se já tem assinatura
  SELECT * INTO v_existing_subscription
  FROM subscriptions
  WHERE user_id = v_user_id OR email = user_email
  LIMIT 1;
  
  IF FOUND THEN
    RAISE NOTICE 'ℹ️ [TRIAL] Assinatura já existe para este usuário';
    
    -- Calcular dias restantes
    DECLARE
      v_days_remaining INTEGER;
    BEGIN
      v_days_remaining := GREATEST(0, EXTRACT(DAY FROM (v_existing_subscription.trial_end_date - NOW()))::INTEGER);
      
      RETURN json_build_object(
        'success', true,
        'message', 'Assinatura já existe',
        'trial_end_date', v_existing_subscription.trial_end_date,
        'days_remaining', v_days_remaining
      );
    END;
  END IF;
  
  -- Calcular data de fim do trial (15 dias a partir de agora)
  v_trial_end_date := NOW() + INTERVAL '15 days';
  
  RAISE NOTICE '📅 [TRIAL] Criando assinatura trial até: %', v_trial_end_date;
  
  -- Criar assinatura trial
  INSERT INTO subscriptions (
    user_id,
    email,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    user_email,
    'trial',          -- Status trial
    'free',           -- Plano free durante trial
    NOW(),            -- Início do trial
    v_trial_end_date, -- Fim do trial (15 dias)
    NOW(),            -- Data de início da "assinatura"
    v_trial_end_date, -- Data de fim (mesmo que trial)
    NOW(),
    NOW()
  );
  
  RAISE NOTICE '✅ [TRIAL] Trial de 15 dias ativado com sucesso!';
  
  RETURN json_build_object(
    'success', true,
    'message', '15 dias de teste ativados com sucesso!',
    'trial_end_date', v_trial_end_date,
    'days_remaining', 15
  );
  
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ [TRIAL] Erro ao ativar trial: %', SQLERRM;
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM,
    'trial_end_date', NULL,
    'days_remaining', 0
  );
END;
$$;

-- Dar permissões para a função
GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(TEXT) TO service_role;

SELECT '✅ PASSO 1: Função activate_trial_for_new_user criada!' as status;

-- ============================================================================
-- PASSO 2: Criar função para aprovar usuário após verificação de email
-- ============================================================================

CREATE OR REPLACE FUNCTION approve_user_after_email_verification(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- IMPORTANTE: Bypassa RLS
AS $$
DECLARE
  v_updated BOOLEAN := FALSE;
  v_user_id UUID;
  v_trial_result JSON;
BEGIN
  RAISE NOTICE '🎯 [APROVACAO] Aprovando usuário: %', user_email;
  
  -- Atualizar user_approvals
  UPDATE user_approvals 
  SET 
    status = 'approved',
    user_role = 'owner',
    approved_at = NOW(),
    email_verified = TRUE,
    updated_at = NOW()
  WHERE email = user_email
  RETURNING user_id INTO v_user_id;
  
  IF v_user_id IS NOT NULL THEN
    v_updated := TRUE;
    RAISE NOTICE '✅ [APROVACAO] Usuário aprovado: % (ID: %)', user_email, v_user_id;
  ELSE
    RAISE NOTICE '⚠️ [APROVACAO] Usuário não encontrado em user_approvals: %', user_email;
  END IF;
  
  IF v_updated THEN
    -- Ativar trial de 15 dias
    RAISE NOTICE '🎁 [APROVACAO] Ativando trial de 15 dias...';
    v_trial_result := activate_trial_for_new_user(user_email);
    
    RAISE NOTICE '📊 [APROVACAO] Resultado do trial: %', v_trial_result;
    
    -- Retornar sucesso com informações do trial
    RETURN json_build_object(
      'success', true,
      'message', 'Usuário aprovado e trial ativado!',
      'user_id', v_user_id,
      'trial_end_date', v_trial_result->>'trial_end_date',
      'days_remaining', (v_trial_result->>'days_remaining')::INTEGER
    );
  ELSE
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado em user_approvals'
    );
  END IF;
  
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ [APROVACAO] Erro: %', SQLERRM;
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$;

-- Dar permissões
GRANT EXECUTE ON FUNCTION approve_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION approve_user_after_email_verification(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION approve_user_after_email_verification(TEXT) TO service_role;

SELECT '✅ PASSO 2: Função approve_user_after_email_verification criada!' as status;

-- ============================================================================
-- PASSO 3: Verificar se as funções foram criadas corretamente
-- ============================================================================

SELECT 
  '✅ Verificando funções criadas...' as status,
  COUNT(*) FILTER (WHERE proname = 'activate_trial_for_new_user') as func_activate_trial,
  COUNT(*) FILTER (WHERE proname = 'approve_user_after_email_verification') as func_approve_user
FROM pg_proc
WHERE proname IN ('activate_trial_for_new_user', 'approve_user_after_email_verification');

-- ============================================================================
-- PASSO 4: Testar as funções (OPCIONAL - descomente para testar)
-- ============================================================================

-- Descomente as linhas abaixo para testar com um email específico:

-- SELECT approve_user_after_email_verification('email@teste.com');
-- SELECT activate_trial_for_new_user('email@teste.com');

-- ============================================================================
-- PASSO 5: Verificar estrutura da tabela subscriptions
-- ============================================================================

SELECT 
  '✅ Verificando colunas da tabela subscriptions...' as status,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'subscriptions'
ORDER BY ordinal_position;

-- ============================================================================
-- RESUMO
-- ============================================================================

SELECT '
✅ EXECUÇÃO CONCLUÍDA!

Funções criadas:
1. activate_trial_for_new_user(TEXT) - Ativa 15 dias de teste
2. approve_user_after_email_verification(TEXT) - Aprova usuário e ativa trial

O que acontece agora:
1. Usuário se cadastra
2. Recebe código por email
3. Digita os 6 dígitos
4. approve_user_after_email_verification é chamada
5. Usuário é aprovado automaticamente
6. Trial de 15 dias é ativado
7. Usuário entra no dashboard com acesso completo

IMPORTANTE:
- Todos os novos cadastros terão 15 dias automáticos
- Não precisa mais aprovar manualmente no painel admin
- Aparece automaticamente no painel admin assim que verificar email

Para testar, use:
SELECT approve_user_after_email_verification(''seu-email@teste.com'');
' as resumo;
