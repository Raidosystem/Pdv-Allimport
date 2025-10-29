-- =====================================================
-- 🔧 CORRIGIR RLS DA TABELA EMPRESAS (SEM AFETAR OUTRAS TABELAS)
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- Isso vai permitir que usuários vejam apenas sua própria empresa
-- =====================================================

-- 1️⃣ Verificar policies atuais da tabela empresas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'empresas'
ORDER BY cmd, policyname;

-- =====================================================
-- 2️⃣ CRIAR/ATUALIZAR POLICY DE SELECT (LEITURA)
-- =====================================================

-- Remover policy antiga de SELECT se existir
DROP POLICY IF EXISTS "Usuários podem ver sua própria empresa" ON empresas;
DROP POLICY IF EXISTS "Users can read their own company" ON empresas;
DROP POLICY IF EXISTS "select_own_company" ON empresas;

-- Criar policy nova e segura para SELECT
CREATE POLICY "select_own_company"
ON empresas
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() 
  OR email = (auth.jwt()->>'email')
);

-- =====================================================
-- 3️⃣ GARANTIR QUE RLS ESTÁ ATIVADO
-- =====================================================

-- Ativar RLS na tabela empresas
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4️⃣ VERIFICAR ESTRUTURA DA TABELA EMPRESAS
-- =====================================================

-- Ver todas as colunas disponíveis
SELECT 
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'empresas'
ORDER BY ordinal_position;

-- =====================================================
-- 5️⃣ TESTAR SE ESTÁ FUNCIONANDO
-- =====================================================

-- Este SELECT deve retornar a empresa do usuário logado
SELECT *
FROM empresas
WHERE email = 'cris-ramos30@hotmail.com'
   OR user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- Se retornar dados = ✅ FUNCIONOU!
-- Se retornar vazio = ❌ Precisa criar a empresa

-- =====================================================
-- 6️⃣ SE NÃO EXISTIR EMPRESA, CRIAR UMA
-- =====================================================

-- Verificar se o usuário tem empresa
SELECT 
  au.email,
  au.id as user_id,
  e.id as empresa_id,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA - Precisa criar'
    ELSE '✅ TEM EMPRESA'
  END as status
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id OR e.email = au.email
WHERE au.email = 'cris-ramos30@hotmail.com';

-- Se mostrar "SEM EMPRESA", você pode criar manualmente depois
-- (aguarde ver quais colunas existem na tabela)

-- =====================================================
-- 7️⃣ VERIFICAÇÃO FINAL
-- =====================================================

-- Deve retornar a empresa (todas as colunas)
SELECT *
FROM empresas
WHERE email = 'cris-ramos30@hotmail.com'
  OR user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Policy criada sem erros
-- ✅ SELECT retorna a empresa do usuário
-- ✅ Erro 406 deve desaparecer no console do navegador
-- ✅ Painel admin de usuários deve funcionar
-- 
-- ⚠️ IMPORTANTE: Isso NÃO afeta outras tabelas!
-- Apenas corrige o RLS da tabela "empresas"
-- =====================================================
