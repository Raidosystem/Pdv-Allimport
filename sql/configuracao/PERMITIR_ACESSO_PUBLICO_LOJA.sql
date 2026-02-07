-- 🔓 PERMITIR ACESSO PÚBLICO À LOJA ONLINE

-- 1. Verificar RLS atual da tabela lojas_online
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'lojas_online';

-- 2. Criar política de leitura pública para lojas ativas
DROP POLICY IF EXISTS "Acesso público a lojas ativas" ON lojas_online;
CREATE POLICY "Acesso público a lojas ativas"
ON lojas_online
FOR SELECT
TO anon, authenticated
USING (ativa = true);

-- 3. Verificar RLS da tabela produtos
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'produtos';

-- 4. Criar política de leitura pública para produtos ativos
-- Produtos podem ser acessados publicamente se a loja estiver ativa
DROP POLICY IF EXISTS "Acesso público a produtos de lojas ativas" ON produtos;
CREATE POLICY "Acesso público a produtos de lojas ativas"
ON produtos
FOR SELECT
TO anon, authenticated
USING (
    ativo = true
    AND EXISTS (
        SELECT 1 
        FROM lojas_online 
        WHERE lojas_online.ativa = true 
        AND lojas_online.empresa_id = produtos.user_id
    )
);

-- 5. Verificar política de categorias (para o join)
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'categorias';

-- 6. Permitir leitura pública de categorias (se necessário)
DROP POLICY IF EXISTS "Acesso público a categorias" ON categorias;
CREATE POLICY "Acesso público a categorias"
ON categorias
FOR SELECT
TO anon, authenticated
USING (true);

-- 7. Testar acesso
SELECT COUNT(*) FROM lojas_online WHERE ativa = true;
SELECT COUNT(*) FROM produtos WHERE ativo = true LIMIT 10;
