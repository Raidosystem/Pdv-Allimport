-- =====================================================
-- CORRIGIR validar_senha_local - ADICIONAR search_path
-- =====================================================

-- 1. GARANTIR QUE pgcrypto ESTÁ HABILITADA
-- =====================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. RECRIAR FUNÇÃO validar_senha_local COM SCHEMA CORRETO
-- =====================================================
DROP FUNCTION IF EXISTS public.validar_senha_local(TEXT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.validar_senha_local(
  p_usuario TEXT,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
  v_login_record RECORD;
  v_funcionario_record RECORD;
  v_result JSON;
BEGIN
  -- Buscar login do funcionário pelo usuário
  SELECT * INTO v_login_record
  FROM public.login_funcionarios
  WHERE usuario = p_usuario
    AND ativo = true;

  -- Verificar se login existe
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado ou inativo'
    );
  END IF;

  -- Validar senha usando bcrypt (crypt compara automaticamente)
  IF v_login_record.senha != crypt(p_senha, v_login_record.senha) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Senha incorreta'
    );
  END IF;

  -- Buscar dados completos do funcionário
  SELECT 
    f.id,
    f.empresa_id,
    f.nome,
    f.email,
    f.telefone,
    f.cargo,
    f.funcao_id,
    f.ativo,
    f.permissoes,
    fn.nome as funcao_nome,
    fn.nivel as funcao_nivel
  INTO v_funcionario_record
  FROM public.funcionarios f
  LEFT JOIN public.funcoes fn ON fn.id = f.funcao_id
  WHERE f.id = v_login_record.funcionario_id
    AND f.ativo = true;

  -- Verificar se funcionário está ativo
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado ou inativo'
    );
  END IF;

  -- Retornar dados do funcionário autenticado
  RETURN json_build_object(
    'success', true,
    'funcionario', json_build_object(
      'id', v_funcionario_record.id,
      'empresa_id', v_funcionario_record.empresa_id,
      'nome', v_funcionario_record.nome,
      'email', v_funcionario_record.email,
      'telefone', v_funcionario_record.telefone,
      'cargo', v_funcionario_record.cargo,
      'funcao_id', v_funcionario_record.funcao_id,
      'funcao_nome', v_funcionario_record.funcao_nome,
      'funcao_nivel', v_funcionario_record.funcao_nivel,
      'permissoes', v_funcionario_record.permissoes
    ),
    'login_id', v_login_record.id
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Erro ao validar senha: ' || SQLERRM
    );
END;
$$;

-- 3. GARANTIR PERMISSÕES
-- =====================================================
GRANT EXECUTE ON FUNCTION public.validar_senha_local(TEXT, TEXT) TO anon, authenticated;

-- 4. CRIAR LOGIN PARA FUNCIONÁRIO (Cristiano)
-- =====================================================
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
  'cristiano',
  crypt('123456', gen_salt('bf')),
  true,
  now(),
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM login_funcionarios 
  WHERE funcionario_id = '1cb59030-2cd8-4988-a712-57f1e326c180'
);

-- 5. TESTAR FUNÇÃO crypt DIRETAMENTE
-- =====================================================
SELECT 
  'Teste crypt()' as teste,
  crypt('123456', gen_salt('bf')) as senha_criptografada;

-- 6. VERIFICAR LOGIN CRIADO
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

-- 7. TESTAR LOGIN NOVAMENTE
-- =====================================================
SELECT validar_senha_local('cristiano', '123456');

-- 8. RESULTADO
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ FUNÇÃO CORRIGIDA E LOGIN CRIADO!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Credenciais:';
  RAISE NOTICE '   Usuário: cristiano';
  RAISE NOTICE '   Senha: 123456';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Mudanças aplicadas:';
  RAISE NOTICE '   • Extensão pgcrypto habilitada em múltiplos schemas';
  RAISE NOTICE '   • Função validar_senha_local recriada com search_path correto';
  RAISE NOTICE '   • Login criado para Cristiano';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
