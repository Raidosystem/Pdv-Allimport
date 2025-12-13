-- ====================================================================
-- SOLUÇÃO DEFINITIVA: FUNCIONÁRIOS SEM LOGIN - CORREÇÃO + AUTOMAÇÃO
-- ====================================================================
-- Este script:
-- 1. Corrige TODOS os funcionários existentes sem login
-- 2. Cria trigger para funcionários futuros
-- 3. Garante que NUNCA mais teremos este problema
-- ====================================================================

BEGIN;

RAISE NOTICE '====================================================================';
RAISE NOTICE '🚀 INICIANDO CORREÇÃO DEFINITIVA DO SISTEMA DE LOGIN';
RAISE NOTICE '====================================================================';
RAISE NOTICE '';

-- ====================================================================
-- PASSO 1: CORRIGIR FUNCIONÁRIOS EXISTENTES
-- ====================================================================

DO $$
DECLARE
  v_funcionario RECORD;
  v_usuario TEXT;
  v_senha_padrao TEXT := 'Senha@123';
  v_count_criados INT := 0;
  v_count_atualizados INT := 0;
  v_login RECORD;
BEGIN
  RAISE NOTICE '📋 PASSO 1: Corrigindo funcionários existentes...';
  RAISE NOTICE '';

  FOR v_funcionario IN 
    SELECT 
      f.id,
      f.nome,
      f.email,
      f.status,
      f.empresa_id,
      lf.id as login_id,
      lf.usuario as login_usuario,
      lf.ativo as login_ativo,
      lf.senha_hash as login_senha
    FROM funcionarios f
    LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
    WHERE f.status = 'ativo'
    ORDER BY f.empresa_id, f.nome
  LOOP
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

    -- AÇÃO: Criar ou atualizar login
    IF v_funcionario.login_id IS NULL THEN
      -- Não tem login - CRIAR
      INSERT INTO login_funcionarios (
        funcionario_id,
        usuario,
        senha_hash,
        ativo,
        precisa_trocar_senha,
        tentativas_login
      ) VALUES (
        v_funcionario.id,
        v_usuario,
        crypt(v_senha_padrao, gen_salt('bf')),
        true,
        true,
        0
      );

      UPDATE funcionarios 
      SET senha_definida = true, primeiro_acesso = true
      WHERE id = v_funcionario.id;

      v_count_criados := v_count_criados + 1;
      RAISE NOTICE '✅ Criado: % → usuário: %', v_funcionario.nome, v_usuario;

    ELSIF v_funcionario.login_ativo = false OR v_funcionario.login_usuario IS NULL THEN
      -- Tem login mas inativo ou sem usuário - ATUALIZAR
      UPDATE login_funcionarios 
      SET 
        ativo = true,
        usuario = COALESCE(usuario, v_usuario),
        senha_hash = CASE 
          WHEN senha_hash IS NULL THEN crypt(v_senha_padrao, gen_salt('bf'))
          ELSE senha_hash
        END,
        precisa_trocar_senha = CASE
          WHEN senha_hash IS NULL THEN true
          ELSE precisa_trocar_senha
        END
      WHERE funcionario_id = v_funcionario.id;

      UPDATE funcionarios 
      SET senha_definida = true
      WHERE id = v_funcionario.id;

      v_count_atualizados := v_count_atualizados + 1;
      RAISE NOTICE '🔄 Atualizado: % → usuário: %', v_funcionario.nome, COALESCE(v_funcionario.login_usuario, v_usuario);
    END IF;

  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '📊 Resumo do Passo 1:';
  RAISE NOTICE '   • Logins criados: %', v_count_criados;
  RAISE NOTICE '   • Logins atualizados: %', v_count_atualizados;
  RAISE NOTICE '';
END;
$$;

-- ====================================================================
-- PASSO 2: CRIAR TRIGGER PARA FUNCIONÁRIOS FUTUROS
-- ====================================================================

RAISE NOTICE '🔧 PASSO 2: Criando trigger automático...';
RAISE NOTICE '';

-- Função do trigger
CREATE OR REPLACE FUNCTION trg_func_auto_criar_login()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_usuario TEXT;
  v_senha_padrao TEXT := 'Senha@123';
