-- ====================================================================
-- 🚨 CORREÇÃO URGENTE: JENNIFER SEM LOGIN
-- ====================================================================
-- Execute este script NO SQL EDITOR DO SUPABASE
-- ====================================================================

-- 🎯 CRIAR LOGIN PARA JENNIFER
DO $$
DECLARE
  v_jennifer_id UUID := '866ae21a-ba51-4fca-bbba-4d4610017a4e';
  v_usuario TEXT := 'jennifer';
  v_senha_padrao TEXT := 'Senha@123';
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '🔧 Criando login para Jennifer...';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';

  -- Verificar empresa
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE id = v_jennifer_id;

  RAISE NOTICE '👤 Funcionário: Jennifer';
  RAISE NOTICE '🏢 Empresa ID: %', v_empresa_id;
  RAISE NOTICE '';

  -- Criar registro em login_funcionarios
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha_hash,
    ativo,
    precisa_trocar_senha,
    tentativas_login,
    bloqueado_ate
  ) VALUES (
    v_jennifer_id,
    v_usuario,
    crypt(v_senha_padrao, gen_salt('bf')),
    true,
    true,  -- Obriga trocar senha no primeiro login
    0,
    NULL
  );

  -- Atualizar flags na tabela funcionarios
  UPDATE funcionarios 
  SET 
    senha_definida = true,
    primeiro_acesso = true,
    updated_at = NOW()
  WHERE id = v_jennifer_id;

  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '✅ Login criado com sucesso!';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';
  RAISE NOTICE '🔐 CREDENCIAIS DA JENNIFER:';
  RAISE NOTICE '   • Usuário: %', v_usuario;
  RAISE NOTICE '   • Senha: %', v_senha_padrao;
  RAISE NOTICE '   • Trocar senha: SIM (obrigatório no 1º acesso)';
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';

END;
$$;

-- ✅ VERIFICAR SE FUNCIONOU
SELECT 
  '✅ VERIFICAÇÃO' as resultado,
  f.nome,
  lf.usuario,
  lf.ativo,
  lf.precisa_trocar_senha,
  f.senha_definida,
  CASE 
    WHEN lf.usuario IS NOT NULL AND lf.ativo = true 
    THEN '✅ VAI APARECER NA TELA DE LOGIN'
    ELSE '❌ NÃO VAI APARECER'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.id = '866ae21a-ba51-4fca-bbba-4d4610017a4e';

-- 🧪 TESTAR RPC (O que o sistema vê)
SELECT 
  '🧪 TESTE RPC' as resultado,
  nome,
  usuario,
  email,
  tipo_admin
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE id = '866ae21a-ba51-4fca-bbba-4d4610017a4e')
)
WHERE nome ILIKE '%jennifer%';

-- ====================================================================
-- 📝 INSTRUÇÕES PARA JENNIFER:
-- ====================================================================
-- 
-- 1. Acesse: https://pdv.gruporaval.com.br/login-local
-- 2. Clique no seu nome: Jennifer
-- 3. Digite a senha temporária: Senha@123
-- 4. Você será solicitada a criar sua senha pessoal
-- 
-- ====================================================================
