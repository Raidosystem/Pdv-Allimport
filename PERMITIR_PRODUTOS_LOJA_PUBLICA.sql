-- 🛍️ PERMITIR ACESSO ANÔNIMO AOS PRODUTOS DA LOJA ONLINE

-- 1. Dar permissão GRANT para anon na tabela produtos
GRANT SELECT ON produtos TO anon;

-- 2. Dropar política antiga se existir
DROP POLICY IF EXISTS "public_read_produtos_ativos" ON produtos;

-- 3. Criar política PERMISSIVA para produtos de lojas ativas
-- Permite ler produtos que pertencem a uma empresa com loja online ativa
CREATE POLICY "public_read_produtos_loja_online"
ON produtos
FOR SELECT
USING (
  ativo = true 
  AND EXISTS (
    SELECT 1 FROM lojas_online 
    WHERE lojas_online.empresa_id IN (produtos.empresa_id, produtos.user_id)
    AND lojas_online.ativa = true
  )
);

-- 4. Verificar política criada
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'produtos'
AND policyname = 'public_read_produtos_loja_online';

-- 5. Teste: Buscar produtos da loja Allimport como anônimo
-- (Simula o que o frontend faz)
SELECT COUNT(*) as total_produtos_loja
FROM produtos
WHERE ativo = true
AND EXISTS (
  SELECT 1 FROM lojas_online 
  WHERE lojas_online.slug = 'loja-allimport'
  AND lojas_online.ativa = true
  AND lojas_online.empresa_id IN (produtos.empresa_id, produtos.user_id)
);

-- 6. Verificar estrutura da tabela produtos (empresa_id vs user_id)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'produtos'
AND column_name IN ('empresa_id', 'user_id')
ORDER BY column_name;
