-- SCRIPT PARA CONFIGURAR ADMIN ABSOLUTO
-- Cristiano Ramos Mendes - assistenciaallimport10@gmail.com

DO $$
DECLARE
    admin_email TEXT := 'assistenciaallimport10@gmail.com';
    admin_uuid UUID;
BEGIN
    -- Encontrar o usuário admin
    SELECT id INTO admin_uuid 
    FROM auth.users 
    WHERE email = admin_email;
    
    IF admin_uuid IS NULL THEN
        SELECT id INTO admin_uuid 
        FROM usuarios 
        WHERE email = admin_email;
    END IF;
    
    IF admin_uuid IS NULL THEN
        RAISE EXCEPTION 'Admin % não encontrado!', admin_email;
    END IF;
    
    RAISE NOTICE 'Configurando admin: % (ID: %)', admin_email, admin_uuid;
    
    -- 1. Criar/atualizar assinatura INFINITA para admin
    INSERT INTO user_subscriptions (
        user_id, email, status, access_allowed, has_subscription, 
        days_remaining, created_at, updated_at
    ) VALUES (
        admin_uuid, admin_email, 'active', true, true, 
        9999, -- Dias infinitos para admin
        '2025-01-01'::timestamp, -- Data fixa no passado
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        status = 'active',
        access_allowed = true,
        has_subscription = true,
        days_remaining = 9999, -- Infinito
        created_at = '2025-01-01'::timestamp,
        updated_at = NOW();
    
    -- 2. Criar subscription premium para admin
    INSERT INTO subscriptions (
        user_id, status, plan_type, start_date, end_date,
        payment_method, amount_paid, created_at, updated_at
    ) VALUES (
        admin_uuid, 'active', 'admin_premium', 
        '2025-01-01'::timestamp, 
        '2099-12-31'::timestamp, -- Data muito futura
        'admin_access', 0.00, 
        '2025-01-01'::timestamp, NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        status = 'active',
        plan_type = 'admin_premium',
        start_date = '2025-01-01'::timestamp,
        end_date = '2099-12-31'::timestamp,
        payment_method = 'admin_access',
        amount_paid = 0.00,
        updated_at = NOW();
    
    -- 3. Garantir que admin tem permissões especiais (se existir tabela de permissões)
    INSERT INTO user_permissions (user_id, permission, granted_at)
    VALUES 
        (admin_uuid, 'admin_full_access', NOW()),
        (admin_uuid, 'create_users', NOW()),
        (admin_uuid, 'delete_users', NOW()),
        (admin_uuid, 'manage_subscriptions', NOW()),
        (admin_uuid, 'view_all_data', NOW())
    ON CONFLICT (user_id, permission) DO UPDATE SET
        granted_at = NOW();
    
    RAISE NOTICE 'Admin configurado com sucesso - Acesso INFINITO!';
    
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Erro ao configurar permissões (tabela pode não existir): %', SQLERRM;
        -- Continuar mesmo se a tabela de permissões não existir
END $$;

-- Verificar configuração do admin
SELECT 
    'ADMIN CONFIGURADO' as status,
    us.email,
    us.status,
    us.access_allowed,
    us.has_subscription,
    us.days_remaining as dias_restantes,
    s.plan_type as plano,
    s.end_date::date as expira_em
FROM user_subscriptions us
LEFT JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com';