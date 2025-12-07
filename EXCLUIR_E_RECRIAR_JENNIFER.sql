-- ========================================
-- EXCLUIR JENNIFER E PREPARAR RECADASTRO
-- ========================================
-- Jennifer precisa ter conta própria no Supabase Auth
-- para que o sistema funcione corretamente sem localStorage

-- 1️⃣ VERIFICAR DADOS ATUAIS DE JENNIFER
SELECT 
  '📊 DADOS ATUAIS DE JENNIFER' as etapa,
  f.id,
  f.nome,
  f.email,
  f.user_id,
  f.empresa_id,
  f.tipo_admin,
  f.funcao_id,
  func.nome as funcao_nome,
  f.ativo,
  e.email as email_empresa
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN auth.users e ON e.id = f.empresa_id
WHERE f.nome ILIKE '%jennifer%'
   OR f.email ILIKE '%jennifer%';

-- 2️⃣ BACKUP DOS DADOS DE JENNIFER (antes de excluir)
-- Copie o resultado acima para referência

-- 3️⃣ EXCLUIR JENNIFER DA TABELA login_funcionarios (se existir)
DELETE FROM login_funcionarios
WHERE funcionario_id IN (
  SELECT id FROM funcionarios 
  WHERE nome ILIKE '%jennifer%'
);

SELECT '✅ Login de Jennifer excluído' as status;

-- 4️⃣ EXCLUIR JENNIFER DA TABELA funcionarios
DELETE FROM funcionarios
WHERE nome ILIKE '%jennifer%';

SELECT '✅ Jennifer excluída da tabela funcionarios' as status;

-- ========================================
-- INSTRUÇÕES PARA RECADASTRO
-- ========================================

-- 📝 PASSOS PARA RECADASTRAR JENNIFER CORRETAMENTE:
--
-- 1. Jennifer deve criar conta própria:
--    - Acessar: https://pdv.gruporaval.com.br/signup
--    - Usar email dela (ex: jennifer@allimport.com ou jennifer.sousa@gmail.com)
--    - Criar senha dela
--    - Completar cadastro
--
-- 2. Cristiano deve adicionar Jennifer como funcionária:
--    - Login como Cristiano (assistenciaallimport10@gmail.com)
--    - Ir em Configurações > Funcionários
--    - Clicar em "Adicionar Funcionário"
--    - Preencher:
--      * Nome: Jennifer Sousa
--      * Email: [O MESMO EMAIL que Jennifer usou no signup]
--      * Cargo: Vendedor
--      * Função: Vendedor (16 permissões)
--      * Senha: [Senha para Jennifer]
--    - Salvar
--
-- 3. O sistema automaticamente:
--    - Cria conta no Supabase Auth com email dela
--    - Vincula user_id ao registro de funcionário
--    - Jennifer pode fazer login de qualquer dispositivo
--    - Sem necessidade de localStorage
--
-- 4. Verificar vínculo após cadastro:

-- Execute esta query DEPOIS de recriar Jennifer:
SELECT 
  '✅ VERIFICAÇÃO PÓS-CADASTRO' as etapa,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  f.tipo_admin,
  f.funcao_id,
  func.nome as funcao_nome,
  u.email as email_auth,
  u.created_at as conta_criada_em,
  CASE 
    WHEN f.user_id IS NOT NULL THEN '✅ user_id vinculado'
    ELSE '❌ ERRO: user_id não vinculado'
  END as status_vinculo,
  CASE 
    WHEN f.tipo_admin = 'funcionario' THEN '✅ tipo_admin correto'
    ELSE '❌ ERRO: tipo_admin incorreto'
  END as status_tipo
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN auth.users u ON u.id = f.user_id
WHERE f.nome ILIKE '%jennifer%';

-- ========================================
-- TROUBLESHOOTING
-- ========================================

-- Se Jennifer não conseguir fazer login após cadastro:

-- A) Verificar se email está correto no auth.users
SELECT 
  id,
  email,
  created_at,
  confirmed_at,
  last_sign_in_at
FROM auth.users
WHERE email ILIKE '%jennifer%';

-- B) Verificar se user_id foi vinculado corretamente
SELECT 
  f.nome,
  f.email as email_funcionario,
  f.user_id,
  u.email as email_auth,
  CASE 
    WHEN f.user_id = u.id THEN '✅ Vinculado'
    ELSE '❌ Não vinculado'
  END as status
FROM funcionarios f
LEFT JOIN auth.users u ON u.id = f.user_id
WHERE f.nome ILIKE '%jennifer%';

-- C) Se necessário, vincular manualmente (USE APENAS SE ERRO):
-- IMPORTANTE: Executar APENAS se o sistema não vincular automaticamente

-- UPDATE funcionarios
-- SET user_id = (
--   SELECT id FROM auth.users 
--   WHERE email = '[email_jennifer_no_auth]'
-- )
-- WHERE email = '[email_jennifer_no_funcionarios]';

-- ========================================
-- VALIDAÇÃO FINAL
-- ========================================

-- Após Jennifer fazer login, verificar logs do console:
-- Deve aparecer:
-- ✅ [usePermissions] Funcionário encontrado: Jennifer Sousa
-- 👤 [usePermissions] Tipo admin: funcionario
-- 🔑 [usePermissions] is_admin_empresa: false
-- 🎯 [usePermissions] Total de permissões: 16
