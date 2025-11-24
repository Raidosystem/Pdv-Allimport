-- ============================================
-- DIAGNÓSTICO: Isolamento de Dados Entre Usuários
-- ============================================

-- 1️⃣ VERIFICAR ESTRUTURA DAS TABELAS
SELECT 
  '1. ESTRUTURA - PRODUTOS' as etapa,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'produtos'
AND column_name IN ('user_id', 'empresa_id')
ORDER BY ordinal_position;

SELECT 
  '1. ESTRUTURA - CLIENTES' as etapa,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'clientes'
AND column_name IN ('user_id', 'empresa_id')
ORDER BY ordinal_position;

-- 2️⃣ VERIFICAR STATUS DO RLS
SELECT 
  '2. STATUS RLS' as etapa,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('produtos', 'clientes')
ORDER BY tablename;

-- 3️⃣ VERIFICAR POLÍTICAS RLS ATIVAS
SELECT 
  '3. POLÍTICAS RLS' as etapa,
  tablename,
  policyname,
  cmd as comando
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('produtos', 'clientes')
ORDER BY tablename, policyname;

-- 4️⃣ VERIFICAR DADOS DOS USUÁRIOS
-- Usuário Assistência All-Import
SELECT 
  '4. USER_ID - Assistência' as etapa,
  id,
  email
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- Usuário Cristiano
SELECT 
  '4. USER_ID - Cristiano' as etapa,
  id,
  email
FROM auth.users
WHERE email = 'cristiano@gruporaval.com.br';

-- 5️⃣ VERIFICAR DISTRIBUIÇÃO DE PRODUTOS POR USER_ID
SELECT 
  '5. PRODUTOS POR USER_ID' as etapa,
  au.email as usuario,
  COUNT(p.id) as total_produtos
FROM produtos p
LEFT JOIN auth.users au ON au.id = p.user_id
GROUP BY au.email
ORDER BY total_produtos DESC;

-- 6️⃣ VERIFICAR DISTRIBUIÇÃO DE CLIENTES POR USER_ID
SELECT 
  '6. CLIENTES POR USER_ID' as etapa,
  au.email as usuario,
  COUNT(c.id) as total_clientes
FROM clientes c
LEFT JOIN auth.users au ON au.id = c.user_id
GROUP BY au.email
ORDER BY total_clientes DESC;

-- 7️⃣ VERIFICAR EMPRESA_ID
SELECT 
  '7. EMPRESAS' as etapa,
  e.id as empresa_id,
  e.nome as empresa_nome,
  au.email as usuario_dono
FROM empresas e
LEFT JOIN auth.users au ON au.id = e.user_id
ORDER BY e.nome;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- ❌ PROBLEMA 1: Produtos/clientes têm user_id do assistenciaallimport
-- ❌ PROBLEMA 2: RLS está desabilitado OU políticas incorretas
-- ❌ PROBLEMA 3: Dados não têm empresa_id preenchido
-- ============================================
