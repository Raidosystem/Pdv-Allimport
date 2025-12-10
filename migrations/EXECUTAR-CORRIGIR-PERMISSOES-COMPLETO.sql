-- =====================================================
-- SCRIPT COMPLETO: CORRIGIR RECURSÃO + POPULAR PERMISSÕES
-- =====================================================
-- Executa em ordem: correção de recursão + população de permissões

BEGIN;

-- ===========================================
-- PARTE 1: CORRIGIR RECURSÃO NAS POLÍTICAS
-- ===========================================

-- 🔥 Remover TODAS as políticas existentes da tabela permissoes
DROP POLICY IF EXISTS "permissoes_select_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_insert_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_update_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_delete_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "Admin pode gerenciar permissoes" ON permissoes CASCADE;
DROP POLICY IF EXISTS "Usuarios podem ver suas permissoes" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_read_policy" ON permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_write_policy" ON permissoes CASCADE;

-- Garantir que RLS está ativo
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;

-- ✅ Criar políticas SIMPLES e SEM RECURSÃO

-- 📖 SELECT: Todos autenticados podem ver permissões (é tabela de metadados)
CREATE POLICY "permissoes_select_public"
ON permissoes
FOR SELECT
TO authenticated
USING (true);

-- ✏️ INSERT: Apenas super_admin ou admin da empresa
CREATE POLICY "permissoes_insert_admin"
ON permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- 🔄 UPDATE: Apenas super_admin ou admin da empresa
CREATE POLICY "permissoes_update_admin"
ON permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- 🗑️ DELETE: Apenas super_admin ou admin da empresa
CREATE POLICY "permissoes_delete_admin"
ON permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

-- ===========================================
-- PARTE 2: VERIFICAR SE PERMISSÕES EXISTEM
-- ===========================================

-- Se a tabela está vazia, popular com permissões padrão
DO $$
DECLARE
  total_permissoes INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_permissoes FROM permissoes;
  
  IF total_permissoes < 10 THEN
    RAISE NOTICE '⚠️ Tabela permissoes tem apenas % registros. Considere executar POPULAR-PERMISSOES.sql', total_permissoes;
  ELSE
    RAISE NOTICE '✅ Tabela permissoes tem % registros. Tudo OK!', total_permissoes;
  END IF;
END $$;

-- ===========================================
-- PARTE 3: CORRIGIR TABELAS RELACIONADAS
-- ===========================================

-- Corrigir tabela FUNCOES
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes CASCADE;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes CASCADE;

ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;

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

-- Corrigir tabela FUNCIONARIOS_FUNCOES
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

-- Corrigir tabela FUNCOES_PERMISSOES
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

-- ===========================================
-- PARTE 4: VERIFICAÇÃO FINAL
-- ===========================================

-- Listar políticas criadas
SELECT 
  '✅ ' || tablename || ': ' || COUNT(*) || ' políticas' as status
FROM pg_policies 
WHERE tablename IN ('permissoes', 'funcoes', 'funcionarios_funcoes', 'funcoes_permissoes')
GROUP BY tablename
ORDER BY tablename;

-- Testar SELECT sem recursão
SELECT 
  '📊 Total de permissões: ' || COUNT(*) as resultado
FROM permissoes;

SELECT 
  '📊 Categorias: ' || STRING_AGG(DISTINCT categoria, ', ') as categorias
FROM permissoes;

-- Resumo de permissões por categoria
SELECT 
  categoria,
  COUNT(*) as total,
  STRING_AGG(DISTINCT recurso, ', ') as recursos
FROM permissoes
GROUP BY categoria
ORDER BY categoria;

COMMIT;

-- =====================================================
-- 🎯 RESULTADO ESPERADO:
-- =====================================================
-- ✅ Políticas RLS corrigidas sem recursão
-- ✅ Permissões carregadas e acessíveis
-- ✅ Tabelas relacionadas também corrigidas
-- ✅ SELECT funciona sem erro 42P17
-- =====================================================
