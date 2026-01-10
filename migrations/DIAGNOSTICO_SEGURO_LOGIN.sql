-- ====================================================================
-- 🔍 DIAGNÓSTICO SEGURO DE LOGIN - NÃO ALTERA NADA
-- ====================================================================
-- Este script APENAS diagnostica problemas
-- NÃO remove políticas
-- NÃO desabilita RLS
-- NÃO altera nada que já está funcionando
-- ====================================================================

-- ✅ PASSO 1: Verificar status atual do RLS
SELECT 
    '🔒 STATUS RLS' as info,
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('subscriptions', 'user_approvals', 'empresas', 'funcionarios', 'clientes', 'produtos')
ORDER BY tablename;

-- ✅ PASSO 2: Listar TODAS as políticas atuais (NÃO remove nada)
SELECT 
    '📋 POLÍTICAS ATUAIS' as info,
    tablename,
    policyname,
    cmd as tipo_comando,
    CASE 
        WHEN qual IS NOT NULL THEN 'Tem condição USING'
        ELSE 'Sem condição'
    END as tem_condicao,
    CASE 
        WHEN with_check IS NOT NULL THEN 'Tem condição WITH CHECK'
        ELSE 'Sem condição'
    END as tem_check
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- ✅ PASSO 3: Verificar usuários em auth.users
SELECT 
    '👥 USUÁRIOS NO AUTH' as info,
    u.email,
    u.email_confirmed_at IS NOT NULL as email_confirmado,
    u.created_at as data_criacao,
    CASE 
        WHEN u.email = 'novaradiosystem@outlook.com' THEN '🔑 SUPER ADMIN'
        ELSE '👤 Usuário Normal'
    END as tipo
FROM auth.users u
WHERE u.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
ORDER BY 
    CASE WHEN u.email = 'novaradiosystem@outlook.com' THEN 0 ELSE 1 END,
    u.email;

-- ✅ PASSO 4: Verificar usuários em user_approvals
SELECT 
    '✅ STATUS EM USER_APPROVALS' as info,
    ua.email,
    ua.status as status_aprovacao,
    ua.user_role as funcao,
    ua.approved_at IS NOT NULL as foi_aprovado,
    ua.created_at as data_criacao
FROM user_approvals ua
WHERE ua.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
ORDER BY 
    CASE WHEN ua.email = 'novaradiosystem@outlook.com' THEN 0 ELSE 1 END,
    ua.email;

-- ✅ PASSO 5: Verificar usuários em subscriptions
SELECT 
    '💳 SUBSCRIPTIONS' as info,
    s.email,
    s.status as status_sub,
    s.plan_type as plano,
    s.subscription_end_date as data_fim,
    CASE 
        WHEN s.subscription_end_date > NOW() THEN 
            CONCAT(EXTRACT(DAY FROM (s.subscription_end_date - NOW())), ' dias restantes')
        WHEN s.trial_end_date > NOW() THEN 
            CONCAT(EXTRACT(DAY FROM (s.trial_end_date - NOW())), ' dias trial')
        ELSE 'Expirado'
    END as tempo_restante
FROM subscriptions s
WHERE s.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
ORDER BY 
    CASE WHEN s.email = 'novaradiosystem@outlook.com' THEN 0 ELSE 1 END,
    s.email;

-- ✅ PASSO 6: Verificar funções RPC existentes
SELECT 
    '⚙️ FUNÇÕES RPC' as info,
    routine_name as funcao,
    routine_type as tipo,
    CASE 
        WHEN security_type = 'DEFINER' THEN '🔐 SECURITY DEFINER (bypass RLS)'
        ELSE '👤 SECURITY INVOKER (usa RLS)'
    END as seguranca
FROM information_schema.routines 
WHERE routine_schema = 'public'
AND routine_name IN (
    'check_subscription_status',
    'get_admin_subscribers',
    'get_all_empresas_admin',
    'get_all_subscriptions_admin'
)
ORDER BY routine_name;

