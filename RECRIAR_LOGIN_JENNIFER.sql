-- 🔧 RECRIAR LOGIN DE JENNIFER COM SENHA CORRETA

-- ====================================
-- 1. DELETAR LOGIN ANTIGO DE JENNIFER
-- ====================================
DELETE FROM login_funcionarios
WHERE funcionario_id = (
  SELECT id FROM funcionarios WHERE nome = 'Jennifer Sousa' LIMIT 1
);

-- ====================================
-- 2. CRIAR NOVO LOGIN COM SENHA CORRETA (123456)
-- ====================================
INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
SELECT 
  f.id,
  'jennifer',
  crypt('123456', gen_salt('bf')),
  true
FROM funcionarios f
WHERE f.nome = 'Jennifer Sousa'
LIMIT 1
RETURNING funcionario_id, usuario, 'LOGIN RECRIADO' as status;

-- ====================================
-- 3. TESTAR VALIDAÇÃO NOVAMENTE
-- ====================================
SELECT 
  '🧪 TESTE APÓS RECRIAR' as teste,
  *
FROM validar_senha_local(
  (SELECT id FROM funcionarios WHERE nome = 'Jennifer Sousa' LIMIT 1),
  '123456'
);

-- ====================================
-- 4. VERIFICAR TODOS LOGINS
-- ====================================
SELECT 
  '✅ LOGINS ATIVOS' as info,
  lf.usuario,
  f.nome as funcionario_nome,
  lf.ativo,
  'Senha: 123456' as senha_padrao
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY f.nome;
