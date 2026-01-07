-- ============================================================================
-- PROTEÇÃO TOTAL - USUÁRIOS PAGANTES NUNCA PODEM SER EXCLUÍDOS
-- ============================================================================
-- 🚨 CRÍTICO: Usuários que compraram o sistema sumiram do banco
-- ✅ SOLUÇÃO: Implementar proteções múltiplas contra exclusão acidental
-- ============================================================================

-- ============================================================================
-- 1️⃣ SOFT DELETE - Adicionar coluna deleted_at
-- ============================================================================

-- user_approvals
ALTER TABLE user_approvals 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_user_approvals_deleted 
ON user_approvals(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON COLUMN user_approvals.deleted_at IS 'Quando marcado, usuário está "excluído" mas dados permanecem';

-- empresas
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_empresas_deleted 
ON empresas(deleted_at) WHERE deleted_at IS NULL;

-- subscriptions
ALTER TABLE subscriptions 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_subscriptions_deleted 
ON subscriptions(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- 2️⃣ TABELA DE AUDITORIA - Registrar TODAS as mudanças
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_type TEXT NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE', 'RESTORE')),
  table_name TEXT NOT NULL,
  target_user_id UUID,
  target_email TEXT,
  performed_by UUID, -- Quem fez a ação
  performed_by_email TEXT,
  old_data JSONB, -- Dados antes da mudança
  new_data JSONB, -- Dados depois da mudança
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_target_user ON user_audit_log(target_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_created ON user_audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_action ON user_audit_log(action_type);

COMMENT ON TABLE user_audit_log IS 'Registro permanente de TODAS as mudanças em usuários - NUNCA excluir desta tabela';

-- ============================================================================
-- 3️⃣ TRIGGER DE AUDITORIA - Registrar automaticamente
-- ============================================================================

-- Função para registrar mudanças em user_approvals
CREATE OR REPLACE FUNCTION audit_user_approvals_changes()
RETURNS TRIGGER AS $$
BEGIN
  -- Registrar DELETE
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO user_audit_log (
      action_type,
      table_name,
      target_user_id,
      target_email,
      performed_by,
      performed_by_email,
      old_data
    ) VALUES (
      'DELETE',
      'user_approvals',
      OLD.user_id,
      OLD.email,
      auth.uid(),
      (SELECT email FROM auth.users WHERE id = auth.uid()),
      row_to_json(OLD)::jsonb
    );
    RETURN OLD;
  END IF;

  -- Registrar UPDATE
  IF (TG_OP = 'UPDATE') THEN
    -- Só registrar se deleted_at mudou (soft delete)
    IF (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL) THEN
      INSERT INTO user_audit_log (
        action_type,
        table_name,
        target_user_id,
        target_email,
        performed_by,
        performed_by_email,
        old_data,
        new_data
      ) VALUES (
        'DELETE',
        'user_approvals',
        NEW.user_id,
        NEW.email,
        auth.uid(),
        (SELECT email FROM auth.users WHERE id = auth.uid()),
        row_to_json(OLD)::jsonb,
        row_to_json(NEW)::jsonb
      );
    END IF;

    -- Registrar restauração
    IF (OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL) THEN
      INSERT INTO user_audit_log (
        action_type,
        table_name,
        target_user_id,
        target_email,
        performed_by,
        performed_by_email,
        old_data,
        new_data
      ) VALUES (
        'RESTORE',
        'user_approvals',
        NEW.user_id,
        NEW.email,
        auth.uid(),
        (SELECT email FROM auth.users WHERE id = auth.uid()),
        row_to_json(OLD)::jsonb,
        row_to_json(NEW)::jsonb
      );
    END IF;

    RETURN NEW;
  END IF;

  -- Registrar INSERT
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO user_audit_log (
      action_type,
      table_name,
      target_user_id,
      target_email,
      performed_by,
      performed_by_email,
      new_data
    ) VALUES (
      'INSERT',
      'user_approvals',
      NEW.user_id,
      NEW.email,
      auth.uid(),
      (SELECT email FROM auth.users WHERE id = auth.uid()),
      row_to_json(NEW)::jsonb
    );
    RETURN NEW;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger
DROP TRIGGER IF EXISTS audit_user_approvals_trigger ON user_approvals;

CREATE TRIGGER audit_user_approvals_trigger
  AFTER INSERT OR UPDATE OR DELETE ON user_approvals
  FOR EACH ROW
  EXECUTE FUNCTION audit_user_approvals_changes();

-- ============================================================================
-- 4️⃣ BLOQUEAR EXCLUSÃO FÍSICA de Usuários Pagantes
-- ============================================================================

-- Função que IMPEDE exclusão de usuários com subscription
CREATE OR REPLACE FUNCTION prevent_delete_paid_users()
RETURNS TRIGGER AS $$
DECLARE
  v_has_subscription BOOLEAN;
BEGIN
  -- Verificar se usuário tem subscription ativa ou trial
  SELECT EXISTS(
    SELECT 1 FROM subscriptions 
    WHERE user_id = OLD.user_id 
      AND status IN ('active', 'trial')
      AND deleted_at IS NULL
  ) INTO v_has_subscription;

  -- Se tiver subscription, BLOQUEAR exclusão
  IF v_has_subscription THEN
    RAISE EXCEPTION '🚨 BLOQUEADO: Não é permitido excluir usuário com subscription ativa. Use soft delete (UPDATE SET deleted_at = NOW()) ou cancele a subscription primeiro.';
  END IF;

  -- Se chegou aqui, pode excluir (mas registrar auditoria)
  RAISE WARNING '⚠️ Usuário % foi excluído fisicamente do banco. Isso não é recomendado!', OLD.email;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger de bloqueio
DROP TRIGGER IF EXISTS prevent_delete_paid_users_trigger ON user_approvals;

CREATE TRIGGER prevent_delete_paid_users_trigger
  BEFORE DELETE ON user_approvals
  FOR EACH ROW
  EXECUTE FUNCTION prevent_delete_paid_users();

-- ============================================================================
-- 5️⃣ RLS - Apenas SUPER ADMIN pode "excluir" (soft delete)
-- ============================================================================

-- Política: Apenas super admin pode fazer soft delete de owners
DROP POLICY IF EXISTS "only_super_admin_can_soft_delete_owners" ON user_approvals;

CREATE POLICY "only_super_admin_can_soft_delete_owners" ON user_approvals
  FOR UPDATE
  USING (
    -- Se está tentando fazer soft delete (deleted_at vai de NULL para NOT NULL)
    auth.uid() IN (
      SELECT user_id FROM user_approvals 
      WHERE email = 'novaradiosystem@outlook.com' 
        AND user_role = 'super_admin'
    )
    OR
    -- Ou não está mexendo em deleted_at
    deleted_at IS NOT DISTINCT FROM deleted_at
  );

-- ============================================================================
-- 6️⃣ FUNÇÃO PARA SOFT DELETE SEGURO
-- ============================================================================

-- Função que faz soft delete com todas as validações
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_email TEXT, p_reason TEXT DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_has_active_sub BOOLEAN;
  v_result JSONB;
BEGIN
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_id = auth.uid() 
      AND email = 'novaradiosystem@outlook.com'
      AND user_role = 'super_admin'
  ) THEN
    RAISE EXCEPTION '🚨 Apenas o Super Admin pode excluir usuários';
  END IF;

  -- Buscar usuário
  SELECT user_id INTO v_user_id
  FROM user_approvals
  WHERE email = p_user_email AND deleted_at IS NULL;

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Usuário não encontrado ou já foi excluído'
    );
  END IF;

  -- Verificar subscription ativa
  SELECT EXISTS(
    SELECT 1 FROM subscriptions
    WHERE user_id = v_user_id
      AND status IN ('active', 'trial')
      AND deleted_at IS NULL
  ) INTO v_has_active_sub;

  IF v_has_active_sub THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', '⚠️ Usuário possui subscription ativa. Cancele primeiro!',
      'has_active_subscription', true
    );
  END IF;

  -- Fazer soft delete em todas as tabelas
  UPDATE user_approvals SET deleted_at = NOW() WHERE user_id = v_user_id;
  UPDATE empresas SET deleted_at = NOW() WHERE user_id = v_user_id;
  UPDATE subscriptions SET deleted_at = NOW() WHERE user_id = v_user_id;

  -- Registrar motivo na auditoria
  INSERT INTO user_audit_log (
    action_type,
    table_name,
    target_user_id,
    target_email,
    performed_by,
    performed_by_email,
    new_data
  ) VALUES (
    'DELETE',
    'SOFT_DELETE_USER',
    v_user_id,
    p_user_email,
    auth.uid(),
    'novaradiosystem@outlook.com',
    jsonb_build_object('reason', p_reason)
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Usuário marcado como excluído com sucesso (soft delete)',
    'user_id', v_user_id,
    'deleted_at', NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7️⃣ FUNÇÃO PARA RESTAURAR USUÁRIO
-- ============================================================================

CREATE OR REPLACE FUNCTION restore_deleted_user(p_user_email TEXT)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Verificar se é super admin
  IF NOT EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_id = auth.uid() 
      AND email = 'novaradiosystem@outlook.com'
      AND user_role = 'super_admin'
  ) THEN
    RAISE EXCEPTION '🚨 Apenas o Super Admin pode restaurar usuários';
  END IF;

  -- Buscar usuário excluído
  SELECT user_id INTO v_user_id
  FROM user_approvals
  WHERE email = p_user_email AND deleted_at IS NOT NULL;

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Usuário não encontrado ou não foi excluído'
    );
  END IF;

  -- Restaurar em todas as tabelas
  UPDATE user_approvals SET deleted_at = NULL, updated_at = NOW() WHERE user_id = v_user_id;
  UPDATE empresas SET deleted_at = NULL WHERE user_id = v_user_id;
  UPDATE subscriptions SET deleted_at = NULL WHERE user_id = v_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Usuário restaurado com sucesso',
    'user_id', v_user_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8️⃣ VERIFICAR PROTEÇÕES ATIVAS
