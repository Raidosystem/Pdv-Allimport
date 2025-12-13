-- ====================================================================
-- CORREÇÃO UNIVERSAL: HABILITAR LOGIN PARA QUALQUER FUNCIONÁRIO
-- ====================================================================
-- Este script pode ser executado para QUALQUER funcionário que não
-- está aparecendo na tela de login. Funciona para funcionários
-- existentes e futuros.
-- ====================================================================

BEGIN;

-- 🔧 FUNÇÃO HELPER: Criar/Atualizar Login de Funcionário
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
  v_mensagem TEXT;
BEGIN
  -- Buscar funcionário
  SELECT id, nome, email, status, empresa_id, tipo_admin
  INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT false, '❌ Funcionário não encontrado', NULL::TEXT;
    RETURN;
  END IF;

  IF v_funcionario.status != 'ativo' THEN
    RETURN QUERY SELECT false, '❌ Funcionário está inativo', NULL::TEXT;
    RETURN;
  END IF;

  -- Verificar se já tem login
  SELECT id, usuario, ativo, senha_hash
  INTO v_login
  FROM login_funcionarios
  WHERE funcionario_id = p_funcionario_id;

  -- Gerar nome de usuário
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

  -- CASO 1: Não existe registro - CRIAR
  IF v_login.id IS NULL THEN
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

    v_mensagem := format('✅ Login criado para %s (usuário: %s, senha: %s)', 
      v_funcionario.nome, v_usuario, p_senha_padrao);
    
    RETURN QUERY SELECT true, v_mensagem, v_usuario;
    RETURN;
  END IF;

  -- CASO 2: Existe mas está inativo ou sem usuário - ATUALIZAR
  IF v_login.ativo = false OR v_login.usuario IS NULL THEN
    UPDATE login_funcionarios 
    SET 
      ativo = true,
      usuario = COALESCE(usuario, v_usuario),
      senha_hash = CASE 
        WHEN senha_hash IS NULL THEN crypt(p_senha_padrao, gen_salt('bf'))
        ELSE senha_hash
      END,
      precisa_trocar_senha = CASE
        WHEN senha_hash IS NULL THEN true
        ELSE precisa_trocar_senha
      END
    WHERE funcionario_id = p_funcionario_id;

    UPDATE funcionarios 
    SET senha_definida = true
    WHERE id = p_funcionario_id;

    v_mensagem := format('✅ Login atualizado para %s (usuário: %s)', 
      v_funcionario.nome, COALESCE(v_login.usuario, v_usuario));
    
    RETURN QUERY SELECT true, v_mensagem, COALESCE(v_login.usuario, v_usuario);
    RETURN;
  END IF;

  -- CASO 3: Já está tudo OK
  v_mensagem := format('ℹ️  %s já tem login configurado (usuário: %s)', 
    v_funcionario.nome, v_login.usuario);
  
  RETURN QUERY SELECT true, v_mensagem, v_login.usuario;
END;
$$;

-- ====================================================================
-- 🎯 APLICAÇÃO: CORRIGIR TODOS OS FUNCIONÁRIOS DA EMPRESA
-- ====================================================================

DO $$
DECLARE
  v_empresa_id UUID;
  v_funcionario RECORD;
  v_resultado RECORD;
BEGIN
  -- Buscar empresa
  SELECT id INTO v_empresa_id 
  FROM empresas 
  WHERE email = 'assistenciaallimport10@gmail.com' 
  LIMIT 1;

  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Empresa não encontrada';
  END IF;

  RAISE NOTICE '🏢 Empresa: %', v_empresa_id;
  RAISE NOTICE '🔧 Corrigindo logins de todos os funcionários ativos...';
  RAISE NOTICE '';

  -- Processar cada funcionário ativo
  FOR v_funcionario IN 
    SELECT id, nome 
    FROM funcionarios 
    WHERE empresa_id = v_empresa_id 
      AND status = 'ativo'
    ORDER BY nome
  LOOP
    -- Aplicar correção
    SELECT * INTO v_resultado
    FROM garantir_login_funcionario(v_funcionario.id);

    RAISE NOTICE '%', v_resultado.mensagem;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CORREÇÃO CONCLUÍDA';
  RAISE NOTICE '========================================';
END;
$$;

-- ====================================================================
-- ✅ VALIDAÇÃO FINAL
-- ====================================================================

SELECT 
  '📋 FUNCIONÁRIOS APÓS CORREÇÃO' as secao,
  f.nome,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.precisa_trocar_senha,
  f.senha_definida,
  CASE 
    WHEN f.status = 'ativo' AND lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN '✅ VAI APARECER NA TELA'
    ELSE '❌ NÃO VAI APARECER'
  END as status_login
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
AND f.status = 'ativo'
ORDER BY f.nome;

-- 🧪 Testar RPC que o sistema usa
SELECT 
  '🧪 TESTE RPC (O QUE O SISTEMA VÊ)' as secao,
  nome,
  usuario,
  email,
  tipo_admin,
  senha_definida,
  primeiro_acesso
FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
)
ORDER BY nome;

COMMIT;

-- ====================================================================
-- 📚 COMO USAR ESTE SCRIPT PARA NOVOS FUNCIONÁRIOS:
-- ====================================================================
-- 
-- OPÇÃO 1: Corrigir um funcionário específico
-- SELECT * FROM garantir_login_funcionario('[ID_DO_FUNCIONARIO]'::UUID);
--
-- OPÇÃO 2: Corrigir todos os funcionários ativos
-- Execute este script completo (já faz isso automaticamente)
--
-- OPÇÃO 3: Criar trigger para aplicar automaticamente
-- (será implementado no próximo passo se necessário)
--
-- ====================================================================

-- ====================================================================
-- 🔐 CREDENCIAIS PADRÃO:
-- ====================================================================
-- Usuário: primeiro nome do funcionário (minúsculo, sem acentos)
-- Senha: Senha@123
-- Obrigado a trocar senha no primeiro acesso
-- ====================================================================
