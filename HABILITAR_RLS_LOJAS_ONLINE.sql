-- 🔍 VERIFICAR E HABILITAR RLS NA TABELA lojas_online

-- 1. Verificar se RLS está habilitado
SELECT 
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'lojas_online';

-- 2. HABILITAR RLS se não estiver
ALTER TABLE lojas_online ENABLE ROW LEVEL SECURITY;

-- 3. Dropar TODAS as políticas existentes
DROP POLICY IF EXISTS "Acesso público a lojas ativas" ON lojas_online;
DROP POLICY IF EXISTS "Enable read access for all users" ON lojas_online;
DROP POLICY IF EXISTS "Users can view their own stores" ON lojas_online;

-- 4. Criar política PERMISSIVA para acesso público
CREATE POLICY "public_read_lojas_ativas"
ON lojas_online
AS PERMISSIVE
FOR SELECT
TO PUBLIC
USING (ativa = true);

-- 5. Verificar políticas criadas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'lojas_online';

-- 6. Testar acesso como anônimo
SET ROLE anon;
SELECT COUNT(*) FROM lojas_online WHERE ativa = true;
SELECT * FROM lojas_online WHERE slug = 'loja-allimport' LIMIT 1;
RESET ROLE;
