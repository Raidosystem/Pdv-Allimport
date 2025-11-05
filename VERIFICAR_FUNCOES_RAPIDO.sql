-- 🔍 VERIFICAÇÃO RÁPIDA - QUAIS FUNÇÕES ESTÃO FALTANDO?

-- ====================================
-- 1. VERIFICAR FUNÇÕES CRÍTICAS EXISTENTES
-- ====================================
SELECT 
  '🔍 FUNÇÕES CRÍTICAS' as categoria,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') 
    THEN '✅ listar_usuarios_ativos EXISTE'
    ELSE '❌ listar_usuarios_ativos AUSENTE'
  END as func1,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local') 
    THEN '✅ validar_senha_local EXISTE'
    ELSE '❌ validar_senha_local AUSENTE'
  END as func2;

-- ====================================
-- 2. LISTAR TODAS AS FUNÇÕES EXISTENTES
-- ====================================
SELECT 
  '📋 TODAS AS FUNÇÕES EXISTENTES' as categoria,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- ====================================
-- 3. VERIFICAR PERMISSÕES
-- ====================================
SELECT 
  '🔑 PERMISSÕES DE EXECUÇÃO' as categoria,
  routine_name,
  grantee,
  privilege_type
FROM information_schema.routine_privileges
WHERE routine_schema = 'public'
  AND grantee IN ('authenticated', 'anon')
ORDER BY routine_name, grantee;

-- ====================================
-- 4. VERIFICAR POLÍTICAS RLS
-- ====================================
SELECT 
  '🔒 POLÍTICAS RLS' as categoria,
  tablename,
  policyname,
  permissive
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;

-- ====================================
-- 5. STATUS DOS FUNCIONÁRIOS
-- ====================================
SELECT 
  '👥 STATUS FUNCIONÁRIOS' as categoria,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha
FROM funcionarios;

-- ====================================
-- 6. DIAGNÓSTICO FINAL
-- ====================================
SELECT 
  '💡 DIAGNÓSTICO' as categoria,
  CASE 
    WHEN NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos')
    THEN '❌ FUNÇÕES NÃO FORAM CRIADAS - Verifique erros no script'
    ELSE '✅ FUNÇÕES EXISTEM - Problema pode ser em outro lugar'
  END as resultado;