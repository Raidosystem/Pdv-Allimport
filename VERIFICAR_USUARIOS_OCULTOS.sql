-- ============================================
-- VERIFICAR USUÁRIOS QUE NÃO APARECEM NO ADMIN
-- ============================================

-- 1. Listar TODOS os usuários do auth.users
SELECT 
    '🔍 TODOS OS USUÁRIOS (auth.users)' as categoria,
    au.id as user_id,
    au.email,
    au.created_at as cadastro,
    au.email_confirmed_at as email_confirmado,
    au.last_sign_in_at as ultimo_login,
    CASE 
        WHEN au.deleted_at IS NOT NULL THEN '❌ DELETADO'
        WHEN au.email_confirmed_at IS NULL THEN '⚠️ EMAIL NÃO CONFIRMADO'
        ELSE '✅ ATIVO'
    END as status_auth
FROM auth.users au
ORDER BY au.created_at DESC;

-- 2. Verificar quais têm subscription
SELECT 
    '📊 USUÁRIOS COM SUBSCRIPTION' as categoria,
    s.user_id,
    au.email,
    s.status,
    s.trial_end_date,
    s.subscription_end_date,
    s.created_at
FROM public.subscriptions s
INNER JOIN auth.users au ON au.id = s.user_id
ORDER BY s.created_at DESC;

-- 3. Verificar quais estão no user_approvals
SELECT 
    '✅ USUÁRIOS NO USER_APPROVALS' as categoria,
    ua.user_id,
    ua.email,
    ua.full_name,
    ua.company_name,
    ua.status as approval_status,
    ua.created_at
FROM public.user_approvals ua
ORDER BY ua.created_at DESC;

-- 4. USUÁRIOS SEM SUBSCRIPTION (por isso não aparecem no admin!)
SELECT 
    '❌ USUÁRIOS SEM SUBSCRIPTION (NÃO APARECEM NO ADMIN)' as problema,
    au.id as user_id,
    au.email,
    au.created_at as cadastro,
    au.last_sign_in_at as ultimo_login,
    'Precisa criar subscription' as solucao
FROM auth.users au
LEFT JOIN public.subscriptions s ON s.user_id = au.id
WHERE s.id IS NULL
ORDER BY au.created_at DESC;

-- 5. CRIAR SUBSCRIPTIONS PARA USUÁRIOS QUE NÃO TÊM
-- Execute este bloco para criar subscriptions automáticas
DO $$ 
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN 
        SELECT au.id, au.email 
        FROM auth.users au
        LEFT JOIN public.subscriptions s ON s.user_id = au.id
        WHERE s.id IS NULL 
        AND au.deleted_at IS NULL
    LOOP
        INSERT INTO public.subscriptions (
            user_id,
            email,
            status,
            trial_start_date,
            trial_end_date,
            created_at,
            updated_at
        ) VALUES (
            user_record.id,
            user_record.email,
            'expired', -- Inicia como expirado, admin pode adicionar dias
            NOW(),
            NOW(), -- Já expirado
            NOW(),
            NOW()
        );
        
        RAISE NOTICE '✅ Subscription criada para: %', user_record.email;
    END LOOP;
    
    RAISE NOTICE '🎉 Subscriptions criadas para todos os usuários!';
END $$;

-- 6. Verificar novamente após criação
SELECT 
    '🎉 RESULTADO FINAL - TODOS DEVEM APARECER AGORA' as resultado,
    au.id as user_id,
    au.email,
    s.status as subscription_status,
    CASE 
        WHEN s.trial_end_date > NOW() THEN '🎁 TRIAL ATIVO'
        WHEN s.subscription_end_date > NOW() THEN '⭐ PREMIUM ATIVO'
        ELSE '❌ EXPIRADO (Admin pode adicionar dias)'
    END as situacao
FROM auth.users au
INNER JOIN public.subscriptions s ON s.user_id = au.id
WHERE au.deleted_at IS NULL
ORDER BY au.created_at DESC;
