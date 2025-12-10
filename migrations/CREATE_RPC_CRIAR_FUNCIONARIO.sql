-- 🔧 CRIAR RPC criar_funcionario_completo - PARA ACTIVATEUSERSPAGE

-- ⚠️ PROBLEMA:
-- Frontend usa btoa() (Base64) para hash de senha
-- Banco usa crypt() (bcrypt) na validação
-- Senhas não batem!

-- ====================================
-- 1. CRIAR RPC PARA CRIAR FUNCIONÁRIO COMPLETO
-- ====================================
CREATE OR REPLACE FUNCTION criar_funcionario_completo(
  p_empresa_id UUID,
  p_nome TEXT,
  p_senha TEXT,
  p_funcao_id UUID,
  p_email TEXT DEFAULT NULL
)
RETURNS TABLE (
  sucesso BOOLEAN,
  funcionario_id UUID,
  usuario TEXT,
  mensagem TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario_id UUID;
  v_usuario TEXT;
  v_usuario_base TEXT;
  v_contador INTEGER := 1;
  v_usuario_existe BOOLEAN;
  v_senha_hash TEXT;
BEGIN
  -- Gerar nome de usuário base (sem espaços, minúsculas)
  v_usuario_base := LOWER(REPLACE(p_nome, ' ', ''));
  v_usuario := v_usuario_base;
  
  -- Verificar se usuário já existe e incrementar se necessário
  LOOP
    SELECT EXISTS (
      SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario
    ) INTO v_usuario_existe;
    
    IF NOT v_usuario_existe THEN
      EXIT;
    END IF;
    
    v_usuario := v_usuario_base || v_contador::TEXT;
    v_contador := v_contador + 1;
  END LOOP;
  
  -- Hash da senha usando bcrypt
  v_senha_hash := crypt(p_senha, gen_salt('bf'));
  
  -- Criar funcionário
  INSERT INTO funcionarios (
    empresa_id,
    nome,
    email,
    status,
    tipo_admin,
    usuario_ativo,
    senha_definida,
    primeiro_acesso,
    funcao_id
  )
  VALUES (
    p_empresa_id,
    p_nome,
    p_email,
    'ativo',
    'funcionario',
    true,  -- ✅ Ativo para aparecer no login
    true,  -- ✅ Senha definida
    true,  -- ✅ Primeiro acesso (pode trocar senha depois)
    p_funcao_id
  )
  RETURNING id INTO v_funcionario_id;
  
  -- Criar login do funcionário
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
  
  -- Retornar sucesso
  RETURN QUERY SELECT 
    true,
    v_funcionario_id,
    v_usuario,
    'Funcionário criado com sucesso! Usuário: ' || v_usuario;
    
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro
    RETURN QUERY SELECT 
      false,
      NULL::UUID,
      ''::TEXT,
      'Erro ao criar funcionário: ' || SQLERRM;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION criar_funcionario_completo(UUID, TEXT, TEXT, UUID, TEXT) TO authenticated;

-- ====================================
-- 2. TESTAR A RPC
-- ====================================
-- Criar funcionário de teste
SELECT 
  '🧪 TESTE CRIAR FUNCIONÁRIO' as teste,
  *
FROM criar_funcionario_completo(
  'f1726fcf-d23b-4cca-8079-39314ae56e00',  -- empresa_id
  'Teste Silva',                             -- nome
  '123456',                                  -- senha
  (SELECT id FROM funcoes WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' AND nome = 'Caixa' LIMIT 1),  -- funcao_id
  NULL                                       -- email (opcional)
);

-- ====================================
-- 3. VERIFICAR SE FOI CRIADO
-- ====================================
SELECT 
  '✅ FUNCIONÁRIOS APÓS CRIAR' as info,
  f.id,
  f.nome,
  f.usuario_ativo,
  f.senha_definida,
  f.funcao_id,
  lf.usuario as login_usuario
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY f.created_at DESC;

-- ====================================
-- 4. TESTAR LOGIN COM NOVO FUNCIONÁRIO
-- ====================================
-- Buscar ID do funcionário de teste
DO $$
DECLARE
  v_funcionario_id UUID;
BEGIN
  SELECT id INTO v_funcionario_id
  FROM funcionarios
  WHERE nome = 'Teste Silva'
  ORDER BY created_at DESC
  LIMIT 1;
  
  IF v_funcionario_id IS NOT NULL THEN
    RAISE NOTICE 'ID do Teste Silva: %', v_funcionario_id;
  END IF;
END $$;

-- ====================================
-- 5. RESUMO
-- ====================================
SELECT 
  '📝 RESUMO' as info,
  '✅ RPC criar_funcionario_completo criada' as status_1,
  '🔐 Usa crypt() (bcrypt) para senha' as status_2,
  '👤 Gera usuário único automaticamente' as status_3,
  '🎯 Pronto para usar no ActivateUsersPage' as status_4;
