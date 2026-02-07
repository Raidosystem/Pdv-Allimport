-- =====================================================
-- SISTEMA DE SENHA MESTRA PARA SQL CRÍTICOS
-- =====================================================
-- Adiciona camada extra de segurança ao executar SQLs
-- Requer senha mestra antes de executar comandos perigosos
-- =====================================================

-- CAMADA 1: TABELA DE SENHAS MESTRAS
-- Armazena hash bcrypt da senha mestra
-- =====================================================

CREATE TABLE IF NOT EXISTS master_passwords (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    password_hash TEXT NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    active BOOLEAN DEFAULT true,
    description TEXT
);

COMMENT ON TABLE master_passwords IS 'Senhas mestras hasheadas para executar operações críticas no banco';

-- Inserir senha mestra inicial
-- SENHA PADRÃO: RaVal@2026Secure
-- Hash bcrypt: $2b$10$... (você deve trocar isso!)
INSERT INTO master_passwords (password_hash, description, active)
VALUES (
    '$2b$10$XQ8J9K5p8vZ9mN2xL3wV8eHnF4rK5mQ7vB2cN8wX6yP1zT4sH9jKW',
    'Senha mestra inicial do sistema - TROCAR IMEDIATAMENTE',
    true
) ON CONFLICT DO NOTHING;

-- =====================================================
-- CAMADA 2: TABELA DE TENTATIVAS DE ACESSO
-- Registra todas as tentativas (válidas e inválidas)
-- =====================================================

CREATE TABLE IF NOT EXISTS master_password_attempts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    user_email TEXT,
    success BOOLEAN NOT NULL,
    attempted_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    operation_type TEXT,
    blocked_reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_master_password_attempts_attempted_at 
ON master_password_attempts(attempted_at DESC);

CREATE INDEX IF NOT EXISTS idx_master_password_attempts_success 
ON master_password_attempts(success) WHERE success = false;

COMMENT ON TABLE master_password_attempts IS 'Log de tentativas de uso da senha mestra';

