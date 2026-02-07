-- 🔓 DAR PERMISSÕES COMPLETAS PARA ACESSO ANÔNIMO À LOJA

-- 1. DESABILITAR RLS temporariamente (para teste)
ALTER TABLE lojas_online DISABLE ROW LEVEL SECURITY;

-- 2. Dar permissão de SELECT para usuários anônimos
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON lojas_online TO anon;
GRANT SELECT ON produtos TO anon;
GRANT SELECT ON categorias TO anon;

-- 3. RE-HABILITAR RLS
ALTER TABLE lojas_online ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas permissivas
DROP POLICY IF EXISTS "public_read_lojas_ativas" ON lojas_online;
CREATE POLICY "public_read_lojas_ativas"
ON lojas_online
FOR SELECT
USING (ativa = true);

DROP POLICY IF EXISTS "public_read_produtos_ativos" ON produtos;
CREATE POLICY "public_read_produtos_ativos"
ON produtos
FOR SELECT
USING (ativo = true);

DROP POLICY IF EXISTS "public_read_categorias" ON categorias;
CREATE POLICY "public_read_categorias"
ON categorias
FOR SELECT
USING (true);

-- 5. Verificar permissões
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name IN ('lojas_online', 'produtos', 'categorias')
AND grantee = 'anon';

-- 6. Verificar políticas
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('lojas_online', 'produtos', 'categorias')
ORDER BY tablename, policyname;

-- 7. Teste final
SELECT COUNT(*) as total_lojas FROM lojas_online WHERE ativa = true;
SELECT COUNT(*) as total_produtos FROM produtos WHERE ativo = true;
