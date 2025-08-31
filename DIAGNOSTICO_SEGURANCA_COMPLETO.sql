-- =========================================================================
-- DIAGNÓSTICO COMPLETO DE SEGURANÇA E ISOLAMENTO MULTI-TENANT
-- Execute este SQL no SQL Editor do Supabase Dashboard
-- =========================================================================

-- 1. VERIFICAR SE RLS ESTÁ ATIVADO NAS TABELAS
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename IN ('clientes', 'produtos');

-- 2. LISTAR TODAS AS POLÍTICAS RLS EXISTENTES
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as operacao,
  permissive,
  roles,
  qual as condicao,
  with_check
FROM pg_policies 
WHERE tablename IN ('produtos', 'clientes')
ORDER BY tablename, policyname;

-- 3. VERIFICAR ESTRUTURA DAS TABELAS (COLUNAS USER_ID)
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name IN ('clientes', 'produtos') 
  AND column_name = 'user_id';

-- 4. VERIFICAR DADOS SEM USER_ID (PROBLEMAS DE ISOLAMENTO)
SELECT 
  'clientes' as tabela,
  COUNT(*) as registros_sem_user_id
FROM clientes 
WHERE user_id IS NULL

UNION ALL

SELECT 
  'produtos' as tabela,
  COUNT(*) as registros_sem_user_id
FROM produtos 
WHERE user_id IS NULL;

-- 5. VERIFICAR DISTRIBUIÇÃO DE DADOS POR USER_ID
SELECT 
  'clientes' as tabela,
  user_id,
  COUNT(*) as total_registros
FROM clientes 
WHERE user_id IS NOT NULL
GROUP BY user_id

UNION ALL

SELECT 
  'produtos' as tabela,
  user_id,
  COUNT(*) as total_registros
FROM produtos 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY tabela, user_id;

-- 6. VERIFICAR SE O UUID ASSISTENCIA EXISTE EM AUTH.USERS
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  email_confirmed_at
FROM auth.users 
WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- 7. TESTAR ACESSO COM DIFERENTES CONTEXTOS DE USUÁRIO
-- (Simulação de teste de segurança)

-- 7.1. Verificar se podemos ver dados sem autenticação (deve falhar)
SET LOCAL rls.current_user_id = NULL;
SELECT 'Teste sem autenticação - clientes' as teste, COUNT(*) as resultado FROM clientes;
SELECT 'Teste sem autenticação - produtos' as teste, COUNT(*) as resultado FROM produtos;

-- 7.2. Verificar com o usuário correto (deve funcionar)
SET LOCAL rls.current_user_id = '550e8400-e29b-41d4-a716-446655440000';
SELECT 'Teste com usuário correto - clientes' as teste, COUNT(*) as resultado FROM clientes;
SELECT 'Teste com usuário correto - produtos' as teste, COUNT(*) as resultado FROM produtos;

-- 7.3. Verificar com usuário diferente (deve retornar 0)
SET LOCAL rls.current_user_id = '11111111-2222-3333-4444-555555555555';
SELECT 'Teste com usuário diferente - clientes' as teste, COUNT(*) as resultado FROM clientes;
SELECT 'Teste com usuário diferente - produtos' as teste, COUNT(*) as resultado FROM produtos;

-- 8. VERIFICAR FOREIGN KEY CONSTRAINTS
SELECT
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.table_name IN ('clientes', 'produtos')
  AND tc.constraint_type = 'FOREIGN KEY';

-- 9. VERIFICAR TRIGGERS QUE PODEM INTERFERIR
SELECT 
  schemaname,
  tablename,
  triggername,
  triggerdef
FROM pg_triggers 
WHERE tablename IN ('clientes', 'produtos');

-- 10. VERIFICAR ROLES E PERMISSÕES
SELECT 
  grantee,
  table_name,
  privilege_type
FROM information_schema.role_table_grants 
WHERE table_name IN ('clientes', 'produtos')
  AND grantee NOT IN ('postgres', 'public');

-- =========================================================================
-- ANÁLISE DE PROBLEMAS COMUNS:
-- 
-- PROBLEMA 1: RLS não habilitado
-- PROBLEMA 2: Políticas RLS incorretas ou ausentes
-- PROBLEMA 3: Registros sem user_id (dados "órfãos")
-- PROBLEMA 4: UUID do usuário não existe em auth.users
-- PROBLEMA 5: Frontend não está filtrando corretamente
-- PROBLEMA 6: Service Role bypassa RLS
-- PROBLEMA 7: Múltiplas políticas conflitantes
-- =========================================================================
