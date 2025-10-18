-- ============================================
-- ADICIONAR COLUNA STATUS NA TABELA FUNCIONARIOS
-- ============================================
-- Descrição: Adiciona coluna 'status' para controlar
-- funcionários ativos, pausados ou inativos
-- Data: 2025
-- ============================================

-- 1. Adicionar coluna status (se não existir)
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
        ADD COLUMN status VARCHAR(20) DEFAULT 'ativo' 
        CHECK (status IN ('ativo', 'pausado', 'inativo'));
        
        RAISE NOTICE 'Coluna status adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'Coluna status já existe.';
    END IF;
END $$;

-- 1.1. Adicionar coluna ultimo_acesso (se não existir)
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
        
        RAISE NOTICE 'Coluna ultimo_acesso adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'Coluna ultimo_acesso já existe.';
    END IF;
END $$;

-- 2. Atualizar todos os registros existentes para 'ativo'
UPDATE funcionarios 
SET status = 'ativo' 
WHERE status IS NULL;

-- 3. Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_funcionarios_status 
ON funcionarios(status);

CREATE INDEX IF NOT EXISTS idx_funcionarios_ultimo_acesso 
ON funcionarios(ultimo_acesso);

-- 4. Verificar resultado
SELECT 
    COUNT(*) as total_funcionarios,
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as ativos,
    COUNT(CASE WHEN status = 'pausado' THEN 1 END) as pausados,
    COUNT(CASE WHEN status = 'inativo' THEN 1 END) as inativos
FROM funcionarios;

-- ============================================
-- ATUALIZAR FUNÇÃO DE LOGIN PARA VERIFICAR STATUS
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
        f.status
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

-- ============================================
-- TESTES
-- ============================================

-- Testar estrutura da tabela
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'funcionarios' 
AND column_name IN ('status', 'ultimo_acesso')
ORDER BY ordinal_position;

-- Verificar funcionários
SELECT 
    id,
    nome,
    status,
    tipo_admin,
    ultimo_acesso
FROM funcionarios
ORDER BY nome;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- ✅ Coluna 'status' criada
-- ✅ Todos funcionários existentes com status 'ativo'
-- ✅ Índice criado para performance
-- ✅ Função de login atualizada para verificar status
-- ✅ Funcionários pausados não conseguem fazer login
-- ============================================
