-- =====================================================
-- MIGRAÇÃO: Criar logins para funcionários existentes
-- =====================================================

-- 1. VERIFICAR FUNCIONÁRIOS SEM LOGIN
-- =====================================================
SELECT 
  f.id,
  f.nome,
  f.email,
  CASE WHEN lf.id IS NULL THEN '❌ Sem login' ELSE '✅ Com login' END as status_login
FROM public.funcionarios f
LEFT JOIN public.login_funcionarios lf ON f.id = lf.funcionario_id
ORDER BY f.created_at DESC;

-- 2. CRIAR LOGINS AUTOMÁTICOS (EXEMPLO)
-- =====================================================
-- ⚠️ ATENÇÃO: Este script cria logins com senhas padrão
-- Você deve alterar as senhas após a criação!

DO $$
DECLARE
  v_funcionario RECORD;
  v_usuario TEXT;
  v_senha_padrao TEXT := 'Mudar@123'; -- SENHA PADRÃO - ALTERAR DEPOIS!
  v_contador INTEGER := 0;
BEGIN
  -- Para cada funcionário sem login
  FOR v_funcionario IN 
    SELECT f.* 
    FROM public.funcionarios f
    LEFT JOIN public.login_funcionarios lf ON f.id = lf.funcionario_id
    WHERE lf.id IS NULL
      AND f.ativo = true
  LOOP
    -- Gerar usuário baseado no email (antes do @)
    v_usuario := SPLIT_PART(v_funcionario.email, '@', 1);
    
    -- Se já existir, adicionar sufixo
    WHILE EXISTS (SELECT 1 FROM public.login_funcionarios WHERE usuario = v_usuario) LOOP
      v_usuario := v_usuario || '_' || floor(random() * 100)::text;
    END LOOP;

    -- Criar login
    INSERT INTO public.login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      ativo,
      created_at
    ) VALUES (
      v_funcionario.id,
      v_usuario,
      crypt(v_senha_padrao, gen_salt('bf')),
      true,
      now()
    );

    v_contador := v_contador + 1;
    RAISE NOTICE 'Login criado: % (Func: %)', v_usuario, v_funcionario.nome;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de logins criados: %', v_contador;
  RAISE NOTICE '⚠️ SENHA PADRÃO: %', v_senha_padrao;
  RAISE NOTICE '⚠️ ALTERE AS SENHAS IMEDIATAMENTE!';
END $$;

-- 3. LISTAR TODOS OS LOGINS CRIADOS
-- =====================================================
SELECT 
  f.nome as funcionario_nome,
  f.email,
  lf.usuario,
  CASE WHEN lf.ativo THEN '✅ Ativo' ELSE '❌ Inativo' END as status,
  lf.created_at as login_criado_em
FROM public.login_funcionarios lf
INNER JOIN public.funcionarios f ON lf.funcionario_id = f.id
ORDER BY lf.created_at DESC;

-- 4. FUNÇÃO PARA ALTERAR SENHA DE FUNCIONÁRIO
-- =====================================================
CREATE OR REPLACE FUNCTION public.alterar_senha_funcionario(
  p_funcionario_id UUID,
  p_senha_nova TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Verificar se o usuário tem permissão (é da mesma empresa)
  v_empresa_id := auth.uid();
  
  IF NOT EXISTS (
    SELECT 1 FROM public.funcionarios 
    WHERE id = p_funcionario_id 
      AND empresa_id = v_empresa_id
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado ou sem permissão'
    );
  END IF;

  -- Atualizar senha
  UPDATE public.login_funcionarios
  SET senha = crypt(p_senha_nova, gen_salt('bf')),
      updated_at = now()
  WHERE funcionario_id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Login não encontrado para este funcionário'
    );
  END IF;

  RETURN json_build_object(
    'success', true,
    'message', 'Senha alterada com sucesso'
  );
END;
$$;

-- Expor função na API
GRANT EXECUTE ON FUNCTION public.alterar_senha_funcionario TO authenticated;

-- 5. FUNÇÃO PARA RESETAR SENHA (GERAR AUTOMÁTICA)
-- =====================================================
CREATE OR REPLACE FUNCTION public.resetar_senha_funcionario(
  p_funcionario_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_empresa_id UUID;
  v_senha_temp TEXT;
BEGIN
  -- Verificar permissão
  v_empresa_id := auth.uid();
  
  IF NOT EXISTS (
    SELECT 1 FROM public.funcionarios 
    WHERE id = p_funcionario_id 
      AND empresa_id = v_empresa_id
  ) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado ou sem permissão'
    );
  END IF;

  -- Gerar senha temporária (8 caracteres aleatórios)
  v_senha_temp := substring(md5(random()::text) from 1 for 8);

  -- Atualizar senha
  UPDATE public.login_funcionarios
  SET senha = crypt(v_senha_temp, gen_salt('bf')),
      updated_at = now()
  WHERE funcionario_id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Login não encontrado para este funcionário'
    );
  END IF;

  RETURN json_build_object(
    'success', true,
    'senha_temporaria', v_senha_temp,
    'message', 'Senha resetada. Informe a senha temporária ao funcionário.'
  );
END;
$$;

-- Expor função na API
GRANT EXECUTE ON FUNCTION public.resetar_senha_funcionario TO authenticated;

RAISE NOTICE '✅ Script de migração preparado!';
RAISE NOTICE '';
RAISE NOTICE '🔧 Para executar:';
RAISE NOTICE '   1. Execute o bloco DO $$ para criar logins automáticos';
RAISE NOTICE '   2. Use alterar_senha_funcionario() para mudar senhas';
RAISE NOTICE '   3. Use resetar_senha_funcionario() para gerar senhas temporárias';
