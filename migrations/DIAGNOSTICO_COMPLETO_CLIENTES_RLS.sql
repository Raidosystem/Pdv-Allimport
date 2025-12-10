-- =====================================================
-- 🔍 DIAGNÓSTICO COMPLETO - ISOLAMENTO DE CLIENTES
-- =====================================================
-- PROBLEMA: Clientes de uma empresa aparecem em outra
-- CAUSA: RLS não está protegendo adequadamente
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR ESTRUTURA DA TABELA CLIENTES
-- =====================================================

SELECT 
  '1️⃣ Estrutura da tabela clientes' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'clientes'
ORDER BY ordinal_position;

-- =====================================================
-- 2️⃣ VERIFICAR SE RLS ESTÁ ATIVADO
-- =====================================================

SELECT 
  '2️⃣ Status RLS' as secao,
  schemaname,
  tablename,
  rowsecurity as rls_ativado
FROM pg_tables
WHERE tablename = 'clientes';

-- =====================================================
-- 3️⃣ VER TODAS AS POLÍTICAS RLS DE CLIENTES
-- =====================================================

SELECT 
  '3️⃣ Políticas RLS' as secao,
  policyname as nome_politica,
  cmd as operacao,
  permissive as permissiva,
  roles as funcoes,
  qual as condicao_where,
  with_check as condicao_insert_update
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- =====================================================
-- 4️⃣ VERIFICAR DISTRIBUIÇÃO DE CLIENTES POR EMPRESA
-- =====================================================

SELECT 
  '4️⃣ Clientes por Empresa' as secao,
  e.nome as empresa_nome,
  au.email as usuario_email,
  COUNT(c.id) as total_clientes,
  STRING_AGG(c.nome, ', ' ORDER BY c.nome) as nomes_clientes
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN clientes c ON c.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- =====================================================
-- 5️⃣ VERIFICAR SE HÁ CLIENTES SEM EMPRESA_ID
-- =====================================================

SELECT 
  '5️⃣ Clientes órfãos' as secao,
  COUNT(*) as total_sem_empresa
FROM clientes
WHERE empresa_id IS NULL;

-- =====================================================
-- 6️⃣ VERIFICAR SE HÁ CLIENTES COM USER_ID ERRADO
-- =====================================================

SELECT 
  '6️⃣ Clientes com user_id incompatível' as secao,
  c.id,
  c.nome as cliente_nome,
  c.user_id as cliente_user_id,
  c.empresa_id,
  e.user_id as empresa_user_id,
  CASE 
    WHEN c.user_id = e.user_id THEN '✅ OK'
    ELSE '❌ INCOMPATÍVEL'
  END as validacao
FROM clientes c
LEFT JOIN empresas e ON e.id = c.empresa_id
WHERE c.user_id != e.user_id OR c.empresa_id IS NULL
LIMIT 20;

-- =====================================================
-- 7️⃣ TESTAR QUERY COMO USUÁRIO ESPECÍFICO
-- =====================================================
-- Esta query mostra o que cada usuário consegue ver
SELECT 
  '7️⃣ Simulação de acesso por usuário' as secao,
  au.email as usuario_email,
  e.nome as empresa_nome,
  COUNT(c.id) as clientes_visiveis
FROM auth.users au
INNER JOIN empresas e ON e.user_id = au.id
LEFT JOIN clientes c ON c.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY au.email, e.nome
ORDER BY au.email;

-- =====================================================
-- 🎯 ANÁLISE DO PROBLEMA
-- =====================================================
-- Se na seção 3️⃣ não houver políticas OU as políticas
-- não usarem empresa_id: PROBLEMA CRÍTICO
-- 
-- Se na seção 6️⃣ houver clientes com ❌: precisa corrigir
-- 
-- Políticas corretas devem usar:
-- WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
-- =====================================================
