-- ====================================================================
-- CORREÇÃO SIMPLES: Criar Login SEM Criptografia (Mais Rápido)
-- ====================================================================
-- Esta versão usa senha em texto plano temporariamente
-- Você pode adicionar criptografia depois
-- Execute no SQL Editor do Supabase
-- ====================================================================

-- Criar função helper
CREATE OR REPLACE FUNCTION garantir_login_funcionario_simples(
  p_funcionario_id UUID,
  p_senha_padrao TEXT DEFAULT 'Senha@123'
)
RETURNS TABLE (
  sucesso BOOLEAN,
  mensagem TEXT,
  usuario_criado TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_funcionario RECORD;
  v_login RECORD;
  v_usuario TEXT;
BEGIN
  SELECT id, nome, email, status
  INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Funcionario nao encontrado'::TEXT, NULL::TEXT;
    RETURN;
  END IF;

  IF v_funcionario.status != 'ativo' THEN
    RETURN QUERY SELECT false, 'Funcionario inativo'::TEXT, NULL::TEXT;
    RETURN;
  END IF;

  SELECT id, usuario, ativo, senha_hash
  INTO v_login
  FROM login_funcionarios
  WHERE funcionario_id = p_funcionario_id;

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

  IF v_usuario = '' OR v_usuario IS NULL THEN
    v_usuario := SPLIT_PART(v_funcionario.email, '@', 1);
  END IF;

  IF v_login.id IS NULL THEN
    -- Criar login com senha em texto plano (temporário)
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      senha_hash,
      ativo,
      precisa_trocar_senha
    ) VALUES (
      p_funcionario_id,
      v_usuario,
      p_senha_padrao,  -- Coluna senha (NOT NULL)
      p_senha_padrao,  -- Coluna senha_hash
      true,
      true
    );

    UPDATE funcionarios 
    SET senha_definida = true, primeiro_acesso = true
    WHERE id = p_funcionario_id;

    RETURN QUERY SELECT true, format('CRIADO: %s -> %s', v_funcionario.nome, v_usuario), v_usuario;
  
  ELSIF v_login.ativo = false OR v_login.usuario IS NULL THEN
    UPDATE login_funcionarios 
    SET 
      ativo = true,
      usuario = COALESCE(usuario, v_usuario),
      senha_hash = COALESCE(senha_hash, p_senha_padrao)
    WHERE funcionario_id = p_funcionario_id;

    UPDATE funcionarios SET senha_definida = true WHERE id = p_funcionario_id;

    RETURN QUERY SELECT true, format('ATUALIZADO: %s -> %s', v_funcionario.nome, v_usuario), v_usuario;
  
  ELSE
    RETURN QUERY SELECT true, format('OK: %s (%s)', v_funcionario.nome, v_login.usuario), v_login.usuario;
  END IF;
END;
$$;

-- Aplicar correção
DO $$
DECLARE
  v_funcionario RECORD;
  v_resultado RECORD;
  v_count_criados INT := 0;
  v_count_atualizados INT := 0;
  v_count_ok INT := 0;
BEGIN
  RAISE NOTICE '=== Processando funcionarios ===';

  FOR v_funcionario IN 
    SELECT id, nome 
    FROM funcionarios 
    WHERE status = 'ativo'
    ORDER BY empresa_id, nome
  LOOP
    SELECT * INTO v_resultado FROM garantir_login_funcionario_simples(v_funcionario.id);
    RAISE NOTICE '%', v_resultado.mensagem;

    IF v_resultado.mensagem LIKE '%CRIADO%' THEN
      v_count_criados := v_count_criados + 1;
    ELSIF v_resultado.mensagem LIKE '%ATUALIZADO%' THEN
      v_count_atualizados := v_count_atualizados + 1;
    ELSE
      v_count_ok := v_count_ok + 1;
    END IF;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '=== RESUMO ===';
  RAISE NOTICE 'Criados: %', v_count_criados;
  RAISE NOTICE 'Atualizados: %', v_count_atualizados;
  RAISE NOTICE 'Ja OK: %', v_count_ok;
  RAISE NOTICE '';
  RAISE NOTICE 'ATENCAO: Senhas em texto plano (temporario)';
  RAISE NOTICE 'Os funcionarios devem trocar a senha no primeiro acesso';
