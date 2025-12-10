-- =====================================================
-- 🔧 CORRIGIR EMPRESAS PARA TODOS OS USUÁRIOS
-- =====================================================
-- Este SQL vai:
-- 1. Adicionar policy de INSERT (para novos usuários)
-- 2. Adicionar policy de UPDATE (para editar empresa)
-- 3. Criar empresas para TODOS os usuários que não têm
-- =====================================================

-- =====================================================
-- 1️⃣ ADICIONAR POLICY DE INSERT (NOVOS USUÁRIOS)
-- =====================================================

-- Remover policy antiga se existir
DROP POLICY IF EXISTS "insert_own_company" ON empresas;
DROP POLICY IF EXISTS "Usuários podem criar sua própria empresa" ON empresas;

-- Criar policy para INSERT
CREATE POLICY "insert_own_company"
ON empresas
FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
);

-- =====================================================
-- 2️⃣ ADICIONAR POLICY DE UPDATE (EDITAR EMPRESA)
-- =====================================================

-- Remover policy antiga se existir
DROP POLICY IF EXISTS "update_own_company" ON empresas;
DROP POLICY IF EXISTS "Usuários podem atualizar sua própria empresa" ON empresas;

-- Criar policy para UPDATE
CREATE POLICY "update_own_company"
ON empresas
FOR UPDATE
TO authenticated
USING (
  user_id = auth.uid()
)
WITH CHECK (
  user_id = auth.uid()
);

-- =====================================================
-- 3️⃣ VERIFICAR QUANTOS USUÁRIOS ESTÃO SEM EMPRESA
-- =====================================================

SELECT 
  COUNT(*) as total_usuarios_sem_empresa,
  STRING_AGG(au.email, ', ') as emails
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
WHERE e.id IS NULL
  AND au.email IS NOT NULL;

-- =====================================================
-- 4️⃣ CRIAR EMPRESAS PARA TODOS OS USUÁRIOS
-- =====================================================

-- Criar empresa para cada usuário que não tem
INSERT INTO empresas (
  id,
  user_id,
  email,
  nome,
  razao_social,
  tipo_conta,
  is_super_admin,
  created_at,
  updated_at,
  data_cadastro
)
SELECT 
  gen_random_uuid(),
  au.id,
  au.email,
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'company_name',
    'Empresa ' || SPLIT_PART(au.email, '@', 1)
  ) as nome,
  COALESCE(
    au.raw_user_meta_data->>'company_name',
    au.raw_user_meta_data->>'full_name',
    'Empresa ' || au.email
  ) as razao_social,
  CASE 
    -- Se tem assinatura ativa, define como premium
    WHEN EXISTS (
      SELECT 1 FROM subscriptions s 
      WHERE s.user_id = au.id 
        AND s.status IN ('active', 'trial')
        AND (
          (s.status = 'active' AND s.subscription_end_date > NOW())
          OR
          (s.status = 'trial' AND s.trial_end_date > NOW())
        )
    ) THEN 'premium'
    ELSE 'trial'
  END as tipo_conta,
  false as is_super_admin,
  NOW(),
  NOW(),
  NOW()
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
WHERE e.id IS NULL
  AND au.email IS NOT NULL;

-- =====================================================
-- 5️⃣ DEFINIR CRISTIAN COMO SUPER ADMIN
-- =====================================================

UPDATE empresas
SET 
  is_super_admin = true,
  tipo_conta = 'premium',
  nome = 'Allimport',
  razao_social = 'Allimport Comércio'
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b'
   OR email = 'cris-ramos30@hotmail.com';

-- =====================================================
-- 6️⃣ VERIFICAÇÃO FINAL
-- =====================================================

-- Ver todas as empresas criadas
SELECT 
  '✅ Empresas criadas' as status,
  COUNT(*) as total
FROM empresas;

-- Ver usuários que ainda não têm empresa (deve ser 0)
SELECT 
  '⚠️ Usuários sem empresa' as status,
  COUNT(*) as total
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
WHERE e.id IS NULL
  AND au.email IS NOT NULL;

-- Ver detalhes da empresa do Cristian
SELECT 
  '✅ Cristian configurado' as status,
  id,
  email,
  nome,
  razao_social,
  tipo_conta,
  is_super_admin
FROM empresas
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- Ver todas as policies ativas
SELECT 
  '✅ Policies configuradas' as status,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'empresas'
ORDER BY cmd;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Policies de SELECT, INSERT e UPDATE criadas
-- ✅ Empresas criadas para TODOS os usuários
-- ✅ Cristian definido como super_admin
-- ✅ Novos usuários poderão criar empresas automaticamente
-- ✅ Erro 406 desaparece para todos
-- ✅ Sistema funciona normalmente
-- =====================================================
