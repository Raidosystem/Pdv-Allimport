-- =====================================================
-- RESET DE EMERGÊNCIA - SENHA MESTRA
-- =====================================================
-- Use este SQL APENAS na primeira configuração
-- ou se esquecer a senha mestra
-- =====================================================

-- OPÇÃO 1: Reset completo (apaga senhas antigas e cria nova)
-- Execute este bloco para definir sua senha pela primeira vez
-- =====================================================

DO $$
DECLARE
    v_user_email TEXT;
    v_new_password TEXT := 'A#procuradaFelicidade$123@@';  -- ⚠️ TROCAR AQUI pela sua senha
BEGIN
    -- Verificar se é super admin
    SELECT email INTO v_user_email
    FROM auth.users
    WHERE id = auth.uid();
    
    IF v_user_email != 'novaradiosystem@outlook.com' THEN
        RAISE EXCEPTION 'Apenas o super admin pode resetar a senha mestra';
    END IF;
    
    -- Desativar todas as senhas antigas
    UPDATE master_passwords SET active = false WHERE active = true;
    
    -- Criar nova senha
    INSERT INTO master_passwords (password_hash, created_by, description, active)
    VALUES (
        crypt(v_new_password, gen_salt('bf', 10)),
        auth.uid(),
        'Senha resetada em ' || NOW()::TEXT,
        true
    );
    
    -- Registrar no log
    INSERT INTO master_password_attempts (
        user_id, user_email, success, operation_type
    ) VALUES (
        auth.uid(), v_user_email, true, 'EMERGENCY_RESET'
    );
    
    RAISE NOTICE '✅ Senha mestra resetada com sucesso!';
    RAISE NOTICE 'Nova senha: %', v_new_password;
    RAISE NOTICE '⚠️  Guarde esta senha em local seguro!';
END $$;

-- =====================================================
-- INSTRUÇÕES:
-- =====================================================
-- 1. Edite a linha 15: v_new_password := 'A#procuradaFelicidade$123@@';
-- 2. Coloque sua senha desejada (mínimo 12 caracteres)
-- 3. Execute este SQL
-- 4. Teste: SELECT validate_master_password('SuaSenhaAqui');
-- 5. Deve retornar: true
-- =====================================================
