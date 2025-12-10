-- ============================================
-- 🚀 SISTEMA COMPLETO: CRIAR FUNCIONÁRIO COM CONTA AUTH
-- ============================================
-- Este script cria funcionários com conta no Supabase Auth
-- Permite login persistente e edição de permissões
-- ============================================

CREATE OR REPLACE FUNCTION criar_funcionario_com_auth(
  p_nome text,
  p_email text,
  p_senha text,
  p_empresa_id uuid,
  p_funcao_id uuid,
  p_cpf text DEFAULT NULL,
  p_telefone text DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_auth_user_id uuid;
  v_funcionario_id uuid;
  v_result json;
BEGIN
  RAISE NOTICE '🔧 Criando funcionário: %', p_nome;
  
  -- 1. Criar usuário no auth.users do Supabase
  -- NOTA: Isso precisa ser feito via Admin API do Supabase
  -- Por enquanto, retornar instruções
  
  RAISE NOTICE '⚠️  ATENÇÃO: Esta função prepara os dados.';
  RAISE NOTICE '   Para criar conta no auth.users, use:';
  RAISE NOTICE '   1. Painel Supabase > Authentication > Users';
  RAISE NOTICE '   2. Ou use a Admin API do Supabase';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Dados do funcionário:';
  RAISE NOTICE '   Nome: %', p_nome;
  RAISE NOTICE '   Email: %', p_email;
  RAISE NOTICE '   Senha: %', p_senha;
  RAISE NOTICE '   Empresa: %', p_empresa_id;
  RAISE NOTICE '   Função: %', p_funcao_id;
  
  -- 2. Verificar se email já existe
  IF EXISTS (SELECT 1 FROM funcionarios WHERE email = p_email) THEN
    RAISE EXCEPTION 'Email % já cadastrado', p_email;
  END IF;
  
  -- 3. Criar registro em funcionarios (sem user_id por enquanto)
  INSERT INTO funcionarios (
    nome,
    email,
    empresa_id,
    funcao_id,
    cpf,
    telefone,
    status,
    tipo_admin
  ) VALUES (
    p_nome,
    p_email,
    p_empresa_id,
    p_funcao_id,
    p_cpf,
    p_telefone,
    'ativo',
    NULL  -- Funcionário normal
  )
  RETURNING id INTO v_funcionario_id;
  
  RAISE NOTICE '✅ Funcionário criado no banco: %', v_funcionario_id;
  RAISE NOTICE '';
  RAISE NOTICE '🔑 PRÓXIMO PASSO:';
  RAISE NOTICE '   1. Crie conta no Supabase Auth com email: %', p_email;
  RAISE NOTICE '   2. Execute: UPDATE funcionarios SET user_id = ''[user_id_gerado]'' WHERE id = ''%'';', v_funcionario_id;
  
  RETURN json_build_object(
    'success', true,
    'funcionario_id', v_funcionario_id,
    'email', p_email,
    'next_step', 'create_auth_user'
  );
  
END;
$$;

-- ============================================
-- 📝 EXEMPLO DE USO
-- ============================================
/*
SELECT criar_funcionario_com_auth(
  'João Silva',                    -- nome
  'joao@example.com',              -- email
  '123456',                        -- senha
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',  -- empresa_id (substitua)
  '[funcao_id]',                   -- funcao_id (ID da função Vendedor, Caixa, etc)
  '123.456.789-00',                -- cpf (opcional)
  '(11) 98765-4321'                -- telefone (opcional)
);
*/

-- ============================================
-- 🔧 ATUALIZAR FUNCIONÁRIO COM USER_ID
-- ============================================
CREATE OR REPLACE FUNCTION vincular_auth_user_funcionario(
  p_funcionario_id uuid,
  p_auth_user_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RAISE NOTICE '🔗 Vinculando auth.user % ao funcionário %', p_auth_user_id, p_funcionario_id;
  
  -- Atualizar funcionário com user_id
  UPDATE funcionarios
  SET user_id = p_auth_user_id,
      updated_at = NOW()
  WHERE id = p_funcionario_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Funcionário % não encontrado', p_funcionario_id;
  END IF;
  
  RAISE NOTICE '✅ Funcionário vinculado com sucesso!';
  RAISE NOTICE '   Agora ele pode fazer login com email/senha';
  
  RETURN json_build_object(
    'success', true,
    'funcionario_id', p_funcionario_id,
    'user_id', p_auth_user_id
  );
END;
$$;

-- ============================================
-- 📊 VERIFICAR FUNCIONÁRIOS SEM AUTH
-- ============================================
SELECT 
  '⚠️  FUNCIONÁRIOS SEM CONTA AUTH' as alerta,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.status,
  fc.nome as funcao,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ PRECISA CRIAR CONTA'
    ELSE '✅ JÁ TEM CONTA'
  END as status_auth
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.tipo_admin IS NULL  -- Apenas funcionários (não admins)
ORDER BY f.created_at DESC;
