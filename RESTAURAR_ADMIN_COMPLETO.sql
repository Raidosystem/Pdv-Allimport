-- ========================================
-- 🔧 RESTAURAR PAINEL ADMINISTRATIVO 100%
-- ========================================
-- Este script restaura:
-- ✅ Acesso total do admin
-- ✅ Visualização de todos os assinantes
-- ✅ Controle de testes e assinaturas premium
-- ✅ Poder adicionar/remover dias
-- ========================================

-- 1️⃣ GARANTIR QUE A TABELA SUBSCRIPTIONS EXISTE
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled')),
  plan_type TEXT DEFAULT 'free' CHECK (plan_type IN ('free', 'trial', 'basic', 'premium', 'enterprise')),
  trial_start_date TIMESTAMPTZ,
  trial_end_date TIMESTAMPTZ,
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  payment_method TEXT,
  payment_status TEXT DEFAULT 'pending',
  last_payment_date TIMESTAMPTZ,
  next_payment_date TIMESTAMPTZ,
  amount DECIMAL(10, 2),
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_email ON subscriptions(email);

-- 2️⃣ HABILITAR RLS MAS PERMITIR ADMIN VER TUDO
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas
DROP POLICY IF EXISTS "Usuários podem ver suas próprias assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Admin pode ver todas as assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Usuários podem inserir suas próprias assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Admin pode inserir assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Admin pode atualizar assinaturas" ON subscriptions;
DROP POLICY IF EXISTS "Admin pode deletar assinaturas" ON subscriptions;

-- Políticas para SELECT (visualização)
CREATE POLICY "Admin pode ver todas as assinaturas"
ON subscriptions FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

-- Políticas para INSERT
CREATE POLICY "Admin pode inserir assinaturas"
ON subscriptions FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

-- Políticas para UPDATE
CREATE POLICY "Admin pode atualizar assinaturas"
ON subscriptions FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
)
WITH CHECK (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

-- Políticas para DELETE
CREATE POLICY "Admin pode deletar assinaturas"
ON subscriptions FOR DELETE
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
);

-- 3️⃣ CRIAR/ATUALIZAR FUNÇÃO PARA ADICIONAR DIAS (ADMIN)
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
BEGIN
  -- Verificar se assinatura existe
  SELECT id, subscription_end_date, trial_end_date, status
  INTO v_subscription_id, v_current_end_date, v_current_end_date, v_status
  FROM subscriptions
  WHERE user_id = p_user_id;

  IF v_subscription_id IS NULL THEN
    -- Criar nova assinatura
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
  ELSE
    -- Adicionar dias à assinatura existente
    IF v_current_end_date IS NULL OR v_current_end_date < NOW() THEN
      -- Se expirou ou não tem data, começa de agora
      v_new_end_date := NOW() + (p_days || ' days')::INTERVAL;
    ELSE
      -- Adiciona dias à data atual
      v_new_end_date := v_current_end_date + (p_days || ' days')::INTERVAL;
    END IF;

    UPDATE subscriptions
    SET 
      subscription_end_date = v_new_end_date,
      status = CASE WHEN p_plan_type = 'trial' THEN 'trial' ELSE 'active' END,
      plan_type = p_plan_type,
      updated_at = NOW()
    WHERE user_id = p_user_id;

    RETURN json_build_object(
      'success', true,
      'message', p_days || ' dias adicionados com sucesso',
      'subscription_id', v_subscription_id,
      'end_date', v_new_end_date,
      'days_added', p_days
    );
  END IF;
END;
$$;

-- 4️⃣ FUNÇÃO PARA ATIVAR TESTE DE 15 DIAS
CREATE OR REPLACE FUNCTION activate_trial(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_existing_subscription RECORD;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'message', 'Usuário não encontrado');
  END IF;

  -- Verificar se já tem assinatura
  SELECT * INTO v_existing_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  IF v_existing_subscription.id IS NOT NULL THEN
    RETURN json_build_object(
      'success', true,
      'message', 'Usuário já possui assinatura',
      'existing_status', v_existing_subscription.status
    );
  END IF;

  -- Criar nova assinatura de teste (15 dias)
  INSERT INTO subscriptions (
    user_id,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    email,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    'trial',
    'trial',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW() + INTERVAL '15 days',
    user_email,
    NOW(),
    NOW()
  );

  RETURN json_build_object(
    'success', true,
    'message', 'Período de teste de 15 dias ativado',
    'trial_end_date', NOW() + INTERVAL '15 days'
  );
END;
$$;

-- 5️⃣ CRIAR ASSINATURA PARA USUÁRIOS SEM SUBSCRIPTION
DO $$
DECLARE
  v_user RECORD;
  v_subscription_count INT;