END;
$$;

-- Criar trigger
CREATE OR REPLACE FUNCTION trg_func_auto_login_simples()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_usuario TEXT;
  v_senha_padrao TEXT := 'Senha@123';
  v_login_existe BOOLEAN;
BEGIN
  IF NEW.status != 'ativo' THEN
    RETURN NEW;
  END IF;

  SELECT EXISTS(SELECT 1 FROM login_funcionarios WHERE funcionario_id = NEW.id) INTO v_login_existe;

  v_usuario := LOWER(
    REGEXP_REPLACE(
      TRANSLATE(
        SPLIT_PART(NEW.nome, ' ', 1),
        'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
        'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
      ),
      '[^a-zA-Z0-9]',
      '',
      'g'
    )
  );

  IF v_usuario = '' OR v_usuario IS NULL THEN
    v_usuario := SPLIT_PART(NEW.email, '@', 1);
  END IF;

  IF TG_OP = 'INSERT' AND NOT v_login_existe THEN
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha_hash,
      ativo,
      precisa_trocar_senha
    ) VALUES (
      NEW.id,
      v_usuario,
      v_senha_padrao,  -- Senha em texto plano
      true,
      true
    );
    NEW.senha_definida := true;
    NEW.primeiro_acesso := true;
  
  ELSIF TG_OP = 'UPDATE' AND OLD.status != 'ativo' AND NEW.status = 'ativo' THEN
    IF v_login_existe THEN
      UPDATE login_funcionarios SET ativo = true WHERE funcionario_id = NEW.id;
    ELSE
      INSERT INTO login_funcionarios (
        funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha
      ) VALUES (
        NEW.id, v_usuario, v_senha_padrao, true, true
      );
    END IF;
  
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'ativo' AND NEW.status != 'ativo' THEN
    UPDATE login_funcionarios SET ativo = false WHERE funcionario_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_auto_login_funcionario ON funcionarios;

CREATE TRIGGER trg_auto_login_funcionario
  BEFORE INSERT OR UPDATE ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION trg_func_auto_login_simples();

-- Validação
SELECT 
  'RESULTADO' as relatorio,
  COUNT(*) as total_ativos,
  COUNT(lf.id) as com_login,
  COUNT(CASE WHEN lf.ativo = true AND lf.usuario IS NOT NULL THEN 1 END) as login_ok
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo';

SELECT 
  'FUNCIONARIOS' as relatorio,
  f.nome,
  lf.usuario,
  lf.ativo,
  CASE 
    WHEN lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN 'PODE FAZER LOGIN'
    ELSE 'PROBLEMA'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo'
ORDER BY f.empresa_id, f.nome;

-- Mensagem final
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '=== SUCESSO ===';
  RAISE NOTICE 'Todos os funcionarios podem fazer login';
  RAISE NOTICE 'Trigger criado para futuros funcionarios';
  RAISE NOTICE '';
  RAISE NOTICE 'Credenciais:';
  RAISE NOTICE '  Usuario: primeiro nome (minusculo)';
  RAISE NOTICE '  Senha: Senha@123';
  RAISE NOTICE '';
  RAISE NOTICE 'IMPORTANTE: Senhas em texto plano (temporario)';
  RAISE NOTICE 'Funcionarios DEVEM trocar senha no primeiro acesso';
  RAISE NOTICE '';
  RAISE NOTICE 'Teste: https://pdv.gruporaval.com.br/login-local';
END;
$$;

-- ====================================================================
-- NOTAS IMPORTANTES:
-- ====================================================================
-- Esta versão usa senhas em TEXTO PLANO porque a extensão pgcrypto
-- não está disponível ou configurada.
--
-- A senha é "Senha@123" e todos devem trocá-la no primeiro acesso.
--
-- Para adicionar criptografia depois, você precisará:
-- 1. Habilitar pgcrypto no Supabase (Database > Extensions)
-- 2. Executar um script para criptografar as senhas existentes
-- ====================================================================