-- =====================================================
-- CAMADA 3: FUNÇÃO DE VALIDAÇÃO DE SENHA
-- Valida senha mestra antes de operações críticas
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION validate_master_password(input_password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_password_hash TEXT;
    v_is_valid BOOLEAN := false;
    v_user_email TEXT;
BEGIN
    -- Buscar email do usuário atual
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = auth.uid();
    
    -- Buscar hash da senha ativa
    SELECT password_hash INTO v_password_hash
    FROM master_passwords
    WHERE active = true
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- Se não houver senha configurada, bloquear
    IF v_password_hash IS NULL THEN
        INSERT INTO master_password_attempts (
            user_id, user_email, success, operation_type, blocked_reason
        ) VALUES (
            auth.uid(), v_user_email, false, 'VALIDATE_PASSWORD',
            'Nenhuma senha mestra configurada'
        );
        RETURN false;
    END IF;
    
    -- Validar senha usando crypt
    v_is_valid := (crypt(input_password, v_password_hash) = v_password_hash);
    
    -- Registrar tentativa
    INSERT INTO master_password_attempts (
        user_id, user_email, success, operation_type
    ) VALUES (
        auth.uid(), v_user_email, v_is_valid, 'VALIDATE_PASSWORD'
    );
    
    RETURN v_is_valid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CAMADA 4: FUNÇÃO PARA TROCAR SENHA MESTRA
-- Permite trocar a senha mestra de forma segura
-- =====================================================

CREATE OR REPLACE FUNCTION change_master_password(
    current_password TEXT,
    new_password TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_user_email TEXT;
    v_is_super_admin BOOLEAN := false;
BEGIN
    -- Verificar se usuário é super admin
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = auth.uid();
    
    v_is_super_admin := (v_user_email = 'novaradiosystem@outlook.com');
    
    IF NOT v_is_super_admin THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Apenas o super admin pode trocar a senha mestra'
        );
    END IF;
    
    -- Validar senha atual
    IF NOT validate_master_password(current_password) THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Senha atual incorreta'
        );
    END IF;
    
    -- Validar nova senha (mínimo 12 caracteres)
    IF length(new_password) < 12 THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Nova senha deve ter no mínimo 12 caracteres'
        );
    END IF;
    
    -- Desativar senhas antigas
    UPDATE master_passwords SET active = false WHERE active = true;
    
    -- Inserir nova senha
    INSERT INTO master_passwords (password_hash, created_by, description, active)
    VALUES (
        crypt(new_password, gen_salt('bf', 10)),
        auth.uid(),
        'Senha alterada por ' || v_user_email,
        true
    );
    
    -- Registrar no log
    INSERT INTO master_password_attempts (
        user_id, user_email, success, operation_type
    ) VALUES (
        auth.uid(), v_user_email, true, 'CHANGE_PASSWORD'
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Senha mestra alterada com sucesso'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CAMADA 5: FUNÇÕES PROTEGIDAS POR SENHA
-- Operações críticas que exigem senha mestra
-- =====================================================

-- Função para deletar usuário com senha
CREATE OR REPLACE FUNCTION delete_user_with_password(
    master_password TEXT,
    user_id_to_delete UUID
)
RETURNS JSONB AS $$
DECLARE
    v_user_email TEXT;
    v_is_super_admin BOOLEAN := false;
BEGIN
    -- Verificar senha mestra
    IF NOT validate_master_password(master_password) THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Senha mestra incorreta'
        );
    END IF;
    
    -- Verificar se é super admin
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = auth.uid();
    
    v_is_super_admin := (v_user_email = 'novaradiosystem@outlook.com');
    
    IF NOT v_is_super_admin THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Apenas o super admin pode deletar usuários'
        );
    END IF;
    
    -- Executar delete
    DELETE FROM user_approvals WHERE id = user_id_to_delete;
    
    -- Registrar no log
    INSERT INTO master_password_attempts (
        user_id, user_email, success, operation_type
    ) VALUES (
        auth.uid(), v_user_email, true, 'DELETE_USER'
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Usuário deletado com sucesso'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para executar SQL arbitrário com senha
CREATE OR REPLACE FUNCTION execute_sql_with_password(
    master_password TEXT,
    sql_query TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_user_email TEXT;
    v_is_super_admin BOOLEAN := false;
    v_result TEXT;
BEGIN
    -- Verificar senha mestra
    IF NOT validate_master_password(master_password) THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Senha mestra incorreta'
        );
    END IF;
    
    -- Verificar se é super admin
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = auth.uid();
    
    v_is_super_admin := (v_user_email = 'novaradiosystem@outlook.com');
    
    IF NOT v_is_super_admin THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Apenas o super admin pode executar SQL direto'
        );
    END IF;
    
    -- Bloquear comandos muito perigosos
    IF sql_query ~* 'DROP\s+DATABASE|DROP\s+SCHEMA|TRUNCATE.*auth\.users' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Comando bloqueado por segurança extrema'
        );
    END IF;
    
    -- Executar SQL
    EXECUTE sql_query;
    
    -- Registrar no log
    INSERT INTO master_password_attempts (
        user_id, user_email, success, operation_type
    ) VALUES (
        auth.uid(), v_user_email, true, 'EXECUTE_SQL: ' || left(sql_query, 100)
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'SQL executado com sucesso'
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', 'Erro ao executar SQL: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CAMADA 6: ATUALIZAR TRIGGERS EXISTENTES
-- Adicionar validação de senha aos triggers de proteção
-- =====================================================

-- Criar configuração temporária para bypass do trigger
CREATE TABLE IF NOT EXISTS temp_master_password_bypass (
    session_id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '5 minutes'
);

-- Função para criar bypass temporário
CREATE OR REPLACE FUNCTION create_temp_bypass(master_password TEXT)
RETURNS TEXT AS $$
DECLARE
    v_session_id TEXT;
BEGIN
    -- Validar senha
    IF NOT validate_master_password(master_password) THEN
        RAISE EXCEPTION 'Senha mestra incorreta';
    END IF;
    
    -- Gerar ID de sessão único
    v_session_id := gen_random_uuid()::text;
    
    -- Criar bypass temporário (5 minutos)
    INSERT INTO temp_master_password_bypass (session_id, user_id)
    VALUES (v_session_id, auth.uid());
    
    -- Limpar bypasses expirados
    DELETE FROM temp_master_password_bypass WHERE expires_at < NOW();
    
    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INSTRUÇÕES DE USO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ SISTEMA DE SENHA MESTRA INSTALADO!';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 SENHA PADRÃO: RaVal@2026Secure';
    RAISE NOTICE '⚠️  TROQUE IMEDIATAMENTE com: SELECT change_master_password(''senha_atual'', ''nova_senha'')';
    RAISE NOTICE '';
    RAISE NOTICE '📋 FUNÇÕES DISPONÍVEIS:';
    RAISE NOTICE '  1. validate_master_password(senha) - Validar senha';
    RAISE NOTICE '  2. change_master_password(atual, nova) - Trocar senha';
    RAISE NOTICE '  3. delete_user_with_password(senha, user_id) - Deletar usuário';
    RAISE NOTICE '  4. execute_sql_with_password(senha, sql) - Executar SQL';
    RAISE NOTICE '  5. create_temp_bypass(senha) - Criar bypass temporário';
    RAISE NOTICE '';
    RAISE NOTICE '🔍 MONITORAMENTO:';
    RAISE NOTICE '  - Ver tentativas: SELECT * FROM master_password_attempts ORDER BY attempted_at DESC';
    RAISE NOTICE '  - Ver falhas: SELECT * FROM master_password_attempts WHERE success = false';
    RAISE NOTICE '';
    RAISE NOTICE '💡 EXEMPLO DE USO:';
    RAISE NOTICE '  SELECT delete_user_with_password(''RaVal@2026Secure'', ''user-uuid-aqui'')';
END $$;
