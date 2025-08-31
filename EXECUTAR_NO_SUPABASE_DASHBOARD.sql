-- =========================================================================
-- BLOQUEIO DEFINITIVO RLS - EXECUTAR NO SUPABASE DASHBOARD
-- PROBLEMA: Dados ainda visíveis para outros usuários
-- SOLUÇÃO: Configuração manual super restritiva
-- =========================================================================

-- PASSO 1: DESABILITAR RLS PARA LIMPEZA
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

-- PASSO 2: REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "isolamento_clientes" ON clientes CASCADE;
DROP POLICY IF EXISTS "isolamento_produtos" ON produtos CASCADE;
DROP POLICY IF EXISTS "clientes_acesso_proprio" ON clientes CASCADE;
DROP POLICY IF EXISTS "produtos_acesso_proprio" ON produtos CASCADE;
DROP POLICY IF EXISTS "clientes_auth_only" ON clientes CASCADE;
DROP POLICY IF EXISTS "produtos_auth_only" ON produtos CASCADE;

-- PASSO 3: REMOVER COMPLETAMENTE PERMISSÕES ANÔNIMAS
REVOKE ALL ON clientes FROM anon;
REVOKE ALL ON produtos FROM anon;
REVOKE ALL ON clientes FROM public;
REVOKE ALL ON produtos FROM public;

-- PASSO 4: CONCEDER APENAS PARA USUÁRIOS AUTENTICADOS
GRANT SELECT, INSERT, UPDATE, DELETE ON clientes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO authenticated;

-- PASSO 5: CRIAR POLÍTICAS SUPER RESTRITIVAS
CREATE POLICY "clientes_usuario_logado" ON clientes
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "produtos_usuario_logado" ON produtos
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- PASSO 6: ATIVAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- PASSO 7: VERIFICAÇÃO
SELECT 
    'POLÍTICAS ATIVAS' as status,
    tablename, 
    policyname,
    roles
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos');

SELECT 
    'RLS STATUS' as status,
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('clientes', 'produtos');

-- =========================================================================
-- INSTRUÇÕES PARA EXECUÇÃO:
-- 1. Abrir: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
-- 2. Ir em: SQL Editor
-- 3. Colar este script completo
-- 4. Executar (botão RUN)
-- 5. Verificar se aparece "SUCCESS" sem erros
-- 6. Testar sistema: http://localhost:5174
-- =========================================================================
