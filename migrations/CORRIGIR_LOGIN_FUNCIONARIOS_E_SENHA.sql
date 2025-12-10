-- ============================================
-- CORREÇÃO COMPLETA: LOGIN FUNCIONARIOS E TROCA DE SENHA
-- ============================================
-- Data: 07/12/2024
-- Descrição: Corrige estrutura da tabela login_funcionarios e RPCs de troca de senha
-- ============================================

-- ============================================
-- 1. VERIFICAR E CORRIGIR ESTRUTURA DA TABELA
-- ============================================

-- Verificar colunas atuais
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- Adicionar coluna senha_hash se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'login_funcionarios' 
        AND column_name = 'senha_hash'
    ) THEN
        ALTER TABLE login_funcionarios 
        ADD COLUMN senha_hash TEXT;
        
        RAISE NOTICE '✅ Coluna senha_hash adicionada';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna senha_hash já existe';
    END IF;
END $$;

-- Adicionar coluna precisa_trocar_senha se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'login_funcionarios' 
        AND column_name = 'precisa_trocar_senha'
    ) THEN
        ALTER TABLE login_funcionarios 
        ADD COLUMN precisa_trocar_senha BOOLEAN DEFAULT true;
        
        RAISE NOTICE '✅ Coluna precisa_trocar_senha adicionada';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna precisa_trocar_senha já existe';
    END IF;
END $$;

-- ============================================
-- 2. CORRIGIR RPC: trocar_senha_propria
-- ============================================

-- Remover TODAS as versões antigas da função
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.trocar_senha_propria(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.trocar_senha_propria;

-- Criar função correta
CREATE OR REPLACE FUNCTION public.trocar_senha_propria(
    p_funcionario_id UUID,
    p_nova_senha TEXT,
    p_senha_antiga TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_login RECORD;
    v_senha_hash_antiga TEXT;
    v_senha_hash_nova TEXT;
BEGIN
    -- 🔍 DEBUG: Log dos parâmetros
    RAISE NOTICE '🔑 Iniciando troca de senha';
    RAISE NOTICE '   funcionario_id: %', p_funcionario_id;
    RAISE NOTICE '   nova_senha length: %', LENGTH(p_nova_senha);
    RAISE NOTICE '   senha_antiga length: %', LENGTH(p_senha_antiga);

    -- Buscar login do funcionário
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE NOTICE '❌ Funcionário não encontrado no login_funcionarios';
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Funcionário não possui login local'
        );
    END IF;

    -- 🔍 DEBUG: Login encontrado
    RAISE NOTICE '✅ Login encontrado: %', v_login.usuario;
    RAISE NOTICE '   senha_hash existe: %', (v_login.senha_hash IS NOT NULL);

    -- Validar senha antiga
    v_senha_hash_antiga := crypt(p_senha_antiga, v_login.senha_hash);
    
    RAISE NOTICE '🔐 Validando senha antiga...';
    RAISE NOTICE '   Hash armazenado: %', SUBSTRING(v_login.senha_hash, 1, 20);
    RAISE NOTICE '   Hash calculado: %', SUBSTRING(v_senha_hash_antiga, 1, 20);
    
    IF v_senha_hash_antiga != v_login.senha_hash THEN
        RAISE NOTICE '❌ Senha antiga incorreta';
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Senha antiga incorreta'
        );
    END IF;

    RAISE NOTICE '✅ Senha antiga validada com sucesso';

    -- Gerar hash da nova senha
    v_senha_hash_nova := crypt(p_nova_senha, gen_salt('bf'));
    
    RAISE NOTICE '🔐 Gerando hash da nova senha...';
    RAISE NOTICE '   Novo hash: %', SUBSTRING(v_senha_hash_nova, 1, 20);

    -- Atualizar senha e marcar como não precisa trocar
    UPDATE login_funcionarios
    SET 
        senha_hash = v_senha_hash_nova,
        precisa_trocar_senha = false,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RAISE NOTICE '✅ Senha atualizada no banco de dados';

    -- Retornar sucesso
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Senha alterada com sucesso'
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO: % - %', SQLERRM, SQLSTATE;
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- Comentar função
COMMENT ON FUNCTION public.trocar_senha_propria IS 
'Permite que um funcionário troque sua própria senha, validando a senha antiga';

-- ============================================
-- 3. CORRIGIR RPC: atualizar_senha_funcionario
-- ============================================

-- Remover TODAS as versões antigas da função
DROP FUNCTION IF EXISTS public.atualizar_senha_funcionario(UUID, TEXT);
DROP FUNCTION IF EXISTS public.atualizar_senha_funcionario(TEXT, TEXT);
DROP FUNCTION IF EXISTS public.atualizar_senha_funcionario;

-- Criar função para admin atualizar senha (sem validar antiga)
CREATE OR REPLACE FUNCTION public.atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_login RECORD;
    v_senha_hash_nova TEXT;
BEGIN
    -- 🔍 DEBUG
    RAISE NOTICE '🔑 Atualizando senha (admin)';
    RAISE NOTICE '   funcionario_id: %', p_funcionario_id;

    -- Buscar login do funcionário
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE NOTICE '❌ Funcionário não encontrado';
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Funcionário não possui login local'
        );
    END IF;

    -- Gerar hash da nova senha
    v_senha_hash_nova := crypt(p_nova_senha, gen_salt('bf'));

    -- Atualizar senha e forçar troca no próximo login
    UPDATE login_funcionarios
    SET 
        senha_hash = v_senha_hash_nova,
        precisa_trocar_senha = true,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RAISE NOTICE '✅ Senha atualizada (admin) - precisa_trocar_senha=true';

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso. Funcionário precisará trocar a senha no próximo login.'
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO: %', SQLERRM;
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

COMMENT ON FUNCTION public.atualizar_senha_funcionario IS 
'Permite que um admin atualize a senha de um funcionário (sem validar senha antiga)';

-- ============================================
-- 4. GARANTIR PERMISSÕES DE EXECUÇÃO
-- ============================================

-- Garantir que authenticated pode executar as funções
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

-- ============================================
-- 5. ATUALIZAR SENHAS EXISTENTES (SE NECESSÁRIO)
-- ============================================

-- Verificar se há logins sem senha_hash
SELECT 
    lf.id,
    lf.usuario,
    lf.funcionario_id,
    (lf.senha_hash IS NULL) as sem_senha,
    f.nome as nome_funcionario
FROM login_funcionarios lf
LEFT JOIN funcionarios f ON f.id = lf.funcionario_id;

-- Se encontrar logins sem senha_hash, atualizar com senha padrão
-- (DESCOMENTAR APENAS SE NECESSÁRIO)
/*
UPDATE login_funcionarios
SET 
    senha_hash = crypt('123456', gen_salt('bf')),
    precisa_trocar_senha = true
WHERE senha_hash IS NULL;
*/

-- ============================================
-- 6. VERIFICAÇÃO FINAL
-- ============================================

-- Verificar estrutura final
SELECT 
    column_name, 
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- Verificar funções criadas
SELECT 
    p.proname as function_name,
    pg_get_function_identity_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND p.proname IN ('trocar_senha_propria', 'atualizar_senha_funcionario')
ORDER BY p.proname;

-- ============================================
-- ✅ CORREÇÃO CONCLUÍDA
-- ============================================
-- Agora você pode:
-- 1. Logar como admin e atualizar senha de qualquer funcionário
-- 2. Logar como funcionário e trocar sua própria senha
-- ============================================