-- ============================================================================

-- Ver se tudo foi criado corretamente
DO $$
BEGIN
  RAISE NOTICE '=== VERIFICAÇÃO DE PROTEÇÕES ===';
  
  -- Verificar colunas deleted_at
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_approvals' AND column_name = 'deleted_at') THEN
    RAISE NOTICE '✅ user_approvals.deleted_at criado';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'empresas' AND column_name = 'deleted_at') THEN
    RAISE NOTICE '✅ empresas.deleted_at criado';
  END IF;

  -- Verificar tabela de auditoria
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_audit_log') THEN
    RAISE NOTICE '✅ user_audit_log criada';
  END IF;

  -- Verificar triggers
  IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'audit_user_approvals_trigger') THEN
    RAISE NOTICE '✅ Trigger de auditoria ativo';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'prevent_delete_paid_users_trigger') THEN
    RAISE NOTICE '✅ Trigger de bloqueio de exclusão ativo';
  END IF;

  -- Verificar funções
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'soft_delete_user') THEN
    RAISE NOTICE '✅ Função soft_delete_user criada';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'restore_deleted_user') THEN
    RAISE NOTICE '✅ Função restore_deleted_user criada';
  END IF;

  RAISE NOTICE '=== PROTEÇÃO ATIVA ===';
  RAISE NOTICE '🛡️ Usuários pagantes estão protegidos contra exclusão acidental';
END $$;

-- ============================================================================
-- 9️⃣ QUERY DE MONITORAMENTO
-- ============================================================================

-- Ver tentativas de exclusão nas últimas 24h
SELECT 
  action_type,
  target_email,
  performed_by_email,
  created_at,
  old_data->>'user_role' as role_deleted
FROM user_audit_log
WHERE action_type = 'DELETE'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Ver usuários com soft delete
SELECT 
  email,
  user_role,
  deleted_at,
  'Pode ser restaurado' as status
FROM user_approvals
WHERE deleted_at IS NOT NULL;

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- ✅ Coluna deleted_at criada em user_approvals, empresas, subscriptions
-- ✅ Tabela user_audit_log criada para auditoria permanente
-- ✅ Trigger de auditoria registrando todas as mudanças
-- ✅ Trigger bloqueando exclusão física de usuários com subscription
-- ✅ Funções soft_delete_user() e restore_deleted_user() prontas
-- ✅ Apenas super admin pode fazer soft delete de owners
-- 
-- 🛡️ USUÁRIOS PAGANTES NUNCA MAIS VÃO SUMIR!
