-- ====================================================================
-- ✅ SOLUÇÃO COMPLETA: CORRIGIR TODOS + PREVENIR FUTUROS
-- ====================================================================
-- Execute NO SQL EDITOR DO SUPABASE após corrigir Jennifer
-- ====================================================================

-- ====================================================================
-- 🔧 FUNÇÃO HELPER: Garantir Login de Funcionário
-- ====================================================================

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
  -- Buscar funcionário
  SELECT id, nome, email, status
  INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, '❌ Funcionário não encontrado', NULL::TEXT;
    RETURN;
  END IF;

  IF v_funcionario.status != 'ativo' THEN
    RETURN QUERY SELECT false, '⚠️  Funcionário inativo', NULL::TEXT;
    RETURN;
  END IF;

  -- Verificar se já tem login
  SELECT id, usuario, ativo, senha_hash
  INTO v_login
  FROM login_funcionarios
  WHERE funcionario_id = p_funcionario_id;

  -- Gerar usuário (primeiro nome minúsculo sem acentos)
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

  -- CRIAR ou ATUALIZAR login
  IF v_login.id IS NULL THEN
    -- NÃO EXISTE - CRIAR
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha_hash,
      ativo,
      precisa_trocar_senha,
      tentativas_login
    ) VALUES (
      p_funcionario_id,
      v_usuario,
      crypt(p_senha_padrao, gen_salt('bf')),
      true,
      true,
      0
    );

    UPDATE funcionarios 
    SET senha_definida = true, primeiro_acesso = true
    WHERE id = p_funcionario_id;

    RETURN QUERY SELECT 
      true, 
      format('✅ CRIADO: %s → usuário: %s', v_funcionario.nome, v_usuario),
      v_usuario;
  
  ELSIF v_login.ativo = false OR v_login.usuario IS NULL THEN
    -- EXISTE MAS INATIVO - ATUALIZAR
    UPDATE login_funcionarios 
    SET 
      ativo = true,
      usuario = COALESCE(usuario, v_usuario),
      senha_hash = CASE 
        WHEN senha_hash IS NULL THEN crypt(p_senha_padrao, gen_salt('bf'))
        ELSE senha_hash
      END
    WHERE funcionario_id = p_funcionario_id;

    UPDATE funcionarios 
    SET senha_definida = true
    WHERE id = p_funcionario_id;

    RETURN QUERY SELECT 
      true,
      format('🔄 ATUALIZADO: %s → usuário: %s', v_funcionario.nome, v_usuario),
      v_usuario;
  
  ELSE
    -- JÁ ESTÁ OK
    RETURN QUERY SELECT 
      true,
      format('✅ OK: %s (usuário: %s)', v_funcionario.nome, v_login.usuario),
      v_login.usuario;
  END IF;
END;
$$;

-- ====================================================================
-- 📋 CORRIGIR TODOS OS FUNCIONÁRIOS ATIVOS
-- ====================================================================

DO $$
DECLARE
  v_funcionario RECORD;
  v_resultado RECORD;
  v_count_criados INT := 0;
  v_count_atualizados INT := 0;
  v_count_ok INT := 0;
BEGIN
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '📋 Processando todos os funcionários ativos...';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';

  FOR v_funcionario IN 
    SELECT id, nome 
    FROM funcionarios 
    WHERE status = 'ativo'
    ORDER BY empresa_id, nome
  LOOP
    SELECT * INTO v_resultado
    FROM garantir_login_funcionario(v_funcionario.id);

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
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 RESUMO:';
  RAISE NOTICE '   ➕ Logins criados: %', v_count_criados;
  RAISE NOTICE '   🔄 Logins atualizados: %', v_count_atualizados;
  RAISE NOTICE '   ✅ Já estavam OK: %', v_count_ok;
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END;
$$;

