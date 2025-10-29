-- =====================================================
-- 🏢 CRIAR EMPRESAS PARA TODOS OS USUÁRIOS SEM EMPRESA
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- Vai criar empresa automaticamente para todos os usuários
-- =====================================================

-- 1️⃣ VERIFICAR QUANTOS USUÁRIOS NÃO TÊM EMPRESA
SELECT 
  COUNT(*) as total_sem_empresa,
  '❌ Usuários sem empresa' as descricao
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id OR e.email = au.email
WHERE e.id IS NULL
  AND au.deleted_at IS NULL;

-- 2️⃣ VER QUAIS USUÁRIOS NÃO TÊM EMPRESA
SELECT 
  au.id as user_id,
  au.email,
  au.created_at as cadastro_usuario,
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'name',
    SPLIT_PART(au.email, '@', 1)
  ) as nome_sugerido
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id OR e.email = au.email
WHERE e.id IS NULL
  AND au.deleted_at IS NULL
ORDER BY au.created_at DESC;

-- =====================================================
-- 3️⃣ CRIAR EMPRESAS PARA TODOS (AUTOMÁTICO)
-- =====================================================

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
  gen_random_uuid(),                                    -- id
  au.id,                                                -- user_id
  au.email,                                             -- email
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'company_name',
    au.raw_user_meta_data->>'name',
    'Empresa ' || SPLIT_PART(au.email, '@', 1)
  ),                                                    -- nome
  COALESCE(
    au.raw_user_meta_data->>'company_name',
    au.raw_user_meta_data->>'full_name',
    'Empresa ' || au.email
  ),                                                    -- razao_social
  'trial',                                              -- tipo_conta (padrão: trial)
  false,                                                -- is_super_admin (padrão: false)
  NOW(),                                                -- created_at
  NOW(),                                                -- updated_at
  NOW()                                                 -- data_cadastro
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id OR e.email = au.email
WHERE e.id IS NULL                                      -- Só criar se NÃO existir
  AND au.deleted_at IS NULL                             -- Só usuários ativos
  AND au.email IS NOT NULL;                             -- Só com email válido

-- =====================================================
-- 4️⃣ ATUALIZAR CRISTIAN COMO SUPER ADMIN
-- =====================================================

UPDATE empresas
SET 
  is_super_admin = true,
  tipo_conta = 'premium',
  nome = 'Allimport',
  razao_social = 'Allimport Comércio',
  updated_at = NOW()
WHERE email = 'cris-ramos30@hotmail.com'
   OR user_id = '922d4f20-6c99-4438-a922-e275eb527c0b';

-- =====================================================
-- 5️⃣ VERIFICAR RESULTADO FINAL
-- =====================================================

-- Contar quantas empresas foram criadas
SELECT 
  COUNT(*) as total_empresas_criadas,
  '✅ Total de empresas no sistema' as descricao
FROM empresas;

-- Ver todas as empresas criadas
SELECT 
  e.id,
  e.user_id,
  e.email,
  e.nome,
  e.tipo_conta,
  e.is_super_admin,
  e.created_at,
  CASE 
    WHEN e.is_super_admin THEN '👑 SUPER ADMIN'
    WHEN e.tipo_conta = 'premium' THEN '⭐ PREMIUM'
    WHEN e.tipo_conta = 'trial' THEN '🔄 TRIAL'
    ELSE '📋 BÁSICO'
  END as status
FROM empresas e
ORDER BY e.is_super_admin DESC, e.created_at DESC;

-- Verificar se ainda existe usuário sem empresa
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ TODOS os usuários têm empresa!'
    ELSE '⚠️ Ainda existem ' || COUNT(*) || ' usuários sem empresa'
  END as resultado_final
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id OR e.email = au.email
WHERE e.id IS NULL
  AND au.deleted_at IS NULL;

-- =====================================================
-- 🎯 O QUE ESTE SQL FAZ:
-- =====================================================
-- ✅ Cria empresa para TODOS os usuários que não têm
-- ✅ Define tipo_conta='trial' como padrão
-- ✅ Define Cristian como super_admin com conta premium
-- ✅ Usa nome do perfil do usuário se disponível
-- ✅ NÃO duplica empresas (só cria se não existir)
-- ✅ NÃO afeta o sistema de assinaturas
-- 
-- ⚠️ IMPORTANTE:
-- - Usuários novos: tipo_conta='trial'
-- - Você (Cristian): tipo_conta='premium' + super_admin
-- - O RLS já está configurado corretamente
-- =====================================================
