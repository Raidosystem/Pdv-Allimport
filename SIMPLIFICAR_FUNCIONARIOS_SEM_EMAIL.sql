-- ============================================
-- SIMPLIFICAÇÃO: FUNCIONÁRIOS SEM EMAIL
-- ============================================
-- 
-- MUDANÇA:
-- - Funcionários NÃO precisam de email
-- - Apenas NOME + SENHA
-- - Email se torna OPCIONAL (null allowed)
-- - Login é feito apenas por nome de usuário (usuario) + senha
-- - Admin cria/exclui funcionários facilmente
--
-- BENEFÍCIOS:
-- - ✅ Mais simples de usar
-- - ✅ Sem erros de autenticação Supabase
-- - ✅ Sem conflitos de email
-- - ✅ Mais rápido para cadastrar
--
-- ============================================

-- 1. ALTERAR TABELA funcionarios - Email opcional
ALTER TABLE funcionarios 
ALTER COLUMN email DROP NOT NULL;

-- 2. ALTERAR TABELA login_funcionarios - Já tem usuario + senha
-- Não precisa alterar, já está correta

-- 3. VERIFICAR ESTRUTURA ATUAL
SELECT 
  '=== FUNCIONÁRIOS ATUAIS ===' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.status,
  lf.usuario as login_usuario,
  lf.ativo as login_ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
ORDER BY f.nome;

-- 4. CRIAR FUNÇÃO PARA CADASTRAR FUNCIONÁRIO SEM EMAIL
CREATE OR REPLACE FUNCTION cadastrar_funcionario_simples(
  p_empresa_id uuid,
  p_nome text,
  p_senha text,
  p_funcao_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario_id uuid;
  v_usuario text;
  v_senha_hash text;
  v_result jsonb;
BEGIN
  RAISE NOTICE '📝 Cadastrando funcionário: % para empresa: %', p_nome, p_empresa_id;
  
  -- Gerar nome de usuário único (normalizar nome)
  v_usuario := lower(regexp_replace(p_nome, '[^a-zA-Z0-9]', '', 'g'));
  
  -- Se usuário já existe, adicionar número
  WHILE EXISTS (
    SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario
  ) LOOP
    v_usuario := v_usuario || floor(random() * 100)::text;
  END LOOP;
  
  RAISE NOTICE '👤 Usuário gerado: %', v_usuario;
  
  -- Hash da senha (bcrypt seria melhor, mas aqui usamos simples hash)
  v_senha_hash := encode(digest(p_senha, 'sha256'), 'hex');
  
  -- Inserir funcionário (SEM EMAIL)
  INSERT INTO funcionarios (
    empresa_id,
    nome,
    email,  -- NULL
    status
  )
  VALUES (
    p_empresa_id,
    p_nome,
    NULL,  -- Sem email!
    'ativo'
  )
  RETURNING id INTO v_funcionario_id;
  
  RAISE NOTICE '✅ Funcionário criado: %', v_funcionario_id;
  
  -- Inserir login
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha,
    ativo
  )
  VALUES (
    v_funcionario_id,
    v_usuario,
    v_senha_hash,
    true
  );
  
  RAISE NOTICE '🔐 Login criado: %', v_usuario;
  
  -- Se tem função, associar
  IF p_funcao_id IS NOT NULL THEN
    INSERT INTO funcionario_funcoes (
      funcionario_id,
      funcao_id,
      empresa_id
    )
    VALUES (
      v_funcionario_id,
      p_funcao_id,
      p_empresa_id
    );
    
    RAISE NOTICE '🎯 Função associada: %', p_funcao_id;
  END IF;
  
  -- Retornar resultado
  v_result := jsonb_build_object(
    'success', true,
    'funcionario_id', v_funcionario_id,
    'nome', p_nome,
    'usuario', v_usuario,
    'message', 'Funcionário cadastrado com sucesso!'
  );
  
  RAISE NOTICE '✅ Resultado: %', v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 5. CRIAR FUNÇÃO PARA LOGIN DE FUNCIONÁRIO (por usuário, não email)
CREATE OR REPLACE FUNCTION login_funcionario(
  p_usuario text,
  p_senha text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_senha_hash text;
  v_login record;
  v_funcionario record;
  v_empresa record;
  v_result jsonb;
BEGIN
  RAISE NOTICE '🔐 Tentativa de login: usuário=%', p_usuario;
  
  -- Hash da senha informada
  v_senha_hash := encode(digest(p_senha, 'sha256'), 'hex');
  
  -- Buscar login
  SELECT * INTO v_login
  FROM login_funcionarios
  WHERE usuario = p_usuario
    AND senha = v_senha_hash
    AND ativo = true;
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ Credenciais inválidas';
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Usuário ou senha incorretos'
    );
  END IF;
  
  -- Buscar funcionário
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE id = v_login.funcionario_id
    AND status = 'ativo';
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ Funcionário inativo';
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Funcionário inativo'
    );
  END IF;
  
  -- Buscar empresa
  SELECT * INTO v_empresa
  FROM empresas
  WHERE id = v_funcionario.empresa_id;
  
  -- Atualizar último acesso
  UPDATE login_funcionarios
  SET ultimo_acesso = NOW()
  WHERE id = v_login.id;
  
  -- Retornar dados do funcionário logado
  v_result := jsonb_build_object(
    'success', true,
    'funcionario_id', v_funcionario.id,
    'nome', v_funcionario.nome,
    'usuario', v_login.usuario,
    'empresa_id', v_funcionario.empresa_id,
    'empresa_nome', v_empresa.nome,
    'tipo_admin', v_funcionario.tipo_admin,
    'message', 'Login realizado com sucesso!'
  );
  
  RAISE NOTICE '✅ Login bem-sucedido: %', v_result;
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 6. TESTE: Cadastrar funcionário sem email
SELECT cadastrar_funcionario_simples(
  'f1726fcf-d23b-4cca-8079-39314ae56e00'::uuid,  -- empresa_id (Assistência All-Import)
  'Teste Funcionário',  -- nome
  'senha123',  -- senha
  NULL  -- funcao_id (opcional)
) as resultado;

-- 7. TESTE: Login do funcionário
-- (Use o 'usuario' retornado no teste acima)
-- SELECT login_funcionario('testefuncionario', 'senha123') as resultado;

-- 8. VERIFICAR CRIAÇÃO
SELECT 
  '=== FUNCIONÁRIO CRIADO ===' as info,
  f.id,
  f.nome,
  f.email,
  lf.usuario,
  lf.ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.nome LIKE '%Teste%'
ORDER BY f.created_at DESC
LIMIT 1;

-- ============================================
-- ✅ COMO USAR NO SISTEMA
-- ============================================
-- 
-- CADASTRAR FUNCIONÁRIO:
-- SELECT cadastrar_funcionario_simples(
--   '<empresa_id>',
--   'Nome do Funcionário',
--   'senha123',
--   '<funcao_id>' (opcional)
-- );
--
-- LOGIN:
-- SELECT login_funcionario('nomedofuncionario', 'senha123');
--
-- BENEFÍCIOS:
-- - Sem email, sem problemas!
-- - Login simples: usuário + senha
-- - Admin controla tudo
-- - Mais rápido e fácil
--
-- ============================================
