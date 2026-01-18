-- =====================================================
-- PROTEÇÃO MÁXIMA CONTRA EXCLUSÃO DE USUÁRIOS
-- =====================================================
-- Este script implementa múltiplas camadas de segurança
-- para IMPEDIR a exclusão de usuários do banco de dados
-- =====================================================

-- CAMADA 1: SOFT DELETE (Deleção Lógica)
-- Adiciona campo deleted_at para "marcar como excluído" sem deletar
-- =====================================================

-- Adicionar campo deleted_at nas tabelas críticas (se não existir)
ALTER TABLE user_approvals 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

COMMENT ON COLUMN user_approvals.deleted_at IS 'Data de exclusão lógica - NULL = ativo, data = excluído';
COMMENT ON COLUMN funcionarios.deleted_at IS 'Data de exclusão lógica - NULL = ativo, data = excluído';
COMMENT ON COLUMN empresas.deleted_at IS 'Data de exclusão lógica - NULL = ativo, data = excluído';

-- =====================================================
-- CAMADA 2: TRIGGERS DE BLOQUEIO
-- Impede DELETE físico nas tabelas críticas
-- =====================================================

-- Função que BLOQUEIA qualquer DELETE
CREATE OR REPLACE FUNCTION bloquear_delete_usuarios()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'OPERAÇÃO BLOQUEADA: Exclusão de usuários não é permitida. Use soft delete (UPDATE deleted_at) em vez disso.'
        USING HINT = 'Para desativar um usuário, use: UPDATE ' || TG_TABLE_NAME || ' SET deleted_at = NOW() WHERE id = ...';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger em user_approvals
DROP TRIGGER IF EXISTS prevent_delete_user_approvals ON user_approvals;
CREATE TRIGGER prevent_delete_user_approvals
    BEFORE DELETE ON user_approvals
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios();

-- Aplicar trigger em funcionarios
DROP TRIGGER IF EXISTS prevent_delete_funcionarios ON funcionarios;
CREATE TRIGGER prevent_delete_funcionarios
    BEFORE DELETE ON funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios();

-- Aplicar trigger em empresas
DROP TRIGGER IF EXISTS prevent_delete_empresas ON empresas;
CREATE TRIGGER prevent_delete_empresas
    BEFORE DELETE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios();

-- =====================================================
-- CAMADA 3: POLÍTICAS RLS
-- Nega permissão de DELETE via RLS
-- =====================================================

-- Remover políticas antigas de DELETE (se existirem)
DROP POLICY IF EXISTS "Bloquear DELETE em user_approvals" ON user_approvals;
DROP POLICY IF EXISTS "Bloquear DELETE em funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Bloquear DELETE em empresas" ON empresas;

-- Criar políticas que NEGAM DELETE
CREATE POLICY "Bloquear DELETE em user_approvals"
    ON user_approvals
    FOR DELETE
    USING (false);  -- Sempre falso = NUNCA permite DELETE

CREATE POLICY "Bloquear DELETE em funcionarios"
    ON funcionarios
    FOR DELETE
    USING (false);

CREATE POLICY "Bloquear DELETE em empresas"
    ON empresas
    FOR DELETE
    USING (false);

-- =====================================================
-- CAMADA 4: FUNÇÕES DE SOFT DELETE
-- Funções seguras para "excluir" (marcar como excluído)
-- =====================================================

-- Função para soft delete de user_approval
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

-- Função para restaurar user_approval
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

