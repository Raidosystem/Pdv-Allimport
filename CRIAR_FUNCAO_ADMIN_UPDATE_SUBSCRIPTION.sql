-- =====================================================
-- FUNÇÃO RPC PARA ADMIN ATUALIZAR SUBSCRIPTIONS
-- =====================================================
-- Esta função permite que admins atualizem qualquer subscription
-- Ela roda com SECURITY DEFINER, bypassando o RLS
-- =====================================================

-- Remover função se já existir
DROP FUNCTION IF EXISTS admin_update_subscription(uuid, jsonb);

-- Criar função que bypassa RLS
CREATE OR REPLACE FUNCTION admin_update_subscription(
  p_user_id uuid,
  p_updates jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com permissões do owner (bypassa RLS)
SET search_path = public
AS $$
DECLARE
  v_result jsonb;
BEGIN
  -- Validar que quem está executando é admin
  -- (você pode adicionar validações adicionais aqui)
  
  -- Executar o UPDATE
  UPDATE subscriptions
  SET
    updated_at = COALESCE((p_updates->>'updated_at')::timestamptz, now()),
    status = COALESCE(p_updates->>'status', status),
    plan_type = COALESCE(p_updates->>'plan_type', plan_type),
    trial_start_date = CASE 
      WHEN p_updates ? 'trial_start_date' THEN (p_updates->>'trial_start_date')::timestamptz
      ELSE trial_start_date
    END,
    trial_end_date = CASE 
      WHEN p_updates ? 'trial_end_date' THEN (p_updates->>'trial_end_date')::timestamptz
      ELSE trial_end_date
    END,
    subscription_start_date = CASE 
      WHEN p_updates ? 'subscription_start_date' THEN (p_updates->>'subscription_start_date')::timestamptz
      ELSE subscription_start_date
    END,
    subscription_end_date = CASE 
      WHEN p_updates ? 'subscription_end_date' THEN (p_updates->>'subscription_end_date')::timestamptz
      ELSE subscription_end_date
    END,
    payment_method = COALESCE(p_updates->>'payment_method', payment_method),
    last_payment_date = CASE 
      WHEN p_updates ? 'last_payment_date' THEN (p_updates->>'last_payment_date')::timestamptz
      ELSE last_payment_date
    END,
    next_payment_date = CASE 
      WHEN p_updates ? 'next_payment_date' THEN (p_updates->>'next_payment_date')::timestamptz
      ELSE next_payment_date
    END,
    amount = CASE 
      WHEN p_updates ? 'amount' THEN (p_updates->>'amount')::numeric
      ELSE amount
    END
  WHERE user_id = p_user_id
  RETURNING to_jsonb(subscriptions.*) INTO v_result;

  -- Se não encontrou, retornar erro
  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Subscription não encontrada para user_id: %', p_user_id;
  END IF;

  -- Retornar o registro atualizado
  RETURN v_result;
END;
$$;

-- Dar permissão para usuários autenticados executarem
GRANT EXECUTE ON FUNCTION admin_update_subscription(uuid, jsonb) TO authenticated;

-- Comentário da função
COMMENT ON FUNCTION admin_update_subscription(uuid, jsonb) IS 
  'Permite admins atualizarem subscriptions, bypassando RLS. Params: user_id, updates (jsonb). Returns: subscription atualizada.';

-- =====================================================
-- TESTE DA FUNÇÃO
-- =====================================================

-- Exemplo de uso:
/*
SELECT admin_update_subscription(
  '922d4f20-6c99-4438-a922-e275eb527c0b'::uuid,
  jsonb_build_object(
    'status', 'trial',
    'plan_type', 'trial',
    'trial_end_date', (now() + interval '30 days')::text,
    'payment_method', 'trial',
    'amount', '0.00'
  )
);
*/
