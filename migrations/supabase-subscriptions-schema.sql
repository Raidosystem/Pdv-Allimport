-- ============================================
-- SISTEMA DE ASSINATURAS COMPLETO
-- Controle automático de testes e planos premium
-- ============================================

-- 1. Criar tabela de assinaturas
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_approvals(user_id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL DEFAULT 'trial', -- 'trial' ou 'premium'
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ NOT NULL,
  days_added INTEGER DEFAULT 30, -- Total de dias adicionados
  is_active BOOLEAN DEFAULT true,
  is_paused BOOLEAN DEFAULT false,
  paused_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_active ON subscriptions(is_active);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON subscriptions(end_date);

-- 2. Função para calcular dias restantes em tempo real
CREATE OR REPLACE FUNCTION calculate_days_remaining(end_date_param TIMESTAMPTZ)
RETURNS INTEGER AS $$
BEGIN
  RETURN GREATEST(0, EXTRACT(DAY FROM (end_date_param - NOW()))::INTEGER);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 3. View para dados em tempo real com cálculo automático
CREATE OR REPLACE VIEW subscriptions_realtime AS
SELECT 
  s.*,
  calculate_days_remaining(s.end_date) as days_remaining,
  CASE 
    WHEN s.end_date < NOW() THEN false
    ELSE s.is_active
  END as is_currently_active,
  CASE
    WHEN s.plan_type = 'trial' THEN '🎁 TESTE'
    WHEN s.plan_type = 'premium' THEN '⭐ PREMIUM'
    ELSE '📦 BÁSICO'
  END as plan_display_name
FROM subscriptions s;

-- 4. Trigger para criar assinatura de teste automaticamente ao aprovar usuário
CREATE OR REPLACE FUNCTION create_trial_subscription()
RETURNS TRIGGER AS $$
BEGIN
  -- Quando um usuário é aprovado, criar assinatura de teste de 30 dias
  IF NEW.approval_status = 'approved' AND OLD.approval_status != 'approved' THEN
    -- Verificar se já não existe uma assinatura
    IF NOT EXISTS (SELECT 1 FROM subscriptions WHERE user_id = NEW.user_id) THEN
      INSERT INTO subscriptions (
        user_id,
        plan_type,
        start_date,
        end_date,
        days_added,
        is_active
      ) VALUES (
        NEW.user_id,
        'trial',
        NOW(),
        NOW() + INTERVAL '30 days',
        30,
        true
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para ativar teste automaticamente
DROP TRIGGER IF EXISTS trigger_create_trial_subscription ON user_approvals;
CREATE TRIGGER trigger_create_trial_subscription
  AFTER UPDATE ON user_approvals
  FOR EACH ROW
  EXECUTE FUNCTION create_trial_subscription();

-- 5. Função para adicionar dias à assinatura
CREATE OR REPLACE FUNCTION add_subscription_days(
  p_user_id UUID,
  p_days INTEGER
)
RETURNS JSON AS $$
DECLARE
  v_subscription subscriptions%ROWTYPE;
  v_new_end_date TIMESTAMPTZ;
BEGIN
  -- Buscar assinatura atual
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = p_user_id
  ORDER BY created_at DESC
  LIMIT 1;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assinatura não encontrada para este usuário';
  END IF;
  
  -- Calcular nova data de expiração
  v_new_end_date := v_subscription.end_date + (p_days || ' days')::INTERVAL;
  
  -- Atualizar assinatura
  UPDATE subscriptions
  SET 
    end_date = v_new_end_date,
    days_added = days_added + p_days,
    updated_at = NOW(),
    is_active = true -- Reativar se estava expirada
  WHERE id = v_subscription.id;
  
  -- Retornar resultado
  RETURN json_build_object(
    'success', true,
    'new_end_date', v_new_end_date,
    'total_days', v_subscription.days_added + p_days,
    'days_remaining', calculate_days_remaining(v_new_end_date)
  );
END;
$$ LANGUAGE plpgsql;

-- 6. Função para pausar/reativar assinatura
CREATE OR REPLACE FUNCTION toggle_subscription_pause(
  p_user_id UUID,
  p_pause BOOLEAN
)
RETURNS JSON AS $$
DECLARE
  v_subscription_id UUID;
BEGIN
  -- Atualizar status de pausa
  UPDATE subscriptions
  SET 
    is_paused = p_pause,
    paused_at = CASE WHEN p_pause THEN NOW() ELSE NULL END,
    updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING id INTO v_subscription_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assinatura não encontrada';
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'is_paused', p_pause,
    'subscription_id', v_subscription_id
  );
END;
$$ LANGUAGE plpgsql;

-- 7. Função para atualizar plano (trial -> premium)
CREATE OR REPLACE FUNCTION upgrade_to_premium(
  p_user_id UUID,
  p_days INTEGER DEFAULT 365
)
RETURNS JSON AS $$
DECLARE
  v_new_end_date TIMESTAMPTZ;
BEGIN
  -- Calcular data de expiração premium (1 ano por padrão)
  v_new_end_date := NOW() + (p_days || ' days')::INTERVAL;
  
  -- Atualizar para premium
  UPDATE subscriptions
  SET 
    plan_type = 'premium',
    end_date = v_new_end_date,
    days_added = p_days,
    is_active = true,
    is_paused = false,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  RETURN json_build_object(
    'success', true,
    'plan_type', 'premium',
    'end_date', v_new_end_date,
    'days', p_days
  );
END;
$$ LANGUAGE plpgsql;

-- 8. Políticas RLS (Row Level Security)
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Admins podem ver tudo
CREATE POLICY "Admins podem ver todas assinaturas"
  ON subscriptions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_approvals
      WHERE user_approvals.user_id = auth.uid()
      AND user_approvals.user_role = 'admin'
    )
  );

-- Admins podem modificar
CREATE POLICY "Admins podem modificar assinaturas"
  ON subscriptions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_approvals
      WHERE user_approvals.user_id = auth.uid()
      AND user_approvals.user_role = 'admin'
    )
  );

-- Usuários podem ver apenas suas próprias assinaturas
CREATE POLICY "Usuários veem suas assinaturas"
  ON subscriptions FOR SELECT
  USING (user_id = auth.uid());

-- 9. Função para limpar assinaturas expiradas (manutenção)
CREATE OR REPLACE FUNCTION cleanup_expired_subscriptions()
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE subscriptions
  SET is_active = false
  WHERE end_date < NOW() AND is_active = true;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- 10. Criar assinaturas para usuários aprovados existentes (migração)
INSERT INTO subscriptions (user_id, plan_type, start_date, end_date, days_added, is_active)
SELECT 
  user_id,
  'trial',
  created_at,
  created_at + INTERVAL '30 days',
  30,
  true
FROM user_approvals
WHERE approval_status = 'approved'
  AND user_role != 'employee'
  AND user_id NOT IN (SELECT user_id FROM subscriptions)
ON CONFLICT DO NOTHING;

-- ============================================
-- INSTRUÇÕES DE USO
-- ============================================

-- Para adicionar dias a uma assinatura:
-- SELECT add_subscription_days('user-uuid-aqui', 30);

-- Para pausar/reativar:
-- SELECT toggle_subscription_pause('user-uuid-aqui', true); -- pausar
-- SELECT toggle_subscription_pause('user-uuid-aqui', false); -- reativar

-- Para fazer upgrade para premium:
-- SELECT upgrade_to_premium('user-uuid-aqui', 365);

-- Para ver todas assinaturas em tempo real:
-- SELECT * FROM subscriptions_realtime;

-- Para limpar assinaturas expiradas:
-- SELECT cleanup_expired_subscriptions();