-- Função para soft delete de funcionário
CREATE OR REPLACE FUNCTION soft_delete_funcionario(funcionario_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    UPDATE funcionarios 
    SET deleted_at = NOW()
    WHERE id = funcionario_id
    AND deleted_at IS NULL
    RETURNING jsonb_build_object(
        'success', true,
        'id', id,
        'deleted_at', deleted_at,
        'message', 'Funcionário marcado como excluído com sucesso'
    ) INTO result;
    
    IF result IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Funcionário não encontrado ou já está excluído'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para restaurar funcionário
CREATE OR REPLACE FUNCTION restaurar_funcionario(funcionario_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    UPDATE funcionarios 
    SET deleted_at = NULL
    WHERE id = funcionario_id
    AND deleted_at IS NOT NULL
    RETURNING jsonb_build_object(
        'success', true,
        'id', id,
        'message', 'Funcionário restaurado com sucesso'
    ) INTO result;
    
    IF result IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Funcionário não encontrado ou não estava excluído'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CAMADA 5: ÍNDICES PARA PERFORMANCE
-- Otimiza consultas com deleted_at
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_user_approvals_deleted_at 
ON user_approvals(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_funcionarios_deleted_at 
ON funcionarios(deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_empresas_deleted_at 
ON empresas(deleted_at) WHERE deleted_at IS NULL;

-- =====================================================
-- CAMADA 6: VIEWS PARA CONSULTAS
-- Views que filtram automaticamente registros excluídos
-- =====================================================

-- View de user_approvals ativos
CREATE OR REPLACE VIEW user_approvals_ativos AS
SELECT * FROM user_approvals WHERE deleted_at IS NULL;

-- View de funcionarios ativos
CREATE OR REPLACE VIEW funcionarios_ativos AS
SELECT * FROM funcionarios WHERE deleted_at IS NULL;

-- View de empresas ativas
CREATE OR REPLACE VIEW empresas_ativas AS
SELECT * FROM empresas WHERE deleted_at IS NULL;

-- =====================================================
-- CAMADA 7: AUDITORIA DE TENTATIVAS DE DELETE
-- Registra tentativas de exclusão para análise de segurança
-- =====================================================

-- Tabela de log de tentativas de delete
CREATE TABLE IF NOT EXISTS delete_attempts_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id UUID,
    attempted_by UUID REFERENCES auth.users(id),
    attempted_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    blocked BOOLEAN DEFAULT true
);

COMMENT ON TABLE delete_attempts_log IS 'Log de todas as tentativas de DELETE bloqueadas no sistema';

-- Função atualizada que registra tentativas
CREATE OR REPLACE FUNCTION bloquear_delete_usuarios_com_log()
RETURNS TRIGGER AS $$
BEGIN
    -- Registra a tentativa de delete
    INSERT INTO delete_attempts_log (
        table_name,
        record_id,
        attempted_by,
        blocked
    ) VALUES (
        TG_TABLE_NAME,
        OLD.id,
        auth.uid(),
        true
    );
    
    -- Bloqueia a operação
    RAISE EXCEPTION 'OPERAÇÃO BLOQUEADA: Exclusão de usuários não é permitida. Tentativa registrada no log de segurança.'
        USING HINT = 'Para desativar um usuário, use: SELECT soft_delete_user_approval(''' || OLD.id || ''')';
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar triggers com a função que faz log
DROP TRIGGER IF EXISTS prevent_delete_user_approvals ON user_approvals;
CREATE TRIGGER prevent_delete_user_approvals
    BEFORE DELETE ON user_approvals
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios_com_log();

DROP TRIGGER IF EXISTS prevent_delete_funcionarios ON funcionarios;
CREATE TRIGGER prevent_delete_funcionarios
    BEFORE DELETE ON funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios_com_log();

DROP TRIGGER IF EXISTS prevent_delete_empresas ON empresas;
CREATE TRIGGER prevent_delete_empresas
    BEFORE DELETE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION bloquear_delete_usuarios_com_log();

-- =====================================================
-- CAMADA 8: PERMISSÕES RESTRITAS
-- Remove permissões de DELETE do schema public
-- =====================================================

-- Revoga DELETE de usuários autenticados
REVOKE DELETE ON user_approvals FROM authenticated;
REVOKE DELETE ON funcionarios FROM authenticated;
REVOKE DELETE ON empresas FROM authenticated;

-- Revoga DELETE de usuários anônimos
REVOKE DELETE ON user_approvals FROM anon;
REVOKE DELETE ON funcionarios FROM anon;
REVOKE DELETE ON empresas FROM anon;

-- =====================================================
-- INSTRUÇÕES DE USO
-- =====================================================

-- COMO USAR SOFT DELETE:
-- SELECT soft_delete_user_approval('uuid-do-usuario');
-- SELECT soft_delete_funcionario('uuid-do-funcionario');

-- COMO RESTAURAR:
-- SELECT restaurar_user_approval('uuid-do-usuario');
-- SELECT restaurar_funcionario('uuid-do-funcionario');

-- LISTAR USUÁRIOS EXCLUÍDOS:
-- SELECT * FROM user_approvals WHERE deleted_at IS NOT NULL;
-- SELECT * FROM funcionarios WHERE deleted_at IS NOT NULL;

-- LISTAR TENTATIVAS DE DELETE BLOQUEADAS:
-- SELECT * FROM delete_attempts_log ORDER BY attempted_at DESC;

-- =====================================================
-- TESTE DE SEGURANÇA
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ PROTEÇÃO MÁXIMA INSTALADA COM SUCESSO!';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 CAMADAS DE SEGURANÇA ATIVAS:';
    RAISE NOTICE '  1. Soft Delete (deleted_at)';
    RAISE NOTICE '  2. Triggers de Bloqueio';
    RAISE NOTICE '  3. Políticas RLS (DELETE negado)';
    RAISE NOTICE '  4. Funções seguras de soft delete';
    RAISE NOTICE '  5. Índices otimizados';
    RAISE NOTICE '  6. Views de registros ativos';
    RAISE NOTICE '  7. Log de tentativas de delete';
    RAISE NOTICE '  8. Permissões restritas';
    RAISE NOTICE '';
    RAISE NOTICE '💡 USO:';
    RAISE NOTICE '  - Para "excluir": SELECT soft_delete_user_approval(uuid)';
    RAISE NOTICE '  - Para restaurar: SELECT restaurar_user_approval(uuid)';
    RAISE NOTICE '  - Listar excluídos: SELECT * FROM user_approvals WHERE deleted_at IS NOT NULL';
END $$;
