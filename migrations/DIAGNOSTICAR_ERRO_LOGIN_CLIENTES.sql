-- =====================================================
-- 🔍 DIAGNÓSTICO COMPLETO: ERRO DE LOGIN DE CLIENTES
-- =====================================================
-- Data: 07/01/2026
-- Objetivo: Identificar por que clientes não conseguem fazer login
-- Execute no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR RLS EM AUTH.USERS (CRÍTICO!)
-- =====================================================
-- ⚠️ RLS NÃO deve estar habilitado em auth.users!

SELECT 
    '🔒 VERIFICAÇÃO DE RLS' as secao,
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity THEN '❌ RLS HABILITADO (PROBLEMA!)'
        ELSE '✅ RLS DESABILITADO (OK)'
    END as status_rls
FROM pg_tables
WHERE schemaname = 'auth' 
  AND tablename = 'users';

-- Se aparecer "RLS HABILITADO", execute IMEDIATAMENTE:
-- ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2️⃣ LISTAR TODOS OS USUÁRIOS E STATUS
-- =====================================================

SELECT 
    '👥 USUÁRIOS CADASTRADOS' as secao,
    u.email,
    u.created_at,
    u.last_sign_in_at,
    u.email_confirmed_at,
    u.banned_until,
    CASE 
        WHEN u.banned_until IS NOT NULL AND u.banned_until > NOW() THEN '🚫 BLOQUEADO'
        WHEN u.email_confirmed_at IS NULL THEN '⚠️ Email não confirmado'
        WHEN u.last_sign_in_at IS NULL THEN '🆕 Nunca fez login'
        WHEN u.last_sign_in_at < NOW() - INTERVAL '30 days' THEN '⏰ Login antigo (30+ dias)'
        ELSE '✅ Ativo e funcionando'
    END as status,
    CASE 
        WHEN e.id IS NOT NULL THEN '✅ Tem empresa'
        ELSE '❌ SEM empresa'
    END as tem_empresa
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE u.email NOT LIKE '%supabase%' -- Filtrar usuários do sistema
ORDER BY u.created_at DESC;

-- =====================================================
-- 3️⃣ VERIFICAR USUÁRIOS SEM EMAIL CONFIRMADO
-- =====================================================

SELECT 
    '📧 EMAILS NÃO CONFIRMADOS' as secao,
    email,
    created_at,
    confirmation_sent_at,
    EXTRACT(DAY FROM NOW() - created_at) as dias_desde_criacao
FROM auth.users
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;

-- SOLUÇÃO: Confirmar emails manualmente se necessário
-- UPDATE auth.users SET email_confirmed_at = NOW() WHERE email_confirmed_at IS NULL;

-- =====================================================
-- 4️⃣ VERIFICAR CORRELAÇÃO COM TABELA EMPRESAS
-- =====================================================

SELECT 
    '🏢 EMPRESAS vs AUTH.USERS' as secao,
    u.email as email_usuario,
    e.nome as nome_empresa,
    e.email as email_empresa,
    CASE 
        WHEN e.id IS NULL THEN '❌ Empresa não criada'
        WHEN e.user_id IS NULL THEN '⚠️ Empresa sem user_id'
        WHEN e.user_id != u.id THEN '❌ User_id incorreto'
        ELSE '✅ Tudo OK'
    END as status_correlacao
FROM auth.users u
FULL OUTER JOIN empresas e ON e.user_id = u.id
WHERE u.email NOT LIKE '%supabase%'
   OR e.id IS NOT NULL
ORDER BY u.created_at DESC NULLS LAST;

-- =====================================================
-- 5️⃣ VERIFICAR SESSÕES ANTIGAS/CORROMPIDAS
-- =====================================================

SELECT 
    '🔑 SESSÕES ATIVAS' as secao,
    COUNT(*) as total_sessoes,
    COUNT(*) FILTER (WHERE created_at < NOW() - INTERVAL '7 days') as sessoes_antigas,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '24 hours') as sessoes_recentes
FROM auth.sessions;

-- LIMPEZA SEGURA: Remover sessões antigas
-- DELETE FROM auth.sessions WHERE created_at < NOW() - INTERVAL '7 days';
-- DELETE FROM auth.refresh_tokens WHERE created_at < NOW() - INTERVAL '7 days';

-- =====================================================
-- 6️⃣ VERIFICAR SITE URL (via Dashboard)
-- =====================================================
-- ⚠️ VERIFICAÇÃO MANUAL NECESSÁRIA:
-- 1. Acesse: Supabase Dashboard > Authentication > URL Configuration
-- 2. Verifique se o SITE_URL está SEM barra no final
-- 3. Exemplo correto: https://pdv.gruporaval.com.br (SEM /)
-- 4. Exemplo errado: https://pdv.gruporaval.com.br/

SELECT '⚠️ VERIFICAR MANUALMENTE NO DASHBOARD:' as info,
       'Authentication > URL Configuration' as onde,
       'Site URL deve estar SEM barra no final' as o_que_verificar;

