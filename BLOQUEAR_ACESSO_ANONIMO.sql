-- SCRIPT DIRETO PARA BLOQUEAR ACESSO ANÔNIMO
-- Aplicar isolamento real multi-tenant

-- 1. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "clientes_isolamento_simples" ON clientes CASCADE;
DROP POLICY IF EXISTS "produtos_isolamento_simples" ON produtos CASCADE;
DROP POLICY IF EXISTS "clientes_usuario_autenticado" ON clientes CASCADE;
DROP POLICY IF EXISTS "produtos_usuario_autenticado" ON produtos CASCADE;

-- 2. GARANTIR QUE RLS ESTÁ ATIVADO
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- 3. REMOVER TODAS AS PERMISSÕES DE USUÁRIOS ANÔNIMOS
REVOKE ALL ON clientes FROM anon;
REVOKE ALL ON produtos FROM anon;
REVOKE ALL ON clientes FROM public;
REVOKE ALL ON produtos FROM public;

-- 4. CONCEDER ACESSO APENAS PARA USUÁRIOS AUTENTICADOS
GRANT SELECT, INSERT, UPDATE, DELETE ON clientes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON produtos TO authenticated;

-- 5. CRIAR POLÍTICAS SIMPLES E EFETIVAS
CREATE POLICY "clientes_acesso_proprio" ON clientes
    FOR ALL TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "produtos_acesso_proprio" ON produtos  
    FOR ALL TO authenticated
    USING (user_id = auth.uid());

-- 6. VERIFICAR RESULTADOS
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos');
