-- ============================================
-- ESTRUTURA COMPLETA TABELA FUNCIONARIOS
-- ============================================
-- Descrição: Garante que todas as colunas necessárias existam
-- Data: Outubro 2025
-- ============================================

-- 1. ADICIONAR COLUNAS FALTANTES (SE NÃO EXISTIREM)
-- ============================================

-- Coluna: status
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN status VARCHAR(20) DEFAULT 'ativo';
        
        -- Adicionar constraint separadamente
        ALTER TABLE funcionarios
        ADD CONSTRAINT check_funcionarios_status 
        CHECK (status IN ('ativo', 'pausado', 'inativo'));
        
        RAISE NOTICE '✅ Coluna status adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna status já existe.';
    END IF;
END $$;

-- Coluna: ultimo_acesso
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'ultimo_acesso'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN ultimo_acesso TIMESTAMP;
        
        RAISE NOTICE '✅ Coluna ultimo_acesso adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna ultimo_acesso já existe.';
    END IF;
END $$;

-- Coluna: tipo_admin (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'tipo_admin'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN tipo_admin VARCHAR(50);
        
        RAISE NOTICE '✅ Coluna tipo_admin adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna tipo_admin já existe.';
    END IF;
END $$;

-- Tornar coluna email NULLABLE (se não for)
DO $$ 
BEGIN
    ALTER TABLE funcionarios 
    ALTER COLUMN email DROP NOT NULL;
    
    RAISE NOTICE '✅ Coluna email agora aceita NULL!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ℹ️ Coluna email já aceita NULL.';
END $$;

-- 2. ATUALIZAR DADOS EXISTENTES
-- ============================================

-- Definir status 'ativo' para funcionários sem status
UPDATE funcionarios 
SET status = 'ativo' 
WHERE status IS NULL;

-- Definir tipo_admin para funcionários existentes (se não for admin)
UPDATE funcionarios 
SET tipo_admin = 'funcionario' 
WHERE tipo_admin IS NULL;

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_funcionarios_status 
ON funcionarios(status);

CREATE INDEX IF NOT EXISTS idx_funcionarios_ultimo_acesso 
ON funcionarios(ultimo_acesso);

CREATE INDEX IF NOT EXISTS idx_funcionarios_tipo_admin 
ON funcionarios(tipo_admin);

CREATE INDEX IF NOT EXISTS idx_funcionarios_empresa_id 
ON funcionarios(empresa_id);

-- 4. VERIFICAR ESTRUTURA FINAL
-- ============================================

SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'funcionarios' 
ORDER BY ordinal_position;

-- 5. VERIFICAR DADOS DOS FUNCIONÁRIOS
-- ============================================

SELECT 
    COUNT(*) as total_funcionarios,
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as ativos,
    COUNT(CASE WHEN status = 'pausado' THEN 1 END) as pausados,
    COUNT(CASE WHEN status = 'inativo' THEN 1 END) as inativos,
    COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins,
    COUNT(CASE WHEN tipo_admin = 'funcionario' THEN 1 END) as funcionarios_normais,
    COUNT(CASE WHEN email IS NULL THEN 1 END) as sem_email
FROM funcionarios;

-- 6. ATUALIZAR FUNÇÃO DE LOGIN PARA VERIFICAR STATUS
-- ============================================

CREATE OR REPLACE FUNCTION verificar_login_funcionario(
    p_usuario TEXT,
    p_senha TEXT
)
RETURNS TABLE (
    sucesso BOOLEAN,
    funcionario_id UUID,
    nome TEXT,
    empresa_id UUID,
    mensagem TEXT,
    status TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_funcionario_id UUID;
    v_nome TEXT;
    v_empresa_id UUID;
    v_senha_hash TEXT;
    v_ativo BOOLEAN;
    v_status TEXT;
BEGIN
    -- Buscar funcionário pelo usuário
    SELECT 
        lf.funcionario_id,
        lf.senha_hash,
        lf.ativo,
        f.nome,
        f.empresa_id,
        COALESCE(f.status, 'ativo') -- Default ativo se NULL
    INTO 
        v_funcionario_id,
        v_senha_hash,
        v_ativo,
        v_nome,
        v_empresa_id,
        v_status
    FROM login_funcionarios lf
    INNER JOIN funcionarios f ON f.id = lf.funcionario_id
    WHERE lf.usuario = p_usuario;

    -- Verificar se funcionário existe
    IF v_funcionario_id IS NULL THEN
        RETURN QUERY SELECT 
            FALSE, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::UUID, 
            'Usuário ou senha inválidos'::TEXT,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Verificar se está pausado
    IF v_status = 'pausado' THEN
        RETURN QUERY SELECT 
            FALSE, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::UUID, 
            'Funcionário pausado. Entre em contato com o administrador.'::TEXT,
            v_status;
        RETURN;
    END IF;

    -- Verificar se está inativo
    IF NOT v_ativo OR v_status = 'inativo' THEN
        RETURN QUERY SELECT 
            FALSE, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::UUID, 
            'Funcionário inativo. Entre em contato com o administrador.'::TEXT,
            v_status;
        RETURN;
    END IF;

    -- Verificar senha (simplificado - em produção use bcrypt)
    IF v_senha_hash = encode(p_senha::bytea, 'base64') THEN
        -- Atualizar último acesso
        UPDATE funcionarios 
        SET ultimo_acesso = NOW() 
        WHERE id = v_funcionario_id;

        RETURN QUERY SELECT 
            TRUE, 
            v_funcionario_id, 
            v_nome, 
            v_empresa_id, 
            'Login realizado com sucesso'::TEXT,
            v_status;
    ELSE
        RETURN QUERY SELECT 
            FALSE, 
            NULL::UUID, 
            NULL::TEXT, 
            NULL::UUID, 
            'Usuário ou senha inválidos'::TEXT,
            NULL::TEXT;
    END IF;
END;
$$;

-- 7. TESTAR FUNÇÃO DE LOGIN
-- ============================================

-- Listar todos os funcionários com seus dados de login
SELECT 
    f.id,
    f.nome,
    f.status,
    f.tipo_admin,
    f.ultimo_acesso,
    lf.usuario,
    lf.ativo as login_ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
ORDER BY f.nome;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- ✅ Coluna 'status' criada (ativo, pausado, inativo)
-- ✅ Coluna 'ultimo_acesso' criada (TIMESTAMP)
-- ✅ Coluna 'tipo_admin' criada (se não existia)
-- ✅ Coluna 'email' aceita NULL
-- ✅ Todos funcionários existentes com status 'ativo'
-- ✅ Índices criados para performance
-- ✅ Função de login atualizada
-- ✅ Funcionários pausados não conseguem fazer login
-- ============================================
