-- ============================================
-- CRIAR SUBSCRIPTION PARA QUEM TEM EMPRESA MAS NÃO TEM SUBSCRIPTION
-- ============================================

DO $$
DECLARE
  v_user RECORD;
  v_count INT := 0;
BEGIN
  -- Para cada usuário que TEM empresa mas NÃO TEM subscription
  FOR v_user IN 
    SELECT u.id, u.email
    FROM auth.users u
    INNER JOIN empresas e ON e.user_id = u.id  -- TEM empresa
    LEFT JOIN subscriptions s ON s.user_id = u.id
    WHERE s.id IS NULL  -- NÃO TEM subscription
      AND u.email NOT LIKE 'DELETED_%'  -- Ignorar deletados
  LOOP
    v_count := v_count + 1;
    
    RAISE NOTICE '🔧 Criando subscription para: %', v_user.email;
    
    -- Criar subscription de 15 dias
    INSERT INTO subscriptions (
      user_id,
      email,
      plan_type,
      status,
      trial_start_date,
      trial_end_date,
      subscription_start_date,
      subscription_end_date,
      created_at,
      updated_at
    ) VALUES (
      v_user.id,
      v_user.email,
      'free',
      'trial',
      NOW(),
      NOW() + INTERVAL '15 days',
      NOW(),
      NOW() + INTERVAL '15 days',
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    RAISE NOTICE '✅ Subscription criada para: %', v_user.email;
  END LOOP;
  
  RAISE NOTICE '✅ Total de subscriptions criadas: %', v_count;
END $$;

-- VERIFICAR RESULTADO
SELECT 
  u.email,
  e.nome as empresa,
  s.status as subscription_status,
  EXTRACT(DAY FROM (COALESCE(s.trial_end_date, s.subscription_end_date) - NOW())) as dias_restantes,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    WHEN s.id IS NULL THEN '❌ SEM SUBSCRIPTION'
    ELSE '✅ OK'
  END as status
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email NOT LIKE 'DELETED_%'
ORDER BY u.created_at DESC
LIMIT 10;
