-- =====================================================
-- VERIFICAR E PREVENIR RECURSÃO EM TODAS AS TABELAS
-- =====================================================

-- 📋 LISTA DE TABELAS QUE NUNCA DEVEM CAUSAR RECURSÃO:
-- 1. permissoes (tabela de metadados)
-- 2. funcoes (tabela de metadados)
-- 3. empresas (tabela base para verificação de admin)

-- 🔍 PASSO 1: Verificar todas as políticas que referenciam a tabela permissoes
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd AS comando,
  CASE 
    WHEN qual::text LIKE '%permissoes%' OR with_check::text LIKE '%permissoes%' 
    THEN '⚠️ PODE CAUSAR RECURSÃO'
    ELSE '✅ OK'
  END AS status,
  qual::text AS condicao_using,
  with_check::text AS condicao_check
FROM pg_policies
WHERE schemaname = 'public'
  AND (qual::text LIKE '%permissoes%' OR with_check::text LIKE '%permissoes%')
  AND tablename != 'permissoes'
ORDER BY tablename, policyname;

-- 🔧 PASSO 2: Corrigir tabela FUNCOES (se necessário)
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes CASCADE;

ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;

-- SELECT: Todos podem ver funções da sua empresa
CREATE POLICY "funcoes_select_empresa"
ON funcoes
FOR SELECT
TO authenticated
USING (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
    UNION
    SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
  )
);

-- INSERT/UPDATE/DELETE: Apenas admins
CREATE POLICY "funcoes_write_admin"
ON funcoes
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
);

-- 🔧 PASSO 3: Corrigir tabela FUNCIONARIOS_FUNCOES
DROP POLICY IF EXISTS "funcionarios_funcoes_select" ON funcionarios_funcoes CASCADE;
DROP POLICY IF EXISTS "funcionarios_funcoes_write" ON funcionarios_funcoes CASCADE;

ALTER TABLE funcionarios_funcoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "funcionarios_funcoes_select_empresa"
ON funcionarios_funcoes
FOR SELECT
TO authenticated
USING (
  funcionario_id IN (
    SELECT id FROM funcionarios 
    WHERE empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
      UNION
      SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
  )
);

CREATE POLICY "funcionarios_funcoes_write_admin"
ON funcionarios_funcoes
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
);

-- 🔧 PASSO 4: Corrigir tabela FUNCOES_PERMISSOES
DROP POLICY IF EXISTS "funcoes_permissoes_select" ON funcoes_permissoes CASCADE;
DROP POLICY IF EXISTS "funcoes_permissoes_write" ON funcoes_permissoes CASCADE;

ALTER TABLE funcoes_permissoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "funcoes_permissoes_select_empresa"
ON funcoes_permissoes
FOR SELECT
TO authenticated
USING (
  funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
      UNION
      SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
  )
);

CREATE POLICY "funcoes_permissoes_write_admin"
ON funcoes_permissoes
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM empresas WHERE empresas.user_id = auth.uid()
  )
);

-- ✅ PASSO 5: Verificar resultado final
SELECT 
  'permissoes' as tabela,
  COUNT(*) as total_policies,
  STRING_AGG(policyname, ', ') as nomes
FROM pg_policies 
WHERE tablename = 'permissoes'
UNION ALL
SELECT 
  'funcoes' as tabela,
  COUNT(*) as total_policies,
  STRING_AGG(policyname, ', ') as nomes
FROM pg_policies 
WHERE tablename = 'funcoes'
UNION ALL
SELECT 
  'funcionarios_funcoes' as tabela,
  COUNT(*) as total_policies,
  STRING_AGG(policyname, ', ') as nomes
FROM pg_policies 
WHERE tablename = 'funcionarios_funcoes'
UNION ALL
SELECT 
  'funcoes_permissoes' as tabela,
  COUNT(*) as total_policies,
  STRING_AGG(policyname, ', ') as nomes
FROM pg_policies 
WHERE tablename = 'funcoes_permissoes';

-- 🎯 PASSO 6: Teste de recursão
-- Este SELECT deve funcionar SEM erro 42P17
SELECT 
  p.recurso,
  p.acao,
  p.descricao,
  COUNT(fp.funcao_id) as funcoes_usando
FROM permissoes p
LEFT JOIN funcoes_permissoes fp ON fp.permissao_id = p.id
GROUP BY p.id, p.recurso, p.acao, p.descricao
ORDER BY p.categoria, p.recurso, p.acao;

COMMIT;