BEGIN
  -- Para cada usuário em auth.users
  FOR v_user IN 
    SELECT au.id, au.email
    FROM auth.users au
    LEFT JOIN subscriptions s ON s.user_id = au.id
    WHERE s.id IS NULL
  LOOP
    -- Criar assinatura pendente
    INSERT INTO subscriptions (
      user_id,
      status,
      plan_type,
      email,
      created_at,
      updated_at
    ) VALUES (
      v_user.id,
      'pending',
      'free',
      v_user.email,
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    RAISE NOTICE 'Assinatura criada para: %', v_user.email;
  END LOOP;

  SELECT COUNT(*) INTO v_subscription_count FROM subscriptions;
  RAISE NOTICE '✅ Total de assinaturas: %', v_subscription_count;
END $$;

-- 6️⃣ GARANTIR QUE USER_APPROVALS EXISTE
CREATE TABLE IF NOT EXISTS user_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  company_name TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON user_approvals(email);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON user_approvals(status);

-- RLS para user_approvals
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin pode ver todas as aprovações" ON user_approvals;
DROP POLICY IF EXISTS "Admin pode inserir aprovações" ON user_approvals;
DROP POLICY IF EXISTS "Admin pode atualizar aprovações" ON user_approvals;

CREATE POLICY "Admin pode ver todas as aprovações"
ON user_approvals FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

CREATE POLICY "Admin pode inserir aprovações"
ON user_approvals FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

CREATE POLICY "Admin pode atualizar aprovações"
ON user_approvals FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'cristiano@gruporaval.com.br'
  )
  OR user_id = auth.uid()
);

-- 7️⃣ SINCRONIZAR USER_APPROVALS COM AUTH.USERS
DO $$
DECLARE
  v_user RECORD;
BEGIN
  FOR v_user IN 
    SELECT au.id, au.email, au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN user_approvals ua ON ua.user_id = au.id
    WHERE ua.id IS NULL
  LOOP
    INSERT INTO user_approvals (
      user_id,
      email,
      full_name,
      company_name,
      status,
      created_at,
      updated_at
    ) VALUES (
      v_user.id,
      v_user.email,
      COALESCE(v_user.raw_user_meta_data->>'full_name', v_user.raw_user_meta_data->>'name', 'Sem nome'),
      v_user.raw_user_meta_data->>'company_name',
      'approved', -- Já existe no auth.users, consideramos aprovado
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO UPDATE
    SET 
      email = EXCLUDED.email,
      updated_at = NOW();
    
    RAISE NOTICE 'User approval criado para: %', v_user.email;
  END LOOP;
END $$;

-- 8️⃣ VERIFICAÇÃO FINAL
SELECT 
  '✅ RESTAURAÇÃO DO ADMIN CONCLUÍDA!' as titulo,
  '' as espaco;

SELECT 
  '📊 ESTATÍSTICAS' as info,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios,
  (SELECT COUNT(*) FROM subscriptions) as total_subscriptions,
  (SELECT COUNT(*) FROM user_approvals) as total_approvals;

SELECT 
  '📋 ASSINATURAS POR STATUS' as info,
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status
ORDER BY 
  CASE status
    WHEN 'active' THEN 1
    WHEN 'trial' THEN 2
    WHEN 'pending' THEN 3
    WHEN 'expired' THEN 4
    ELSE 5
  END;

SELECT 
  '👥 AMOSTRA DE ASSINANTES' as info,
  s.email,
  s.status,
  s.plan_type,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date IS NOT NULL THEN
      GREATEST(0, EXTRACT(DAY FROM (s.trial_end_date - NOW())))
    WHEN s.status = 'active' AND s.subscription_end_date IS NOT NULL THEN
      GREATEST(0, EXTRACT(DAY FROM (s.subscription_end_date - NOW())))
    ELSE 0
  END as dias_restantes
FROM subscriptions s
ORDER BY s.created_at DESC
LIMIT 10;

SELECT 
  '🎯 PRÓXIMOS PASSOS' as info,
  '1. Acesse o Admin Dashboard no sistema' as passo1,
  '2. Todos os assinantes devem estar visíveis' as passo2,
  '3. Use admin_add_subscription_days() para gerenciar dias' as passo3,
  '4. Teste filtros: Todos, Em Teste, Premium, Expirados' as passo4;

-- 9️⃣ EXEMPLOS DE USO
SELECT 
  '📝 EXEMPLOS DE COMANDOS' as titulo,
  '' as espaco;

SELECT 
  'Para adicionar 30 dias premium:' as exemplo,
  'SELECT admin_add_subscription_days(''user-uuid-aqui'', 30, ''premium'');' as comando;

SELECT 
  'Para adicionar 15 dias de teste:' as exemplo,
  'SELECT admin_add_subscription_days(''user-uuid-aqui'', 15, ''trial'');' as comando;

SELECT 
  'Para ver todas as assinaturas:' as exemplo,
  'SELECT * FROM subscriptions ORDER BY created_at DESC;' as comando;
