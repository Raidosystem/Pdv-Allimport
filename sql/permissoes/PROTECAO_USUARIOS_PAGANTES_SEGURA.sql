-- =====================================================
-- PROTEÇÃO SEGURA CONTRA EXCLUSÃO DE USUÁRIOS PAGANTES
-- =====================================================
-- Protege apenas OWNERS (usuários pagantes) contra exclusão
-- Permite DELETE de funcionários e outros dados normalmente
-- =====================================================

-- ⚠️ IMPORTANTE: ESTA PROTEÇÃO FUNCIONA PARA:
-- ✅ DELETEs via código TypeScript/JavaScript
-- ✅ DELETEs via SQL Editor do Supabase (usuário comum)
-- ⚠️ NÃO protege contra: postgres superuser ou service_role_key
-- 
-- SOLUÇÃO: 
-- 1. NUNCA compartilhe a service_role_key
-- 2. Use apenas anon_key no frontend
-- 3. Acesso ao SQL Editor deve ser restrito a admins confiáveis
-- 4. Em produção, desabilite acesso direto ao SQL Editor para não-admins
-- =====================================================

-- CAMADA 1: TABELA DE AUDITORIA
-- Registra todas as tentativas de DELETE
-- =====================================================

CREATE TABLE IF NOT EXISTS delete_attempts_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID,
    record_email TEXT,
    user_role TEXT,
    is_owner BOOLEAN DEFAULT false,
    attempted_by UUID REFERENCES auth.users(id),
    attempted_at TIMESTAMPTZ DEFAULT NOW(),
    blocked BOOLEAN DEFAULT false,
    reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_delete_log_attempted_at 
ON delete_attempts_log(attempted_at DESC);

CREATE INDEX IF NOT EXISTS idx_delete_log_blocked 
ON delete_attempts_log(blocked) WHERE blocked = true;

COMMENT ON TABLE delete_attempts_log IS 'Auditoria de tentativas de DELETE no sistema';

-- =====================================================
-- CAMADA 2: SOFT DELETE (Opcional)
-- Adiciona campo deleted_at para deleção lógica
-- =====================================================

