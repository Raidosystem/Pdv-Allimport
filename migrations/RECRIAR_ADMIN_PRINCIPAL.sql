-- =====================================================
-- RECRIAR ADMIN PRINCIPAL: novaradiosystem@outlook.com
-- =====================================================
-- Data: 07/01/2026
-- Objetivo: Recriar conta do super admin que sumiu
-- =====================================================

-- 1️⃣ Verificar se já existe
SELECT 
    '🔍 VERIFICAÇÃO' as secao,
    id,
    email,
    created_at,
    deleted_at,
    banned_until
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com';

-- 2️⃣ Recriar usuário completo
DO $$
DECLARE
    v_user_id UUID;
    v_empresa_id UUID;
BEGIN
    -- Verificar se já existe
    IF EXISTS (SELECT 1 FROM auth.users WHERE email = 'novaradiosystem@outlook.com') THEN
        RAISE NOTICE '⚠️ Usuário novaradiosystem@outlook.com já existe!';
        RETURN;
    END IF;

    -- Criar usuário no auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmation_sent_at,
        created_at,
        updated_at,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'novaradiosystem@outlook.com',
        crypt('Admin@2026!PDV', gen_salt('bf')), -- SENHA TEMPORÁRIA FORTE
        NOW(),
        NOW(),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}',
        '{"role":"super_admin"}',
        false
    ) RETURNING id INTO v_user_id;

    RAISE NOTICE '✅ Usuário auth.users criado: %', v_user_id;

    -- Criar identity
    INSERT INTO auth.identities (
        id,
        user_id,
        provider_id,
        provider,
        identity_data,
        last_sign_in_at,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        v_user_id::text,
        'email',
        jsonb_build_object(
            'sub', v_user_id::text,
            'email', 'novaradiosystem@outlook.com',
            'email_verified', true
        ),
        NOW(),
        NOW(),
        NOW()
    );

    RAISE NOTICE '✅ Identity criada';

    -- Criar empresa
    INSERT INTO empresas (
        id,
        user_id,
        nome,
        email,
        telefone,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        'PDV AllImport - Administração',
        'novaradiosystem@outlook.com',
        '(11) 99999-9999',
        NOW(),
        NOW()
    ) RETURNING id INTO v_empresa_id;

    RAISE NOTICE '✅ Empresa criada: %', v_empresa_id;

    -- Criar user_approval (SEM empresa_id)
    INSERT INTO user_approvals (
        id,
        user_id,
        email,
        status,
        user_role,
        approved_at,
        created_at
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        'novaradiosystem@outlook.com',
        'approved',
        'super_admin',
        NOW(),
        NOW()
    );

    RAISE NOTICE '✅ User approval criado';

    RAISE NOTICE '';
    RAISE NOTICE '🎉 ============================================';
    RAISE NOTICE '✅ ADMIN PRINCIPAL CRIADO COM SUCESSO!';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Email: novaradiosystem@outlook.com';
    RAISE NOTICE 'Senha: Admin@2026!PDV';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ IMPORTANTE:';
    RAISE NOTICE '1. Faça login imediatamente';
    RAISE NOTICE '2. ALTERE A SENHA no primeiro acesso';
    RAISE NOTICE '3. Guarde a senha em local seguro';
    RAISE NOTICE '============================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO: %', SQLERRM;
        RAISE EXCEPTION 'Falha ao criar admin principal';
END $$;

-- 3️⃣ Verificar criação completa
SELECT 
    '✅ VERIFICAÇÃO FINAL' as secao,
    u.id as user_id,
    u.email,
    u.email_confirmed_at,
    u.created_at,
    e.id as empresa_id,
    e.nome as empresa_nome,
    ua.status as approval_status,
    ua.user_role,
    CASE 
        WHEN u.id IS NOT NULL 
         AND e.id IS NOT NULL 
         AND ua.id IS NOT NULL 
        THEN '✅ TUDO OK - Pode fazer login!'
        ELSE '❌ Faltando dados'
    END as status_final
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email = 'novaradiosystem@outlook.com';

-- 4️⃣ Verificar identities
SELECT 
    '🔑 IDENTITY' as secao,
    i.provider,
    i.identity_data->>'email' as email,
    i.created_at
FROM auth.identities i
WHERE i.identity_data->>'email' = 'novaradiosystem@outlook.com';

-- =====================================================
-- 📝 INSTRUÇÕES PÓS-CRIAÇÃO
-- =====================================================

/*
🎯 PRÓXIMOS PASSOS:

1. ✅ Execute este SQL no Supabase SQL Editor
2. ✅ Aguarde as mensagens de sucesso
3. ✅ Use as credenciais:
   - Email: novaradiosystem@outlook.com
   - Senha: Admin@2026!PDV

4. 🔐 NO PRIMEIRO LOGIN:
   - Vá em Configurações/Perfil
   - Altere a senha imediatamente
   - Use senha forte (mínimo 12 caracteres)

5. 🚨 SEGURANÇA:
   - Nunca compartilhe essas credenciais
   - Ative 2FA se disponível
   - Guarde em gerenciador de senhas

6. ⚠️ SE DER ERRO DE LOGIN:
   - Limpe cache do navegador (Ctrl+Shift+Del)
   - Tente em aba anônima
   - Verifique Site URL no Supabase Dashboard

7. 📋 PREVENIR PERDA FUTURA:
   - Faça backup das migrations
   - Documente mudanças críticas
   - Teste scripts antes de executar em produção
   - Nunca execute scripts de LIMPEZA_* sem revisar
*/

-- =====================================================
-- 🔍 TROUBLESHOOTING
-- =====================================================

-- Se o usuário já existe mas não consegue logar:
-- SELECT * FROM auth.users WHERE email = 'novaradiosystem@outlook.com';

-- Para resetar senha de usuário existente:
-- UPDATE auth.users 
-- SET encrypted_password = crypt('NovaSenha@2026', gen_salt('bf'))
-- WHERE email = 'novaradiosystem@outlook.com';

-- Para verificar se Site URL está correto:
-- Acesse: Supabase Dashboard > Authentication > URL Configuration
-- Deve ser: https://pdv.gruporaval.com.br (SEM barra no final)
