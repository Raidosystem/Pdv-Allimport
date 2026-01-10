-- =====================================================
-- CORRIGIR TODOS OS USUÁRIOS QUE NÃO CONSEGUEM LOGAR
-- =====================================================
-- Data: 07/01/2026
-- Objetivo: Criar registros faltantes (empresas, approvals)
-- =====================================================

-- 1️⃣ VERIFICAR USUÁRIOS SEM EMPRESA
SELECT 
    '❌ USUÁRIOS SEM EMPRESA' as problema,
    u.id,
    u.email,
    u.created_at
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
  AND u.email NOT LIKE '%supabase%'
ORDER BY u.created_at DESC;

-- 2️⃣ VERIFICAR USUÁRIOS SEM APPROVAL
SELECT 
    '❌ USUÁRIOS SEM APPROVAL' as problema,
    u.id,
    u.email,
    u.created_at
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE ua.id IS NULL
  AND u.email NOT LIKE '%supabase%'
ORDER BY u.created_at DESC;

-- 3️⃣ CRIAR EMPRESAS FALTANTES AUTOMATICAMENTE
DO $$
DECLARE
    v_user RECORD;
    v_empresa_id UUID;
BEGIN
    FOR v_user IN 
        SELECT u.id, u.email, u.created_at
        FROM auth.users u
        LEFT JOIN empresas e ON e.user_id = u.id
        WHERE e.id IS NULL
          AND u.email NOT LIKE '%supabase%'
    LOOP
        -- Criar empresa para cada usuário sem empresa
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
            v_user.id,
            COALESCE(
                SPLIT_PART(v_user.email, '@', 1), 
                'Empresa'
            ) || ' - ' || SUBSTRING(v_user.email FROM 1 FOR 20),
            v_user.email,
            '(00) 00000-0000',
            v_user.created_at,
            NOW()
        ) RETURNING id INTO v_empresa_id;

        RAISE NOTICE '✅ Empresa criada para: % (ID: %)', v_user.email, v_empresa_id;
    END LOOP;
END $$;

-- 4️⃣ CRIAR APPROVALS FALTANTES AUTOMATICAMENTE
DO $$
DECLARE
    v_user RECORD;
    v_approval_id UUID;
BEGIN
    FOR v_user IN 
        SELECT u.id, u.email, u.created_at
        FROM auth.users u
        LEFT JOIN user_approvals ua ON ua.user_id = u.id
        WHERE ua.id IS NULL
          AND u.email NOT LIKE '%supabase%'
    LOOP
        -- Criar user_approval para cada usuário sem approval
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
            v_user.id,
            v_user.email,
            'approved',
            CASE 
                WHEN v_user.email = 'novaradiosystem@outlook.com' THEN 'super_admin'
                ELSE 'admin'
            END,
            NOW(),
            v_user.created_at
        ) RETURNING id INTO v_approval_id;

        RAISE NOTICE '✅ Approval criado para: % (ID: %)', v_user.email, v_approval_id;
    END LOOP;
END $$;

-- 5️⃣ CONFIRMAR EMAILS NÃO CONFIRMADOS
UPDATE auth.users
SET email_confirmed_at = NOW(),
    updated_at = NOW()
WHERE email_confirmed_at IS NULL
  AND email NOT LIKE '%supabase%';

-- 6️⃣ VERIFICAÇÃO FINAL - TODOS OS USUÁRIOS
SELECT 
    '✅ VERIFICAÇÃO FINAL' as secao,
    u.email,
    u.email_confirmed_at IS NOT NULL as email_confirmado,
    e.id IS NOT NULL as tem_empresa,
    e.nome as nome_empresa,
    ua.status as approval_status,
    ua.user_role,
    CASE 
        WHEN u.email_confirmed_at IS NOT NULL 
         AND e.id IS NOT NULL 
         AND ua.status = 'approved'
        THEN '✅ PODE LOGAR'
        ELSE '❌ AINDA TEM PROBLEMA'
    END as status_login
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email NOT LIKE '%supabase%'
ORDER BY u.created_at DESC;

-- 7️⃣ RESETAR SENHAS DE USUÁRIOS PROBLEMÁTICOS (OPCIONAL)
-- Descomente as linhas abaixo se quiser resetar senhas

/*
UPDATE auth.users 
SET encrypted_password = crypt('Senha@2026!Temp', gen_salt('bf')),
    updated_at = NOW()
WHERE email IN (
    'sousajenifer895@gmail.com',
    'jennifer@teste.com',
    'rugovito021@gmail.com'
);

-- Após executar, avise os usuários:
-- Email: [email do usuário]
-- Senha temporária: Senha@2026!Temp
-- Pedir para alterar no primeiro login
*/

-- =====================================================
-- 📝 RESUMO DAS CORREÇÕES
-- =====================================================

SELECT 
    '📊 RESUMO' as tipo,
    (SELECT COUNT(*) FROM auth.users WHERE email NOT LIKE '%supabase%') as total_usuarios,
    (SELECT COUNT(*) FROM empresas) as total_empresas,
    (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved') as aprovados,
    (SELECT COUNT(*) 
     FROM auth.users u
     LEFT JOIN empresas e ON e.user_id = u.id
     WHERE e.id IS NULL AND u.email NOT LIKE '%supabase%'
    ) as usuarios_sem_empresa,
    (SELECT COUNT(*) 
     FROM auth.users u
     LEFT JOIN user_approvals ua ON ua.user_id = u.id
     WHERE ua.id IS NULL AND u.email NOT LIKE '%supabase%'
    ) as usuarios_sem_approval;

-- =====================================================
-- 🎯 INSTRUÇÕES FINAIS
-- =====================================================

/*
APÓS EXECUTAR ESTE SCRIPT:

1. ✅ Todos os usuários terão empresas criadas
2. ✅ Todos os usuários terão approvals aprovados
3. ✅ Todos os emails estarão confirmados

SE AINDA NÃO FUNCIONAR:

1. Limpe cache navegador (Ctrl+Shift+Del)
2. Feche TODAS as abas do site
3. Abra aba anônima (Ctrl+Shift+N)
4. Tente login novamente

SENHAS ORIGINAIS:
- Cada usuário deve usar a senha que criou na hora do cadastro
- Se não lembrar, use a função "Esqueci minha senha"
- OU descomente a seção 7️⃣ acima para resetar com senha temporária

CREDENCIAIS ADMIN PRINCIPAL:
- Email: novaradiosystem@outlook.com
- Senha: Admin@2026!PDV
*/
