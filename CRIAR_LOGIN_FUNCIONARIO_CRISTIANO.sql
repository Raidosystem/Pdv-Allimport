-- =====================================================
-- CRIAR LOGIN PARA FUNCIONÁRIO (Cristiano)
-- =====================================================
-- 
-- PROBLEMA: Não existe registro em login_funcionarios
-- SOLUÇÃO: Criar registro com usuario e senha
-- =====================================================

-- 1. VERIFICAR DADOS DO FUNCIONÁRIO
-- =====================================================
SELECT 
  id,
  empresa_id,
  nome,
  email,
  'Não tem login' as status
FROM funcionarios 
WHERE id = '1cb59030-2cd8-4988-a712-57f1e326c180';

-- 2. VERIFICAR SE JÁ EXISTE LOGIN
-- =====================================================
SELECT * 
FROM login_funcionarios 
WHERE funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180';

-- 3. CRIAR LOGIN (se não existir)
-- =====================================================
-- Senha padrão: 123456
INSERT INTO login_funcionarios (
  funcionario_id,
  usuario,
  senha,
  ativo,
  created_at,
  updated_at
)
SELECT 
  '1cb59030-2cd8-4988-a712-57f1e326c180',
  'cristiano',  -- Nome de usuário (pode ser qualquer coisa)
  crypt('123456', gen_salt('bf')),  -- Senha criptografada com bcrypt
  true,
  now(),
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM login_funcionarios 
  WHERE funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180'
);

-- 4. VERIFICAR RESULTADO
-- =====================================================
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE lf.funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180';

-- 5. TESTAR LOGIN
-- =====================================================
SELECT validar_senha_local('cristiano', '123456');

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ LOGIN CRIADO COM SUCESSO!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Credenciais:';
  RAISE NOTICE '   Usuário: cristiano';
  RAISE NOTICE '   Senha: 123456';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Agora você pode:';
  RAISE NOTICE '   1. Recarregar a página do login';
  RAISE NOTICE '   2. Selecionar o usuário "Cristiano Ramos Mendes"';
  RAISE NOTICE '   3. Digitar a senha: 123456';
  RAISE NOTICE '   4. Fazer login com sucesso!';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️ IMPORTANTE:';
  RAISE NOTICE '   • listar_usuarios_ativos() agora vai retornar campo usuario = "cristiano"';
  RAISE NOTICE '   • validar_senha_local() vai validar corretamente';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
