-- =====================================================
-- 🏢 CRIAR EMPRESA PARA O USUÁRIO CRISTIAN
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Criar empresa para o usuário
INSERT INTO empresas (
  id,
  user_id,
  email,
  nome,
  razao_social,
  cnpj,
  telefone,
  tipo_conta,
  is_super_admin,
  created_at,
  updated_at,
  data_cadastro
)
VALUES (
  gen_random_uuid(),                                    -- id
  '922d4f20-6c99-4438-a922-e275eb527c0b',              -- user_id
  'cris-ramos30@hotmail.com',                          -- email
  'Allimport',                                         -- nome
  'Allimport Comércio',                                -- razao_social
  NULL,                                                -- cnpj (opcional)
  NULL,                                                -- telefone (opcional)
  'premium',                                           -- tipo_conta
  true,                                                -- is_super_admin
  NOW(),                                               -- created_at
  NOW(),                                               -- updated_at
  NOW()                                                -- data_cadastro
);

-- =====================================================
-- ✅ VERIFICAR SE FOI CRIADO
-- =====================================================

SELECT 
  '✅ Empresa criada com sucesso!' as status,
  id,
  user_id,
  email,
  nome,
  razao_social,
  tipo_conta,
  is_super_admin,
  created_at
FROM empresas
WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b'
   OR email = 'cris-ramos30@hotmail.com';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ INSERT executado sem erros
-- ✅ SELECT mostra a empresa criada
-- ✅ Erro 406 deve desaparecer no console
-- ✅ Painel admin deve funcionar normalmente
-- =====================================================