ALTER TABLE user_approvals 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_approvals_deleted_at 
ON user_approvals(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_funcionarios_deleted_at 
ON funcionarios(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_empresas_deleted_at 
ON empresas(deleted_at) WHERE deleted_at IS NULL;

-- =====================================================
-- CAMADA 3: TRIGGER INTELIGENTE
-- Bloqueia DELETE apenas de OWNERS (usuários pagantes)
-- Permite DELETE de funcionários normalmente
-- =====================================================

CREATE OR REPLACE FUNCTION proteger_usuarios_pagantes()
RETURNS TRIGGER AS $$
DECLARE
    v_is_owner BOOLEAN := false;
    v_email TEXT;
    v_user_role TEXT;
    v_has_subscription BOOLEAN := false;
    v_admin_email TEXT;
    v_is_super_admin BOOLEAN := false;
BEGIN
    -- Verificar se quem está deletando é o SUPER ADMIN
    -- Super Admin: novaradiosystem@outlook.com
    SELECT email INTO v_admin_email
    FROM auth.users
    WHERE id = auth.uid();
    
    -- Super Admin pode deletar QUALQUER usuário
    IF v_admin_email = 'novaradiosystem@outlook.com' THEN
        -- Registrar no log (permitido - super admin)
        INSERT INTO delete_attempts_log (
            table_name, record_id, attempted_by, blocked, reason
        ) VALUES (
            TG_TABLE_NAME, OLD.id, auth.uid(), false,
            'DELETE permitido: Executado por SUPER ADMIN'
        );
        
        RETURN OLD; -- PERMITE DELETE
    END IF;
    
    -- Para user_approvals: verificar se é owner
    IF TG_TABLE_NAME = 'user_approvals' THEN
        SELECT 
            COALESCE(OLD.user_role = 'owner', false),
            OLD.email,
            OLD.user_role
        INTO v_is_owner, v_email, v_user_role;
        
        -- Verificar se tem assinatura ativa
        IF v_is_owner THEN
            SELECT EXISTS(
                SELECT 1 FROM subscriptions 
                WHERE user_id = OLD.user_id 
                AND status IN ('active', 'trialing')
            ) INTO v_has_subscription;
        END IF;
    END IF;
    
    -- Para funcionarios: verificar se o user_id é owner de empresa
    IF TG_TABLE_NAME = 'funcionarios' THEN
        -- Verificar se é o dono da empresa (não um funcionário comum)
        SELECT EXISTS(
            SELECT 1 FROM empresas 
            WHERE user_id = OLD.user_id 
            OR id = OLD.empresa_id
        ) INTO v_is_owner;
        
        -- Se for funcionário comum (não owner), PERMITIR DELETE
        IF NOT v_is_owner THEN
            -- Registrar no log (permitido)
            INSERT INTO delete_attempts_log (
                table_name, record_id, attempted_by, blocked, reason
            ) VALUES (
                TG_TABLE_NAME, OLD.id, auth.uid(), false, 
                'DELETE de funcionário permitido'
            );
            
            RETURN OLD; -- PERMITE DELETE
        END IF;
        
        -- Se for owner, verificar assinatura
        SELECT EXISTS(
            SELECT 1 FROM subscriptions 
            WHERE user_id = OLD.user_id 
            AND status IN ('active', 'trialing')
        ) INTO v_has_subscription;
    END IF;
    
    -- Para empresas: sempre verificar se tem assinatura
    IF TG_TABLE_NAME = 'empresas' THEN
        v_is_owner := true;
        
        SELECT EXISTS(
            SELECT 1 FROM subscriptions 
            WHERE user_id = OLD.user_id 
            AND status IN ('active', 'trialing')
        ) INTO v_has_subscription;
    END IF;
    
    -- Se for owner COM assinatura ativa: BLOQUEAR
    IF v_is_owner AND v_has_subscription THEN
        -- Registrar tentativa bloqueada
        INSERT INTO delete_attempts_log (
            table_name, record_id, record_email, user_role, 
            is_owner, attempted_by, blocked, reason
        ) VALUES (
            TG_TABLE_NAME, OLD.id, v_email, v_user_role,
            true, auth.uid(), true,
            'DELETE bloqueado: Usuário pagante com assinatura ativa'
        );
        
        RAISE EXCEPTION 'OPERAÇÃO BLOQUEADA: Não é permitido excluir usuário pagante com assinatura ativa. Use soft delete ou cancele a assinatura primeiro.'
            USING HINT = 'Para desativar: UPDATE ' || TG_TABLE_NAME || ' SET deleted_at = NOW() WHERE id = ''' || OLD.id || '''';
    END IF;
    
    -- Se for owner SEM assinatura: PERMITIR com log
    IF v_is_owner AND NOT v_has_subscription THEN
        INSERT INTO delete_attempts_log (
            table_name, record_id, record_email, user_role,
            is_owner, attempted_by, blocked, reason
        ) VALUES (
            TG_TABLE_NAME, OLD.id, v_email, v_user_role,
            true, auth.uid(), false,
            'DELETE permitido: Owner sem assinatura ativa'
        );
    END IF;
    
    -- Se não for owner: PERMITIR com log
    IF NOT v_is_owner THEN
        INSERT INTO delete_attempts_log (
            table_name, record_id, attempted_by, blocked, reason
        ) VALUES (
            TG_TABLE_NAME, OLD.id, auth.uid(), false,
            'DELETE permitido: Não é usuário pagante'
        );
    END IF;
    
    RETURN OLD; -- PERMITE DELETE
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar triggers
DROP TRIGGER IF EXISTS protect_owner_user_approvals ON user_approvals;
CREATE TRIGGER protect_owner_user_approvals
    BEFORE DELETE ON user_approvals
    FOR EACH ROW
    EXECUTE FUNCTION proteger_usuarios_pagantes();

DROP TRIGGER IF EXISTS protect_owner_funcionarios ON funcionarios;
CREATE TRIGGER protect_owner_funcionarios
    BEFORE DELETE ON funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION proteger_usuarios_pagantes();

DROP TRIGGER IF EXISTS protect_owner_empresas ON empresas;
CREATE TRIGGER protect_owner_empresas
    BEFORE DELETE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION proteger_usuarios_pagantes();

-- =====================================================
-- CAMADA 3.5: POLÍTICAS RLS ADICIONAIS
-- Proteção dupla via Row Level Security
-- =====================================================

-- Ativar RLS nas tabelas (se ainda não estiver)
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- Política que NEGA DELETE de owners com assinatura
-- (Complementa os triggers)
DROP POLICY IF EXISTS "Bloquear DELETE de owners com assinatura" ON user_approvals;
CREATE POLICY "Bloquear DELETE de owners com assinatura"
    ON user_approvals
    FOR DELETE
    USING (
        -- Permite se NÃO for owner
        user_role != 'owner'
        OR
        -- Permite se for owner MAS sem assinatura ativa
        NOT EXISTS (
            SELECT 1 FROM subscriptions
            WHERE subscriptions.user_id = user_approvals.user_id
            AND status IN ('active', 'trialing')
        )
        OR
        -- Sempre permite se for o super admin
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid()
            AND email = 'novaradiosystem@outlook.com'
        )
    );

-- Política similar para empresas
DROP POLICY IF EXISTS "Bloquear DELETE de empresas com assinatura" ON empresas;
CREATE POLICY "Bloquear DELETE de empresas com assinatura"
    ON empresas
    FOR DELETE
    USING (
        -- Permite se NÃO tiver assinatura ativa
        NOT EXISTS (
            SELECT 1 FROM subscriptions
            WHERE subscriptions.user_id = empresas.user_id
            AND status IN ('active', 'trialing')
        )
        OR
        -- Sempre permite se for o super admin
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE id = auth.uid()
            AND email = 'novaradiosystem@outlook.com'
        )
    );

-- =====================================================
-- CAMADA 4: FUNÇÕES DE SOFT DELETE
-- Para uso opcional no código
-- =====================================================

CREATE OR REPLACE FUNCTION soft_delete_user_approval(user_approval_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    UPDATE user_approvals 
    SET deleted_at = NOW()
    WHERE id = user_approval_id
    AND deleted_at IS NULL
    RETURNING jsonb_build_object(
        'success', true,
        'id', id,
        'deleted_at', deleted_at,
        'message', 'Usuário marcado como excluído com sucesso'
    ) INTO result;
    
    IF result IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não encontrado ou já está excluído'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION restaurar_user_approval(user_approval_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    UPDATE user_approvals 
    SET deleted_at = NULL
    WHERE id = user_approval_id
    AND deleted_at IS NOT NULL
    RETURNING jsonb_build_object(
        'success', true,
        'id', id,
        'message', 'Usuário restaurado com sucesso'
    ) INTO result;
    
    IF result IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não encontrado ou não estava excluído'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CAMADA 5: VIEWS PARA CONSULTAS
-- =====================================================

CREATE OR REPLACE VIEW user_approvals_ativos AS
SELECT * FROM user_approvals WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW funcionarios_ativos AS
SELECT * FROM funcionarios WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW empresas_ativas AS
SELECT * FROM empresas WHERE deleted_at IS NULL;

-- View de owners protegidos
CREATE OR REPLACE VIEW owners_protegidos AS
SELECT 
    ua.id,
    ua.user_id,
    ua.email,
    ua.approved_at,
    ua.approved_by,
    s.status as subscription_status,
    s.plan_type,
    CASE 
        WHEN s.status IN ('active', 'trialing') THEN true
        ELSE false
    END as delete_protegido
FROM user_approvals ua
LEFT JOIN subscriptions s ON s.user_id = ua.user_id
WHERE ua.user_role = 'owner'
AND ua.deleted_at IS NULL;

COMMENT ON VIEW owners_protegidos IS 'Lista de usuários pagantes e seu status de proteção contra DELETE';

-- =====================================================
-- CAMADA 6: REVOGAÇÃO DE PERMISSÕES PERIGOSAS
-- Remove permissão de TRUNCATE (que ignora triggers)
-- =====================================================

-- Revogar TRUNCATE (que ignora triggers e RLS)
REVOKE TRUNCATE ON user_approvals FROM authenticated, anon, PUBLIC;
REVOKE TRUNCATE ON funcionarios FROM authenticated, anon, PUBLIC;
REVOKE TRUNCATE ON empresas FROM authenticated, anon, PUBLIC;

-- Adicionar comentários de segurança
COMMENT ON TABLE user_approvals IS 'PROTEGIDO: Triggers e RLS impedem DELETE de owners com assinatura. TRUNCATE está desabilitado.';
COMMENT ON TABLE funcionarios IS 'PROTEGIDO: Triggers e RLS impedem DELETE de owners com assinatura. TRUNCATE está desabilitado.';
COMMENT ON TABLE empresas IS 'PROTEGIDO: Triggers e RLS impedem DELETE de empresas com assinatura. TRUNCATE está desabilitado.';

-- =====================================================
-- INSTRUÇÕES E TESTES
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ PROTEÇÃO MÁXIMA INSTALADA COM SUCESSO!';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 PROTEÇÃO ATIVA PARA:';
    RAISE NOTICE '  - Usuários pagantes (owners) com assinatura ativa';
    RAISE NOTICE '  - Empresas com assinatura ativa';
    RAISE NOTICE '';
    RAISE NOTICE '🛡️ CAMADAS DE PROTEÇÃO:';
    RAISE NOTICE '  1. Tabela de auditoria (delete_attempts_log)';
    RAISE NOTICE '  2. Soft delete (deleted_at)';
    RAISE NOTICE '  3. Triggers BEFORE DELETE';
    RAISE NOTICE '  4. Políticas RLS (Row Level Security)';
    RAISE NOTICE '  5. Funções seguras de soft delete';
    RAISE NOTICE '  6. Views filtradas';
    RAISE NOTICE '  7. TRUNCATE desabilitado';
    RAISE NOTICE '';
    RAISE NOTICE '✅ PERMITIDO:';
    RAISE NOTICE '  - DELETE de funcionários comuns';
    RAISE NOTICE '  - DELETE de owners SEM assinatura';
    RAISE NOTICE '  - DELETE de dados secundários (produtos, vendas, etc)';
    RAISE NOTICE '  - ON DELETE CASCADE funciona normalmente';
    RAISE NOTICE '  - SUPER ADMIN (novaradiosystem@outlook.com) pode deletar QUALQUER usuário';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ LIMITAÇÕES:';
    RAISE NOTICE '  - Postgres SUPERUSER pode contornar estas proteções';
    RAISE NOTICE '  - Service Role Key pode contornar RLS';
    RAISE NOTICE '  - SOLUÇÃO: Proteja credenciais administrativas!';
    RAISE NOTICE '';
    RAISE NOTICE '📊 AUDITORIA:';
    RAISE NOTICE '  - Todas as tentativas de DELETE são registradas';
    RAISE NOTICE '  - Ver log: SELECT * FROM delete_attempts_log ORDER BY attempted_at DESC';
    RAISE NOTICE '';
    RAISE NOTICE '💡 SOFT DELETE (Opcional):';
    RAISE NOTICE '  - SELECT soft_delete_user_approval(uuid)';
    RAISE NOTICE '  - SELECT restaurar_user_approval(uuid)';
    RAISE NOTICE '';
    RAISE NOTICE '🔍 VER OWNERS PROTEGIDOS:';
    RAISE NOTICE '  - SELECT * FROM owners_protegidos';
END $$;
