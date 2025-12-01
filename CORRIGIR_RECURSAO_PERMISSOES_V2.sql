-- =====================================================
-- CORRIGIR RECURSÃO - VERSÃO SEGURA (IDEMPOTENTE)
-- =====================================================
-- Pode ser executado múltiplas vezes sem erro

BEGIN;

-- 🔥 PASSO 1: Limpar TODAS as políticas da tabela permissoes
DO $$ 
DECLARE
  policy_record RECORD;
BEGIN
  FOR policy_record IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'permissoes' 
    AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON permissoes CASCADE', policy_record.policyname);
    RAISE NOTICE 'Removida política: %', policy_record.policyname;
  END LOOP;
  
  IF NOT FOUND THEN
    RAISE NOTICE '✅ Nenhuma política para remover';
  END IF;
END $$;

-- 🔥 PASSO 2: Garantir que RLS está ativo
ALTER TABLE permissoes ENABLE ROW LEVEL SECURITY;

-- ✅ PASSO 3: Criar políticas SIMPLES e SEM RECURSÃO

-- 📖 SELECT: Todos autenticados podem ver permissões (é tabela de metadados)
CREATE POLICY "permissoes_select_public"
ON permissoes
FOR SELECT
TO authenticated
USING (true);

RAISE NOTICE '✅ Política SELECT criada';

-- ✏️ INSERT: Apenas service_role ou admin pode inserir
CREATE POLICY "permissoes_insert_admin"
ON permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Super admin pode (verifica direto na tabela users sem recursão)
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode (verifica direto na tabela empresas)
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

RAISE NOTICE '✅ Política INSERT criada';

-- 🔄 UPDATE: Apenas service_role ou admin pode atualizar
CREATE POLICY "permissoes_update_admin"
ON permissoes
FOR UPDATE
TO authenticated
USING (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
)
WITH CHECK (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

RAISE NOTICE '✅ Política UPDATE criada';

-- 🗑️ DELETE: Apenas service_role ou admin pode deletar
CREATE POLICY "permissoes_delete_admin"
ON permissoes
FOR DELETE
TO authenticated
USING (
  -- Super admin pode
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data->>'is_super_admin' = 'true'
  )
  OR
  -- Admin da empresa pode
  EXISTS (
    SELECT 1 FROM empresas
    WHERE empresas.user_id = auth.uid()
  )
);

RAISE NOTICE '✅ Política DELETE criada';

-- ✅ PASSO 4: Verificar políticas criadas
DO $$
DECLARE
  total_policies INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE tablename = 'permissoes';
  
  RAISE NOTICE '📊 Total de políticas em permissoes: %', total_policies;
END $$;

-- Listar políticas
SELECT 
  '✅ ' || policyname as politica,
  cmd as comando,
  CASE 
    WHEN cmd = 'SELECT' THEN 'Leitura permitida'
    WHEN cmd = 'INSERT' THEN 'Apenas admins podem inserir'
    WHEN cmd = 'UPDATE' THEN 'Apenas admins podem atualizar'
    WHEN cmd = 'DELETE' THEN 'Apenas admins podem deletar'
  END as descricao
FROM pg_policies
WHERE tablename = 'permissoes'
ORDER BY cmd;

-- 📊 PASSO 5: Teste de recursão (deve funcionar sem erro)
DO $$
DECLARE
  total_permissoes INTEGER;
  total_categorias INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_permissoes FROM permissoes;
  SELECT COUNT(DISTINCT categoria) INTO total_categorias FROM permissoes;
  
  RAISE NOTICE '📊 Total de permissões no sistema: %', total_permissoes;
  RAISE NOTICE '📂 Total de categorias: %', total_categorias;
  
  IF total_permissoes >= 10 THEN
    RAISE NOTICE '✅ Tabela permissoes OK - % registros encontrados', total_permissoes;
  ELSE
    RAISE WARNING '⚠️ Tabela permissoes tem poucos registros: %', total_permissoes;
  END IF;
END $$;

-- Testar SELECT (deve funcionar sem erro 42P17)
SELECT 
  categoria,
  COUNT(*) as total
FROM permissoes
GROUP BY categoria
ORDER BY categoria;

COMMIT;

-- =====================================================
-- 🎯 RESULTADO ESPERADO:
-- =====================================================
-- ✅ 4 políticas criadas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Sem erro de recursão infinita
-- ✅ SELECT funciona normalmente
-- ✅ Permissões existentes mantidas (91 registros)
-- =====================================================

RAISE NOTICE '✅✅✅ CORREÇÃO CONCLUÍDA COM SUCESSO! ✅✅✅';
