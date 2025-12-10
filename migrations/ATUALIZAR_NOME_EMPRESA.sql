-- ============================================
-- VERIFICAR NOME DA EMPRESA DO USUÁRIO LOGADO
-- ============================================

-- 1. Ver o nome da empresa cadastrada para você
SELECT 
  e.id as empresa_id,
  e.nome as nome_empresa,
  e.cnpj,
  e.email as email_empresa,
  e.user_id,
  u.email as usuario_email,
  u.raw_user_meta_data->>'full_name' as nome_usuario_perfil
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.email = 'cris-ramos30@hotmail.com';

-- 2. Se o nome estiver errado, atualizar para o nome correto
UPDATE empresas
SET nome = 'Assistência All-Import'  -- MUDE AQUI PARA O NOME DA SUA EMPRESA
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com'
);

-- 3. Verificar se foi atualizado
SELECT 
  id,
  nome,
  cnpj,
  email,
  user_id
FROM empresas
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com'
);
