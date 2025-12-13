-- ====================================================================
-- CORREÇÃO AUTOMÁTICA: GARANTIR LOGIN PARA TODOS OS FUNCIONÁRIOS
-- ====================================================================
-- Este script garante que TODOS os funcionários ativos possam fazer login
-- Cria registros em login_funcionarios onde não existem
-- ====================================================================

BEGIN;

-- 🔍 IDENTIFICAR EMPRESA
DO $$
DECLARE
  v_empresa_id UUID;
  v_funcionario RECORD;
  v_usuario TEXT;
  v_senha_padrao TEXT := 'Senha@123'; -- Senha padrão temporária
  v_count_criados INT := 0;
  v_count_atualizados INT := 0;
BEGIN
  -- Buscar empresa
  SELECT id INTO v_empresa_id 
  FROM empresas 
  WHERE email = 'assistenciaallimport10@gmail.com' 
  LIMIT 1;

  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Empresa não encontrada!';
  END IF;

  RAISE NOTICE '🏢 Empresa encontrada: %', v_empresa_id;
  RAISE NOTICE '🔧 Iniciando correção automática...';
  RAISE NOTICE '';

  -- 🔄 PROCESSAR CADA FUNCIONÁRIO ATIVO
  FOR v_funcionario IN 
    SELECT 
      f.id,
      f.nome,
      f.email,
      f.tipo_admin,
      lf.id as login_id,
      lf.usuario,
      lf.ativo
    FROM funcionarios f
    LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
    WHERE f.empresa_id = v_empresa_id
      AND f.status = 'ativo'
    ORDER BY f.nome
  LOOP
    -- Gerar nome de usuário baseado no primeiro nome (minúsculo, sem acentos)
    v_usuario := LOWER(
      REGEXP_REPLACE(
        TRANSLATE(
          SPLIT_PART(v_funcionario.nome, ' ', 1),
          'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
          'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
        ),
        '[^a-zA-Z0-9]',
        '',
        'g'
      )
    );

    -- Se o usuário ficar vazio, usar parte do email
    IF v_usuario = '' OR v_usuario IS NULL THEN
      v_usuario := SPLIT_PART(v_funcionario.email, '@', 1);
    END IF;

    -- ========================================
    -- CASO 1: NÃO TEM REGISTRO EM login_funcionarios
    -- ========================================
    IF v_funcionario.login_id IS NULL THEN
      RAISE NOTICE '➕ Criando login para: % (usuário: %)', v_funcionario.nome, v_usuario;
      
      INSERT INTO login_funcionarios (
        funcionario_id,
        usuario,
        senha_hash,
        ativo,
        precisa_trocar_senha,
        ultimo_acesso,
        tentativas_login,
        bloqueado_ate
      ) VALUES (
        v_funcionario.id,
        v_usuario,
        crypt(v_senha_padrao, gen_salt('bf')), -- Senha temporária com bcrypt
        true,
        true, -- Obriga trocar senha no primeiro login
        NULL,
        0,
        NULL
      );

      -- Atualizar flags no funcionario
      UPDATE funcionarios 
      SET 
        senha_definida = true,
        primeiro_acesso = true
      WHERE id = v_funcionario.id;

      v_count_criados := v_count_criados + 1;
      RAISE NOTICE '   ✅ Login criado com senha temporária (precisa_trocar_senha = true)';
      RAISE NOTICE '';

    -- ========================================
    -- CASO 2: TEM REGISTRO MAS ESTÁ INATIVO
    -- ========================================
    ELSIF v_funcionario.ativo = false THEN
      RAISE NOTICE '🔄 Ativando login para: % (usuário: %)', v_funcionario.nome, COALESCE(v_funcionario.usuario, v_usuario);
      
      UPDATE login_funcionarios 
      SET 
        ativo = true,
        usuario = COALESCE(usuario, v_usuario)
      WHERE funcionario_id = v_funcionario.id;

      v_count_atualizados := v_count_atualizados + 1;
      RAISE NOTICE '   ✅ Login ativado';
      RAISE NOTICE '';

    -- ========================================
    -- CASO 3: TEM REGISTRO MAS SEM CAMPO USUARIO
    -- ========================================
    ELSIF v_funcionario.usuario IS NULL THEN
      RAISE NOTICE '🔄 Definindo usuário para: % → %', v_funcionario.nome, v_usuario;
      
      UPDATE login_funcionarios 
      SET usuario = v_usuario
      WHERE funcionario_id = v_funcionario.id;

      v_count_atualizados := v_count_atualizados + 1;
      RAISE NOTICE '   ✅ Campo usuario definido';
      RAISE NOTICE '';

    ELSE
      -- Tudo OK, não faz nada
      RAISE NOTICE '✅ % já configurado corretamente (usuário: %)', v_funcionario.nome, v_funcionario.usuario;
    END IF;

  END LOOP;

  -- 📊 RESUMO FINAL
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 RESUMO DA CORREÇÃO';
  RAISE NOTICE '========================================';
  RAISE NOTICE '➕ Logins criados: %', v_count_criados;
  RAISE NOTICE '🔄 Logins atualizados: %', v_count_atualizados;
  RAISE NOTICE '';
  RAISE NOTICE '🔑 Senha padrão temporária: %', v_senha_padrao;
  RAISE NOTICE '⚠️  Funcionários com login criado precisarão trocar a senha no primeiro acesso';
  RAISE NOTICE '';

  -- 📋 LISTAR RESULTADO FINAL
  RAISE NOTICE '========================================';
  RAISE NOTICE '📋 FUNCIONÁRIOS CONFIGURADOS PARA LOGIN';
  RAISE NOTICE '========================================';
  
  RAISE NOTICE '';
END;
$$;

-- ✅ VALIDAR RESULTADO
SELECT 
  '✅ VALIDAÇÃO FINAL' as secao,
  f.nome,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.precisa_trocar_senha,
  CASE 
    WHEN f.status = 'ativo' AND lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN '✅ APARECERÁ NA TELA DE LOGIN'
    ELSE '❌ NÃO APARECERÁ'
  END as resultado
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
ORDER BY f.nome;

-- 🧪 TESTAR RPC
SELECT 
  '🧪 TESTE DA RPC listar_usuarios_ativos' as secao,
  nome,
  usuario,
  tipo_admin,
  senha_definida,
  primeiro_acesso
FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
)
ORDER BY nome;

COMMIT;

-- ====================================================================
-- 📝 NOTAS IMPORTANTES:
-- ====================================================================
-- 1. Todos os funcionários ativos terão login configurado
-- 2. Senha padrão temporária: "Senha@123" (com bcrypt)
-- 3. Flag precisa_trocar_senha = true para novos logins
-- 4. Campo "usuario" será o primeiro nome do funcionário (sem acentos)
-- 5. Logins serão ativados automaticamente
-- ====================================================================

-- ====================================================================
-- 🔐 INFORMAÇÕES DE SEGURANÇA:
-- ====================================================================
-- ⚠️  IMPORTANTE: Após executar este script, informe os funcionários
--    sobre a senha temporária e peça para trocarem no primeiro acesso.
-- 
-- 📧 MENSAGEM PARA FUNCIONÁRIOS:
--    "Seu login foi configurado. Use seu primeiro nome (minúsculo)
--     como usuário e a senha temporária 'Senha@123'.
--     Você será solicitado a trocar a senha no primeiro acesso."
-- ====================================================================