-- =====================================================
-- 7️⃣ VERIFICAR USER_APPROVALS (SISTEMA MULTI-TENANT)
-- =====================================================

SELECT 
    '✅ USER APPROVALS' as secao,
    ua.email,
    ua.status,
    ua.user_role,
    ua.created_at,
    ua.approved_at,
    CASE 
        WHEN ua.status = 'pending' THEN '⏳ Aguardando aprovação'
        WHEN ua.status = 'approved' THEN '✅ Aprovado'
        WHEN ua.status = 'rejected' THEN '❌ Rejeitado'
        ELSE '❓ Status desconhecido'
    END as status_descricao
FROM user_approvals ua
ORDER BY ua.created_at DESC
LIMIT 20;

-- =====================================================
-- 8️⃣ VERIFICAR TRIGGERS QUE PODEM AFETAR AUTH
-- =====================================================

SELECT 
    '🔔 TRIGGERS NO SCHEMA AUTH' as secao,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'auth'
ORDER BY trigger_name;

-- ⚠️ Se houver triggers customizados em auth.users, podem estar causando o problema!

-- =====================================================
-- ✅ RESUMO E RECOMENDAÇÕES
-- =====================================================

SELECT 
    '📊 RESUMO GERAL' as secao,
    (SELECT COUNT(*) FROM auth.users) as total_usuarios,
    (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NULL) as sem_confirmacao,
    (SELECT COUNT(*) FROM auth.users WHERE last_sign_in_at IS NULL) as nunca_logaram,
    (SELECT COUNT(*) FROM empresas) as total_empresas,
    (SELECT COUNT(*) FROM auth.sessions) as sessoes_ativas;

-- =====================================================
-- 🔧 SOLUÇÕES RÁPIDAS
-- =====================================================

-- ✅ SOLUÇÃO 1: Desabilitar RLS em auth.users (se estiver habilitado)
-- ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;

-- ✅ SOLUÇÃO 2: Confirmar todos os emails pendentes
-- UPDATE auth.users 
-- SET email_confirmed_at = NOW()
-- WHERE email_confirmed_at IS NULL;

-- ✅ SOLUÇÃO 3: Limpar sessões antigas
-- DELETE FROM auth.sessions WHERE created_at < NOW() - INTERVAL '7 days';
-- DELETE FROM auth.refresh_tokens WHERE created_at < NOW() - INTERVAL '7 days';

-- ✅ SOLUÇÃO 4: Verificar Site URL (sem barra no final)
-- Via Dashboard: Authentication > URL Configuration
-- Deve ser: https://pdv.gruporaval.com.br (SEM /)

-- ✅ SOLUÇÃO 5: Resetar senha de cliente específico
-- Use no frontend: supabase.auth.resetPasswordForEmail('email@cliente.com')

-- =====================================================
-- 📝 NOTAS FINAIS
-- =====================================================

/*
🎯 CAUSAS MAIS COMUNS DE ERRO DE LOGIN:

1. ❌ Site URL com barra no final (mais comum!)
2. ❌ RLS habilitado em auth.users (crítico!)
3. ❌ Email não confirmado
4. ❌ Sessões corrompidas (cache navegador)
5. ❌ Trigger modificando auth.users incorretamente
6. ❌ Senha alterada/resetada por engano

📋 CHECKLIST DE VERIFICAÇÃO:

- [ ] RLS desabilitado em auth.users
- [ ] Site URL sem barra no final
- [ ] Emails confirmados
- [ ] Sessões antigas limpas
- [ ] Empresas correlacionadas corretamente
- [ ] Sem triggers problemáticos em auth.users

🚨 EMERGÊNCIA: Reset de senha do cliente
Se nada funcionar, use o email recovery do Supabase:
- Frontend: supabase.auth.resetPasswordForEmail()
- Admin API: supabase.auth.admin.updateUserById()
*/

-- =====================================================
-- 🎯 TESTE FINAL: Login de um usuário específico
-- =====================================================

-- Substituir o email pelo cliente com problema:
-- SELECT 
--     u.email,
--     u.email_confirmed_at,
--     u.last_sign_in_at,
--     u.banned_until,
--     e.nome as nome_empresa,
--     ua.status as status_aprovacao,
--     CASE 
--         WHEN u.banned_until IS NOT NULL AND u.banned_until > NOW() THEN '❌ BLOQUEADO'
--         WHEN u.email_confirmed_at IS NULL THEN '⚠️ Confirmar email primeiro'
--         WHEN e.id IS NULL THEN '⚠️ Criar registro de empresa'
--         WHEN ua.status != 'approved' THEN '⚠️ Aprovar usuário'
--         ELSE '✅ Tudo OK - Testar reset de senha'
--     END as diagnostico_final
-- FROM auth.users u
-- LEFT JOIN empresas e ON e.user_id = u.id
-- LEFT JOIN user_approvals ua ON ua.user_id = u.id
-- WHERE u.email = 'email_do_cliente@example.com'; -- SUBSTITUIR AQUI
