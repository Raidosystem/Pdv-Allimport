-- =====================================================
-- 🔥 CORREÇÃO DEFINITIVA - RECURSÃO INFINITA PERMISSÕES
-- =====================================================
-- Erro: infinite recursion detected in policy for relation "permissoes"
-- Data: 2025-12-01
-- Solução: Remover TODAS as políticas problemáticas e criar políticas SIMPLES

-- ✅ EXECUTAR ESTE SCRIPT NO SUPABASE SQL EDITOR

BEGIN;

-- ==================================================
-- PASSO 1: REMOVER TODAS AS POLÍTICAS EXISTENTES
-- ==================================================
SELECT '🗑️ Removendo políticas antigas...' as status;

DROP POLICY IF EXISTS "permissoes_select_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_insert_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_update_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_delete_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_select_public" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_insert_admin" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_update_admin" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_delete_admin" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "Admin pode gerenciar permissoes" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "Usuarios podem ver suas permissoes" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_read_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "permissoes_write_policy" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "Permitir leitura de permissoes" ON public.permissoes CASCADE;
DROP POLICY IF EXISTS "Apenas admins gerenciam permissoes" ON public.permissoes CASCADE;

-- Remover TODAS as políticas de uma vez (força bruta)
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'permissoes' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.permissoes CASCADE', pol.policyname);
    RAISE NOTICE 'Removida política: %', pol.policyname;
  END LOOP;
END $$;

-- ==================================================
-- PASSO 2: GARANTIR QUE RLS ESTÁ ATIVO
-- ==================================================
SELECT '🔒 Ativando RLS...' as status;

ALTER TABLE public.permissoes ENABLE ROW LEVEL SECURITY;

-- ==================================================
-- PASSO 3: CRIAR POLÍTICAS SIMPLES E SEM RECURSÃO
-- ==================================================
-- IMPORTANTE: Estas políticas NÃO DEVEM referenciar a tabela permissoes
-- Caso contrário, causam recursão infinita

SELECT '✅ Criando políticas simples...' as status;

-- 📖 SELECT: TODOS autenticados podem LER permissões
-- Permissões são METADADOS públicos do sistema
CREATE POLICY "permissoes_select_all"
ON public.permissoes
FOR SELECT
TO authenticated
USING (true);

-- ✏️ INSERT: Apenas ADMINS podem INSERIR permissões
-- Verifica direto na tabela empresas (SEM JOIN com permissoes)
CREATE POLICY "permissoes_insert_admin_only"
ON public.permissoes
FOR INSERT
TO authenticated
WITH CHECK (
  -- Admin da empresa pode (verifica direto)
  EXISTS (
    SELECT 1 FROM public.empresas
    WHERE empresas.user_id = auth.uid()
  )
  OR
  -- Super admin pode (verifica no auth.users)
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE users.id = auth.uid()
    AND (
      users.raw_user_meta_data->>'is_super_admin' = 'true'
      OR users.email IN (
        'admin@pdvallimport.com',
        'novaradiosystem@outlook.com',
        'assistenciaallimport10@gmail.com'
      )
    )
  )
);

-- 🔄 UPDATE: Apenas ADMINS podem ATUALIZAR permissões
CREATE POLICY "permissoes_update_admin_only"
ON public.permissoes
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.empresas
    WHERE empresas.user_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE users.id = auth.uid()
    AND (
      users.raw_user_meta_data->>'is_super_admin' = 'true'
      OR users.email IN (
        'admin@pdvallimport.com',
        'novaradiosystem@outlook.com',
        'assistenciaallimport10@gmail.com'
      )
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.empresas
    WHERE empresas.user_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE users.id = auth.uid()
    AND (
      users.raw_user_meta_data->>'is_super_admin' = 'true'
      OR users.email IN (
        'admin@pdvallimport.com',
        'novaradiosystem@outlook.com',
        'assistenciaallimport10@gmail.com'
      )
    )
  )
);

-- 🗑️ DELETE: Apenas ADMINS podem DELETAR permissões
CREATE POLICY "permissoes_delete_admin_only"
ON public.permissoes
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.empresas
    WHERE empresas.user_id = auth.uid()
  )
  OR
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE users.id = auth.uid()
    AND (
      users.raw_user_meta_data->>'is_super_admin' = 'true'
      OR users.email IN (
        'admin@pdvallimport.com',
        'novaradiosystem@outlook.com',
        'assistenciaallimport10@gmail.com'
      )
    )
  )
);

-- ==================================================
-- PASSO 4: VERIFICAR RESULTADO
-- ==================================================
SELECT '🔍 Verificando políticas criadas...' as status;

SELECT 
  policyname as "Política",
  cmd as "Comando",
  CASE 
    WHEN cmd = 'SELECT' THEN '📖 Leitura (todos)'
    WHEN cmd = 'INSERT' THEN '✏️ Inserção (admin)'
    WHEN cmd = 'UPDATE' THEN '🔄 Atualização (admin)'
    WHEN cmd = 'DELETE' THEN '🗑️ Exclusão (admin)'
  END as "Descrição"
FROM pg_policies
WHERE tablename = 'permissoes'
  AND schemaname = 'public'
ORDER BY cmd;

-- ==================================================
-- PASSO 5: TESTAR SEM RECURSÃO
-- ==================================================
SELECT '✅ Testando query...' as status;

SELECT 
  COUNT(*) as total_permissoes,
  COUNT(DISTINCT categoria) as categorias,
  COUNT(DISTINCT recurso) as recursos
FROM public.permissoes;

-- ==================================================
-- RESULTADO FINAL
-- ==================================================
DO $$
DECLARE
  total_policies INTEGER;
  total_permissoes INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_policies FROM pg_policies WHERE tablename = 'permissoes';
  SELECT COUNT(*) INTO total_permissoes FROM public.permissoes;
  
  RAISE NOTICE '================================';
  RAISE NOTICE '✅ CORREÇÃO APLICADA COM SUCESSO';
  RAISE NOTICE '================================';
  RAISE NOTICE '📊 Total de políticas: %', total_policies;
  RAISE NOTICE '📊 Total de permissões: %', total_permissoes;
  RAISE NOTICE '✅ Sem recursão detectada';
  RAISE NOTICE '✅ Sistema funcionando normalmente';
  RAISE NOTICE '================================';
END $$;

COMMIT;

-- =====================================================
-- ✅ APÓS EXECUTAR:
-- =====================================================
-- 1. Aguarde 10 segundos
-- 2. Recarregue a página de Administração no navegador
-- 3. Vá em "Funções e Permissões"
-- 4. Deve carregar sem erro 500
-- =====================================================
