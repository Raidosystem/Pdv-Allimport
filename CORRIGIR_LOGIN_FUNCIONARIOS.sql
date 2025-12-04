-- =====================================================
-- CORREÇÃO: Tabela login_funcionarios e RPC
-- =====================================================

-- 1. CRIAR TABELA login_funcionarios (se não existir)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.login_funcionarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  funcionario_id UUID NOT NULL REFERENCES public.funcionarios(id) ON DELETE CASCADE,
  usuario TEXT NOT NULL UNIQUE,
  senha TEXT NOT NULL,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. ADICIONAR ÍNDICES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_funcionario_id 
  ON public.login_funcionarios(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_usuario 
  ON public.login_funcionarios(usuario);

-- 3. HABILITAR RLS (Row Level Security)
-- =====================================================
ALTER TABLE public.login_funcionarios ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS
-- =====================================================
-- Remover políticas antigas
DROP POLICY IF EXISTS "Usuários podem ver logins da sua empresa" ON public.login_funcionarios;
DROP POLICY IF EXISTS "Usuários podem inserir logins na sua empresa" ON public.login_funcionarios;
DROP POLICY IF EXISTS "Usuários podem atualizar logins da sua empresa" ON public.login_funcionarios;
DROP POLICY IF EXISTS "Usuários podem deletar logins da sua empresa" ON public.login_funcionarios;

-- Criar políticas corretas
CREATE POLICY "Usuários podem ver logins da sua empresa"
  ON public.login_funcionarios FOR SELECT
  USING (
    funcionario_id IN (
      SELECT id FROM public.funcionarios 
      WHERE empresa_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem inserir logins na sua empresa"
  ON public.login_funcionarios FOR INSERT
  WITH CHECK (
    funcionario_id IN (
      SELECT id FROM public.funcionarios 
      WHERE empresa_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem atualizar logins da sua empresa"
  ON public.login_funcionarios FOR UPDATE
  USING (
    funcionario_id IN (
      SELECT id FROM public.funcionarios 
      WHERE empresa_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem deletar logins da sua empresa"
  ON public.login_funcionarios FOR DELETE
  USING (
    funcionario_id IN (
      SELECT id FROM public.funcionarios 
      WHERE empresa_id = auth.uid()
    )
  );

-- 5. CRIAR FUNÇÃO RPC criar_funcionario_completo
-- =====================================================
-- Remover todas as versões antigas da função
DROP FUNCTION IF EXISTS public.criar_funcionario_completo(TEXT, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.criar_funcionario_completo(TEXT, TEXT, TEXT, TEXT, UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.criar_funcionario_completo CASCADE;

-- Criar função nova
CREATE FUNCTION public.criar_funcionario_completo(
  p_nome TEXT,
  p_email TEXT,
  p_telefone TEXT DEFAULT NULL,
  p_cargo TEXT DEFAULT NULL,
  p_funcao_id UUID DEFAULT NULL,
  p_usuario TEXT DEFAULT NULL,
  p_senha TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario_id UUID;
  v_empresa_id UUID;
  v_login_id UUID;
  v_resultado JSON;
BEGIN
  -- Obter empresa_id do usuário autenticado
  v_empresa_id := auth.uid();
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- Inserir funcionário
  INSERT INTO public.funcionarios (
    empresa_id,
    nome,
    email,
    telefone,
    cargo,
    funcao_id,
    ativo,
    created_at,
    updated_at
  ) VALUES (
    v_empresa_id,
    p_nome,
    p_email,
    p_telefone,
    p_cargo,
    p_funcao_id,
    true,
    now(),
    now()
  )
  RETURNING id INTO v_funcionario_id;

  -- Se forneceu usuário e senha, criar login
  IF p_usuario IS NOT NULL AND p_senha IS NOT NULL THEN
    INSERT INTO public.login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      ativo,
      created_at,
      updated_at
    ) VALUES (
      v_funcionario_id,
      p_usuario,
      crypt(p_senha, gen_salt('bf')), -- Criptografar senha com bcrypt
      true,
      now(),
      now()
    )
    RETURNING id INTO v_login_id;
  END IF;

  -- Retornar resultado
  v_resultado := json_build_object(
    'success', true,
    'funcionario_id', v_funcionario_id,
    'login_id', v_login_id,
    'message', 'Funcionário criado com sucesso'
  );

  RETURN v_resultado;

EXCEPTION
  WHEN unique_violation THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email ou usuário já cadastrado'
    );
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 6. CRIAR FUNÇÃO RPC autenticar_funcionario
-- =====================================================
-- Remover versão antiga se existir
DROP FUNCTION IF EXISTS public.autenticar_funcionario(TEXT, TEXT);

-- Criar função nova
CREATE FUNCTION public.autenticar_funcionario(
  p_usuario TEXT,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_login RECORD;
  v_funcionario RECORD;
  v_resultado JSON;
BEGIN
  -- Buscar login
  SELECT * INTO v_login
  FROM public.login_funcionarios
  WHERE usuario = p_usuario
    AND ativo = true
    AND senha = crypt(p_senha, senha); -- Validar senha criptografada

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário ou senha inválidos'
    );
  END IF;

  -- Buscar dados do funcionário
  SELECT f.*, func.nome as funcao_nome
  INTO v_funcionario
  FROM public.funcionarios f
  LEFT JOIN public.funcoes func ON f.funcao_id = func.id
  WHERE f.id = v_login.funcionario_id
    AND f.ativo = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário inativo ou não encontrado'
    );
  END IF;

  -- Retornar sucesso com dados
  v_resultado := json_build_object(
    'success', true,
    'funcionario', row_to_json(v_funcionario),
    'login_id', v_login.id
  );

  RETURN v_resultado;
END;
$$;

-- 7. HABILITAR EXTENSÃO pgcrypto (necessária para crypt)
-- =====================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 8. GARANTIR PERMISSÕES NA API REST
-- =====================================================
-- Expor tabela na API REST
GRANT SELECT, INSERT, UPDATE, DELETE ON public.login_funcionarios TO anon, authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Expor funções RPC na API REST
GRANT EXECUTE ON FUNCTION public.criar_funcionario_completo TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.autenticar_funcionario TO anon, authenticated;

-- =====================================================
-- 8.3. FUNÇÃO RPC: Validar Senha Local (para login de funcionários)
-- =====================================================
DROP FUNCTION IF EXISTS public.validar_senha_local(TEXT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.validar_senha_local(
  p_usuario TEXT,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

-- Expor nova função na API REST
GRANT EXECUTE ON FUNCTION public.validar_senha_local TO anon, authenticated;

-- 9. CRIAR TRIGGER PARA updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION public.atualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atualizar_updated_at_login_funcionarios ON public.login_funcionarios;
CREATE TRIGGER trigger_atualizar_updated_at_login_funcionarios
  BEFORE UPDATE ON public.login_funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION public.atualizar_updated_at();

-- 10. VERIFICAR ESTRUTURA
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Tabela login_funcionarios criada/atualizada';
  RAISE NOTICE '✅ Políticas RLS aplicadas (4 políticas)';
  RAISE NOTICE '✅ Função criar_funcionario_completo criada';
  RAISE NOTICE '✅ Função autenticar_funcionario criada';
  RAISE NOTICE '✅ Função validar_senha_local criada (NOVO!)';
  RAISE NOTICE '✅ Permissões da API REST configuradas';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Próximos passos:';
  RAISE NOTICE '   1. Execute este script no Supabase SQL Editor';
  RAISE NOTICE '   2. Verifique se a tabela aparece em Database > Tables';
  RAISE NOTICE '   3. Teste login de funcionário na interface';
  RAISE NOTICE '';
  RAISE NOTICE '🎯 Funções RPC disponíveis:';
  RAISE NOTICE '   • criar_funcionario_completo() - Cria funcionário + login';
  RAISE NOTICE '   • autenticar_funcionario() - Login para API';
  RAISE NOTICE '   • validar_senha_local() - Login na interface (novo!)';
END $$;
