-- ====================================================================
-- ✅ CORREÇÃO COMPLETA: Criar Login para Todos os Funcionários
-- ====================================================================
-- Execute este script NO SQL EDITOR DO SUPABASE
-- ====================================================================

-- Passo 1: Criar função helper
CREATE OR REPLACE FUNCTION garantir_login_funcionario(
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
    RETURN QUERY SELECT false, 'Funcionário não encontrado'::TEXT, NULL::TEXT;
    RETURN;
  END IF;

  IF v_funcionario.status != 'ativo' THEN
    RETURN QUERY SELECT false, 'Funcionário inativo'::TEXT, NULL::TEXT;
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
    INSERT INTO login_funcionarios (
      funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha, tentativas_login
    ) VALUES (
      p_funcionario_id, v_usuario, crypt(p_senha_padrao, gen_salt('bf')), true, true, 0
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
      senha_hash = CASE WHEN senha_hash IS NULL THEN crypt(p_senha_padrao, gen_salt('bf')) ELSE senha_hash END
    WHERE funcionario_id = p_funcionario_id;

    UPDATE funcionarios SET senha_definida = true WHERE id = p_funcionario_id;

    RETURN QUERY SELECT true, format('ATUALIZADO: %s -> %s', v_funcionario.nome, v_usuario), v_usuario;
  
  ELSE
    RETURN QUERY SELECT true, format('OK: %s (%s)', v_funcionario.nome, v_login.usuario), v_login.usuario;
  END IF;
END;
$$;

-- Passo 2: Aplicar correção em todos os funcionários
DO $$
DECLARE
  v_funcionario RECORD;
  v_resultado RECORD;
  v_count_criados INT := 0;
  v_count_atualizados INT := 0;
  v_count_ok INT := 0;
BEGIN
  RAISE NOTICE '=== Processando funcionários ===';

  FOR v_funcionario IN 
    SELECT id, nome 
    FROM funcionarios 
    WHERE status = 'ativo'
    ORDER BY empresa_id, nome
  LOOP
    SELECT * INTO v_resultado FROM garantir_login_funcionario(v_funcionario.id);
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
  RAISE NOTICE 'Logins criados: %', v_count_criados;
  RAISE NOTICE 'Logins atualizados: %', v_count_atualizados;
  RAISE NOTICE 'Ja estavam OK: %', v_count_ok;
END;
$$;

-- Passo 3: Criar trigger automático
CREATE OR REPLACE FUNCTION trg_func_auto_login()
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
      funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha, tentativas_login
    ) VALUES (
      NEW.id, v_usuario, crypt(v_senha_padrao, gen_salt('bf')), true, true, 0
    );
    NEW.senha_definida := true;
    NEW.primeiro_acesso := true;
  
  ELSIF TG_OP = 'UPDATE' AND OLD.status != 'ativo' AND NEW.status = 'ativo' THEN
    IF v_login_existe THEN
      UPDATE login_funcionarios SET ativo = true, tentativas_login = 0 WHERE funcionario_id = NEW.id;
    ELSE
      INSERT INTO login_funcionarios (
        funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha, tentativas_login
      ) VALUES (
        NEW.id, v_usuario, crypt(v_senha_padrao, gen_salt('bf')), true, true, 0
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
  EXECUTE FUNCTION trg_func_auto_login();

-- Passo 4: Validação
SELECT 
  'VALIDACAO FINAL' as relatorio,
  COUNT(*) as total_ativos,
  COUNT(lf.id) as com_login,
  COUNT(CASE WHEN lf.ativo = true AND lf.usuario IS NOT NULL THEN 1 END) as login_funcional
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo';

SELECT 
  'LISTA DE FUNCIONARIOS' as relatorio,
  f.nome,
  lf.usuario,
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
  RAISE NOTICE '=== CORRECAO COMPLETA ===';
  RAISE NOTICE 'Todos os funcionarios ativos tem login configurado';
  RAISE NOTICE 'Trigger automatico criado para futuros funcionarios';
  RAISE NOTICE '';
  RAISE NOTICE 'Credenciais padrao:';
  RAISE NOTICE '  Usuario: primeiro nome (minusculo)';
  RAISE NOTICE '  Senha: Senha@123';
  RAISE NOTICE '  Trocar senha obrigatorio no 1o acesso';
  RAISE NOTICE '';
  RAISE NOTICE 'Teste em: https://pdv.gruporaval.com.br/login-local';
END;
$$;
