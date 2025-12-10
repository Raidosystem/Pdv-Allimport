-- 🔒 CORRIGIR RLS DA TABELA EMPRESAS - PERMITIR SELECT

-- ⚠️ PROBLEMA:
-- Erro HTTP 406 ao buscar empresa por email
-- RLS está bloqueando acesso mesmo para usuários autenticados

-- ====================================
-- 1. VER POLÍTICAS ATUAIS
-- ====================================
SELECT 
  '📋 POLÍTICAS ATUAIS' as titulo,
  policyname,
  cmd as operacao,
  qual as tipo
FROM pg_policies
WHERE tablename = 'empresas'
ORDER BY cmd, policyname;

-- ====================================
-- 2. REMOVER POLÍTICAS ANTIGAS DE SELECT
-- ====================================
DROP POLICY IF EXISTS "empresas_select" ON empresas;
DROP POLICY IF EXISTS "empresas_select_policy" ON empresas;
DROP POLICY IF EXISTS "rls_empresas_select" ON empresas;
DROP POLICY IF EXISTS "Empresas podem ver seus proprios dados" ON empresas;
DROP POLICY IF EXISTS "Usuarios visualizam propria empresa" ON empresas;

-- ====================================
-- 3. CRIAR POLÍTICA DE SELECT PERMISSIVA
-- ====================================

-- Permitir que qualquer usuário autenticado busque empresas por email
-- Isso é necessário para o sistema de login local de 2 níveis
CREATE POLICY "rls_empresas_select_public" ON empresas
FOR SELECT
TO authenticated
USING (
  -- Permite buscar por email (login)
  true
);

-- ====================================
-- 4. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ POLÍTICAS RLS CRIADAS' as status,
  policyname,
  cmd as operacao,
  qual as tipo
FROM pg_policies
WHERE tablename = 'empresas'
ORDER BY cmd, policyname;

-- ====================================
-- 5. TESTAR QUERY
-- ====================================
-- Execute como usuário autenticado
SELECT 
  '🧪 TESTE DE QUERY' as info,
  id,
  nome,
  email
FROM empresas
WHERE email = 'assistenciaallimport10@gmail.com';

-- ====================================
-- 6. VERIFICAR SE RLS ESTÁ ATIVO
-- ====================================
SELECT 
  '🔒 RLS STATUS' as info,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables
WHERE tablename = 'empresas';