-- ✅ PASSO 7: Verificar CRUZAMENTO completo (quem está onde)
SELECT 
    '🔗 ANÁLISE CRUZADA' as info,
    u.email,
    CASE WHEN u.id IS NOT NULL THEN '✅' ELSE '❌' END as tem_em_auth,
    CASE WHEN ua.user_id IS NOT NULL THEN '✅' ELSE '❌' END as tem_em_approvals,
    CASE WHEN s.user_id IS NOT NULL THEN '✅' ELSE '❌' END as tem_em_subscriptions,
    CASE WHEN e.user_id IS NOT NULL THEN '✅' ELSE '❌' END as tem_em_empresas,
    ua.status as status_approval,
    s.status as status_subscription
FROM auth.users u
FULL OUTER JOIN user_approvals ua ON ua.user_id = u.id
FULL OUTER JOIN subscriptions s ON s.user_id = u.id
FULL OUTER JOIN empresas e ON e.user_id = u.id
WHERE u.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
OR ua.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
ORDER BY u.email;

-- ✅ PASSO 8: Identificar usuários que NÃO conseguem logar
SELECT 
    '⚠️ POSSÍVEIS PROBLEMAS' as alerta,
    u.email,
    CASE 
        WHEN ua.user_id IS NULL THEN '❌ Não está em user_approvals'
        WHEN ua.status != 'approved' THEN '❌ Status não é approved: ' || ua.status
        WHEN u.email_confirmed_at IS NULL THEN '⚠️ Email não confirmado'
        ELSE '✅ Tudo OK'
    END as problema
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email IN (
    'novaradiosystem@outlook.com',
    'gruporaval1001@gmail.com',
    'marcellocattani@gmail.com',
    'josefernando@grupocattanisl.com.br',
    'geraldo.silveira@gmail.com',
    'jennifer.ramos.ferreira@hotmail.com'
)
ORDER BY 
    CASE 
        WHEN ua.user_id IS NULL THEN 0
        WHEN ua.status != 'approved' THEN 1
        WHEN u.email_confirmed_at IS NULL THEN 2
        ELSE 3
    END,
    u.email;

-- ====================================================================
-- 📋 ANÁLISE DOS RESULTADOS
-- ====================================================================
/*
Execute este script e analise os resultados:

🔍 VERIFICAR:

1. **STATUS RLS** - Todas as tabelas devem ter rls_habilitado = true
   Se alguma estiver false, RLS está desabilitado (RISCO!)

2. **POLÍTICAS ATUAIS** - Veja quais políticas existem
   NÃO remova políticas que estão funcionando!

3. **USUÁRIOS NO AUTH** - Todos devem ter email_confirmado = true
   Se false, usuário não pode fazer login

4. **STATUS EM USER_APPROVALS** - Todos devem ter:
   - status_aprovacao = 'approved'
   - foi_aprovado = true
   Se não estiverem, adicione manualmente

5. **SUBSCRIPTIONS** - Verificar se tem subscription ativa
   Super admin não precisa, outros usuários sim

6. **FUNÇÕES RPC** - Devem existir 4 funções
   Se não existirem, AdminDashboard não funciona

7. **ANÁLISE CRUZADA** - Todos devem ter ✅ nas 4 colunas
   Se tiver ❌, usuário tem dados faltando

8. **POSSÍVEIS PROBLEMAS** - Mostra o que está impedindo login
   Corrija um por um baseado no problema identificado

🎯 PRÓXIMOS PASSOS:

Baseado nos resultados, crie um SQL ESPECÍFICO que:
- Adiciona apenas o que está faltando
- NÃO remove políticas existentes
- NÃO desabilita RLS
- NÃO altera dados que já funcionam

⚠️ IMPORTANTE:
NÃO execute scripts genéricos que removem todas as políticas!
Isso vai quebrar o que já está funcionando!
*/