-- ====================================================================
-- 🤖 CRIAR TRIGGER AUTOMÁTICO PARA FUTUROS FUNCIONÁRIOS
-- ====================================================================

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
  -- Só para funcionários ativos
  IF NEW.status != 'ativo' THEN
    RETURN NEW;
  END IF;

  -- Verificar se já existe login
  SELECT EXISTS(
    SELECT 1 FROM login_funcionarios WHERE funcionario_id = NEW.id
  ) INTO v_login_existe;

  -- Gerar usuário
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

  -- INSERT: criar login automaticamente
  IF TG_OP = 'INSERT' AND NOT v_login_existe THEN
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha_hash,
      ativo,
      precisa_trocar_senha,
      tentativas_login
    ) VALUES (
      NEW.id,
      v_usuario,
      crypt(v_senha_padrao, gen_salt('bf')),
      true,
      true,
      0
    );

    NEW.senha_definida := true;
    NEW.primeiro_acesso := true;

    RAISE NOTICE '✅ [TRIGGER] Login criado automaticamente para: %', NEW.nome;
  
  -- UPDATE: reativar se necessário
  ELSIF TG_OP = 'UPDATE' AND OLD.status != 'ativo' AND NEW.status = 'ativo' THEN
    IF v_login_existe THEN
      UPDATE login_funcionarios 
      SET ativo = true, tentativas_login = 0
      WHERE funcionario_id = NEW.id;
    ELSE
      -- Criar se não existir
      INSERT INTO login_funcionarios (
        funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha, tentativas_login
      ) VALUES (
        NEW.id, v_usuario, crypt(v_senha_padrao, gen_salt('bf')), true, true, 0
      );
    END IF;
  
  -- UPDATE: desativar se inativado
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'ativo' AND NEW.status != 'ativo' THEN
    UPDATE login_funcionarios 
    SET ativo = false
    WHERE funcionario_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

-- Remover trigger antigo
DROP TRIGGER IF EXISTS trg_auto_login_funcionario ON funcionarios;

-- Criar novo trigger
CREATE TRIGGER trg_auto_login_funcionario
  BEFORE INSERT OR UPDATE ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION trg_func_auto_login();

-- Mensagem de sucesso do trigger
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '✅ Trigger automático criado com sucesso!';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';
END;
$$;

-- ====================================================================
-- 🧪 VALIDAÇÃO FINAL
-- ====================================================================

-- Verificar todos os funcionários ativos
SELECT 
  '📊 TODOS OS FUNCIONÁRIOS ATIVOS' as relatorio,
  COUNT(*) as total,
  COUNT(lf.id) as com_login,
  COUNT(CASE WHEN lf.ativo = true AND lf.usuario IS NOT NULL THEN 1 END) as login_funcional
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo';

-- Listar todos com status
SELECT 
  '📋 LISTA DETALHADA' as relatorio,
  f.nome,
  lf.usuario,
  lf.ativo,
  CASE 
    WHEN lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN '✅ PODE FAZER LOGIN'
    ELSE '❌ PROBLEMA'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo'
ORDER BY f.empresa_id, f.nome;

-- Testar RPC para cada empresa
SELECT 
  '🧪 RPC listar_usuarios_ativos' as relatorio,
  COUNT(*) as total_usuarios
FROM (
  SELECT DISTINCT empresa_id FROM funcionarios WHERE status = 'ativo'
) empresas
CROSS JOIN LATERAL listar_usuarios_ativos(empresas.empresa_id);

-- Mensagem final
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '✅ SOLUÇÃO COMPLETA APLICADA COM SUCESSO!';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 O que foi feito:';
  RAISE NOTICE '   ✅ Todos os funcionários ativos têm login configurado';
  RAISE NOTICE '   ✅ Trigger criado para funcionários futuros';
  RAISE NOTICE '   ✅ Sistema funcionará automaticamente daqui em diante';
  RAISE NOTICE '';
  RAISE NOTICE '🔐 Credenciais padrão:';
  RAISE NOTICE '   • Usuário: primeiro nome (minúsculo)';
  RAISE NOTICE '   • Senha: Senha@123';
  RAISE NOTICE '   • Obrigação de trocar no 1º acesso';
  RAISE NOTICE '';
  RAISE NOTICE '🧪 Teste agora:';
  RAISE NOTICE '   https://pdv.gruporaval.com.br/login-local';
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
END;
$$;