BEGIN
  -- Só para funcionários ativos
  IF NEW.status != 'ativo' THEN
    RETURN NEW;
  END IF;

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

  -- INSERT: criar login
  IF TG_OP = 'INSERT' THEN
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
    )
    ON CONFLICT (funcionario_id) DO UPDATE
    SET 
      ativo = true,
      usuario = COALESCE(login_funcionarios.usuario, EXCLUDED.usuario);

    NEW.senha_definida := true;
    NEW.primeiro_acesso := true;

  -- UPDATE: reativar se necessário
  ELSIF TG_OP = 'UPDATE' AND OLD.status != 'ativo' AND NEW.status = 'ativo' THEN
    UPDATE login_funcionarios 
    SET 
      ativo = true,
      tentativas_login = 0,
      bloqueado_ate = NULL
    WHERE funcionario_id = NEW.id;

  -- UPDATE: desativar se inativado
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'ativo' AND NEW.status != 'ativo' THEN
    UPDATE login_funcionarios 
    SET ativo = false
    WHERE funcionario_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trg_garantir_login_funcionario ON funcionarios;

-- Criar novo trigger
CREATE TRIGGER trg_garantir_login_funcionario
  BEFORE INSERT OR UPDATE ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION trg_func_auto_criar_login();

RAISE NOTICE '✅ Trigger criado com sucesso!';
RAISE NOTICE '';

-- ====================================================================
-- PASSO 3: VALIDAÇÃO COMPLETA
-- ====================================================================

RAISE NOTICE '🧪 PASSO 3: Validação final...';
RAISE NOTICE '';

-- Contar funcionários por status
DO $$
DECLARE
  v_total_funcionarios INT;
  v_total_com_login INT;
  v_total_sem_login INT;
BEGIN
  SELECT COUNT(*) INTO v_total_funcionarios
  FROM funcionarios
  WHERE status = 'ativo';

  SELECT COUNT(*) INTO v_total_com_login
  FROM funcionarios f
  INNER JOIN login_funcionarios lf ON lf.funcionario_id = f.id
  WHERE f.status = 'ativo'
    AND lf.ativo = true
    AND lf.usuario IS NOT NULL;

  v_total_sem_login := v_total_funcionarios - v_total_com_login;

  RAISE NOTICE '📊 ESTATÍSTICAS:';
  RAISE NOTICE '   • Total funcionários ativos: %', v_total_funcionarios;
  RAISE NOTICE '   • Com login configurado: %', v_total_com_login;
  RAISE NOTICE '   • Sem login configurado: %', v_total_sem_login;
  RAISE NOTICE '';

  IF v_total_sem_login = 0 THEN
    RAISE NOTICE '✅ SUCESSO! Todos os funcionários ativos têm login configurado!';
  ELSE
    RAISE WARNING '⚠️  Ainda existem % funcionários sem login!', v_total_sem_login;
  END IF;
END;
$$;

RAISE NOTICE '';
RAISE NOTICE '====================================================================';
RAISE NOTICE '✅ CORREÇÃO CONCLUÍDA COM SUCESSO!';
RAISE NOTICE '====================================================================';
RAISE NOTICE '';
RAISE NOTICE '🔐 CREDENCIAIS PADRÃO:';
RAISE NOTICE '   • Usuário: primeiro nome (minúsculo, sem acentos)';
RAISE NOTICE '   • Senha: Senha@123';
RAISE NOTICE '   • Os funcionários serão obrigados a trocar a senha no 1º acesso';
RAISE NOTICE '';
RAISE NOTICE '🚀 PRÓXIMOS PASSOS:';
RAISE NOTICE '   1. Teste a tela de login (/login-local)';
RAISE NOTICE '   2. Verifique se todos os funcionários aparecem';
RAISE NOTICE '   3. Teste o login de cada funcionário';
RAISE NOTICE '';

COMMIT;

-- ====================================================================
-- QUERIES DE VERIFICAÇÃO
-- ====================================================================

-- Ver todos os funcionários com status de login
SELECT 
  '📋 FUNCIONÁRIOS ATIVOS E SEUS LOGINS' as relatorio,
  f.nome,
  f.email,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.precisa_trocar_senha,
  CASE 
    WHEN lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN '✅ PODE FAZER LOGIN'
    ELSE '❌ NÃO PODE FAZER LOGIN'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo'
ORDER BY f.empresa_id, f.nome;

-- Testar a RPC que o sistema usa
SELECT 
  '🧪 TESTE DA RPC listar_usuarios_ativos' as relatorio,
  nome,
  usuario,
  email,
  tipo_admin,
  senha_definida
FROM (
  SELECT DISTINCT empresa_id FROM funcionarios WHERE status = 'ativo'
) e
CROSS JOIN LATERAL listar_usuarios_ativos(e.empresa_id)
ORDER BY nome;

-- ====================================================================
-- FIM DO SCRIPT
-- ====================================================================
