-- =====================================================
-- HABILITAR PGCRYPTO E CRIAR LOGIN
-- =====================================================

-- 1. HABILITAR EXTENSÃO pgcrypto (necessária para crypt/bcrypt)
-- =====================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. VERIFICAR SE EXTENSÃO FOI HABILITADA
-- =====================================================
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

-- 3. CRIAR LOGIN PARA FUNCIONÁRIO (Cristiano)
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
  'cristiano',  -- Nome de usuário
  crypt('123456', gen_salt('bf')),  -- Senha criptografada com bcrypt
  true,
  now(),
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM login_funcionarios 
  WHERE funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180'
);

-- 4. VERIFICAR LOGIN CRIADO
-- =====================================================
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome,
  f.email
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE lf.funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180';

-- 5. TESTAR LOGIN
-- =====================================================
SELECT validar_senha_local('cristiano', '123456');

-- 6. RESULTADO
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CONFIGURAÇÃO COMPLETA!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Credenciais de Login:';
  RAISE NOTICE '   Usuário: cristiano';
  RAISE NOTICE '   Senha: 123456';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Próximos passos:';
  RAISE NOTICE '   1. Recarregar a página (F5)';
  RAISE NOTICE '   2. Fazer login com as credenciais acima';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
