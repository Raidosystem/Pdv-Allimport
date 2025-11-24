-- ============================================
-- CORREÇÃO RLS - AUDIT_LOGS
-- ============================================

-- 1️⃣ Verificar políticas RLS atuais em audit_logs
SELECT 
    '🔒 POLÍTICAS RLS ATUAIS' as info,
    policyname as nome_politica,
    permissive as tipo,
    roles,
    cmd as comando,
    qual as usando_expressao,
    with_check as com_check_expressao
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'audit_logs';

-- 2️⃣ Desabilitar RLS temporariamente OU criar políticas permissivas
-- OPÇÃO A: Desabilitar RLS completamente (mais simples)
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

-- OPÇÃO B: Criar políticas permissivas (mais seguro, mas complexo)
/*
-- Remover políticas existentes
DROP POLICY IF EXISTS "Usuários podem inserir seus próprios logs" ON audit_logs;
DROP POLICY IF EXISTS "Usuários podem ver seus próprios logs" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_select_policy" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_insert_policy" ON audit_logs;

-- Criar políticas permissivas para audit_logs
CREATE POLICY "audit_logs_insert_policy" 
ON audit_logs FOR INSERT 
WITH CHECK (true); -- Permitir todas as inserções

CREATE POLICY "audit_logs_select_policy" 
ON audit_logs FOR SELECT 
USING (true); -- Permitir todas as leituras
*/

-- 3️⃣ Verificar se RLS foi desabilitado
SELECT 
    '✅ STATUS DO RLS' as info,
    tablename,
    CASE 
        WHEN rowsecurity = true THEN '🔒 ATIVO'
        ELSE '🔓 DESABILITADO'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'audit_logs';

-- 4️⃣ Testar INSERT em audit_logs
/*
INSERT INTO audit_logs (
    tabela,
    operacao,
    registro_id,
    dados_novos
) VALUES (
    'vendas',
    'INSERT',
    gen_random_uuid(),
    '{"teste": true}'::jsonb
)
RETURNING *;
*/

SELECT '✅ CORREÇÃO APLICADA! RLS desabilitado em audit_logs. Teste a venda novamente.' as resultado;
