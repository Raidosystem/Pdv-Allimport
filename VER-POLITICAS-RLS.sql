-- =====================================================
-- VER POLÍTICAS RLS DE CLIENTES E CORRIGIR
-- =====================================================

-- 1. VER TODAS AS POLÍTICAS RLS DA TABELA CLIENTES
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual as "using_expression",
  with_check as "with_check_expression"
FROM pg_policies 
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 2. VERIFICAR SE admin_empresa TEM BYPASS NO RLS
-- (Super users e service_role podem ver tudo)
SELECT 
  current_user as "usuario_atual",
  current_setting('role') as "role_atual";

-- 3. VER CONFIGURAÇÃO RLS DA TABELA
SELECT 
  tablename,
  rowsecurity as "rls_habilitado"
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'clientes';

-- 4. TENTAR BUSCAR CLIENTES COMO AUTHENTICATED USER
-- (Simula o que o app está fazendo)
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =====================================================
-- DIAGNÓSTICO:
-- - Se a query 4 retornar 0, o RLS está bloqueando
-- - Se retornar 98, o problema é no código da aplicação
-- =====================================================
