-- =====================================================
-- 🚨 CORREÇÃO FINAL AGRESSIVA - RLS FORNECEDORES
-- =====================================================
-- Políticas anteriores falharam. Aplicando correção radical.
-- =====================================================

-- 1️⃣ DESABILITAR E REABILITAR RLS PARA RESET COMPLETO
ALTER TABLE fornecedores DISABLE ROW LEVEL SECURITY;

-- 2️⃣ REMOVER ABSOLUTAMENTE TODAS AS POLÍTICAS
DO $$
DECLARE
    pol_name TEXT;
BEGIN
    FOR pol_name IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'fornecedores'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(pol_name) || ' ON fornecedores';
    END LOOP;
END $$;

-- 3️⃣ REABILITAR RLS
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

-- 4️⃣ CRIAR POLÍTICA ULTRA RESTRITIVA PARA SELECT
CREATE POLICY fornecedores_strict_select ON fornecedores
  FOR SELECT TO authenticated
  USING (
    empresa_id = (
      SELECT e.id 
      FROM empresas e 
      WHERE e.user_id = auth.uid() 
      LIMIT 1
    )
  );

-- 5️⃣ CRIAR POLÍTICA ULTRA RESTRITIVA PARA INSERT
CREATE POLICY fornecedores_strict_insert ON fornecedores
  FOR INSERT TO authenticated
  WITH CHECK (
    empresa_id = (
      SELECT e.id 
      FROM empresas e 
      WHERE e.user_id = auth.uid() 
      LIMIT 1
    )
  );

-- 6️⃣ CRIAR POLÍTICA ULTRA RESTRITIVA PARA UPDATE
CREATE POLICY fornecedores_strict_update ON fornecedores
  FOR UPDATE TO authenticated
  USING (
    empresa_id = (
      SELECT e.id 
      FROM empresas e 
      WHERE e.user_id = auth.uid() 
      LIMIT 1
    )
  )
  WITH CHECK (
    empresa_id = (
      SELECT e.id 
      FROM empresas e 
      WHERE e.user_id = auth.uid() 
      LIMIT 1
    )
  );

-- 7️⃣ CRIAR POLÍTICA ULTRA RESTRITIVA PARA DELETE
CREATE POLICY fornecedores_strict_delete ON fornecedores
  FOR DELETE TO authenticated
  USING (
    empresa_id = (
      SELECT e.id 
      FROM empresas e 
      WHERE e.user_id = auth.uid() 
      LIMIT 1
    )
  );

-- 8️⃣ TESTE IMEDIATO APÓS RESET
SELECT 
  'TESTE_FINAL' as teste,
  auth.uid() as meu_user_id,
  COUNT(*) as fornecedores_visiveis
FROM fornecedores;

-- 9️⃣ VERIFICAR QUAL É MINHA EMPRESA
SELECT 
  'MINHA_EMPRESA' as teste,
  auth.uid() as meu_user_id,
  e.id as minha_empresa_id,
  e.nome as minha_empresa_nome
FROM empresas e
WHERE e.user_id = auth.uid();

-- 🔟 VERIFICAR SE MAXECELL AINDA APARECE
SELECT 
  'TESTE_MAXECELL' as teste,
  f.nome,
  f.empresa_id,
  CASE 
    WHEN f.empresa_id = (SELECT id FROM empresas WHERE user_id = auth.uid()) 
    THEN 'DEVERIA_VER' 
    ELSE 'NAO_DEVERIA_VER' 
  END as status
FROM fornecedores f
WHERE f.nome ILIKE '%maxecell%';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ fornecedores_visiveis deve ser 0 para cris-ramos30@hotmail.com
-- ✅ TESTE_MAXECELL deve retornar vazio ou NAO_DEVERIA_VER
-- ✅ Sistema deve estar finalmente isolado
-- =====================================================