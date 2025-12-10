-- ========================================
-- CRIAR TABELA DE SESSÃO ATIVA
-- ========================================
-- Armazena qual funcionário está ativo para cada user_id (empresa)
-- Substitui localStorage por banco de dados

CREATE TABLE IF NOT EXISTS public.sessao_ativa_funcionario (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  funcionario_id uuid REFERENCES funcionarios(id) ON DELETE CASCADE NOT NULL,
  empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
  criado_em timestamp with time zone DEFAULT now() NOT NULL,
  atualizado_em timestamp with time zone DEFAULT now() NOT NULL,
  
  -- Garantir que cada user_id tenha apenas uma sessão ativa
  UNIQUE(user_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_sessao_ativa_user_id ON sessao_ativa_funcionario(user_id);
CREATE INDEX IF NOT EXISTS idx_sessao_ativa_funcionario_id ON sessao_ativa_funcionario(funcionario_id);

-- RLS para garantir isolamento
ALTER TABLE sessao_ativa_funcionario ENABLE ROW LEVEL SECURITY;

-- Política: Usuário só pode ver/editar sua própria sessão
DROP POLICY IF EXISTS "users_own_session" ON sessao_ativa_funcionario;
CREATE POLICY "users_own_session" ON sessao_ativa_funcionario
  FOR ALL
  USING (user_id = auth.uid());

-- Trigger para atualizar atualizado_em automaticamente
CREATE OR REPLACE FUNCTION atualizar_timestamp_sessao()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atualizar_sessao ON sessao_ativa_funcionario;
CREATE TRIGGER trigger_atualizar_sessao
  BEFORE UPDATE ON sessao_ativa_funcionario
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp_sessao();

-- Comentários
COMMENT ON TABLE sessao_ativa_funcionario IS 'Armazena qual funcionário está ativo para cada empresa (user_id). Substitui localStorage para funcionar multi-dispositivo.';
COMMENT ON COLUMN sessao_ativa_funcionario.user_id IS 'ID do dono da empresa (auth.users)';
COMMENT ON COLUMN sessao_ativa_funcionario.funcionario_id IS 'ID do funcionário ativo na sessão';
COMMENT ON COLUMN sessao_ativa_funcionario.empresa_id IS 'ID da empresa (redundante mas útil para queries)';

-- ========================================
-- FUNÇÃO PARA DEFINIR FUNCIONÁRIO ATIVO
-- ========================================
CREATE OR REPLACE FUNCTION set_funcionario_ativo(p_funcionario_id uuid)
RETURNS json AS $$
DECLARE
  v_user_id uuid;
  v_empresa_id uuid;
  v_funcionario record;
BEGIN
  -- Pegar user_id autenticado
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não autenticado'
    );
  END IF;
  
  -- Buscar dados do funcionário
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id
    AND empresa_id = v_user_id; -- Garantir que pertence à empresa do usuário
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado ou não pertence à sua empresa'
    );
  END IF;
  
  v_empresa_id := v_funcionario.empresa_id;
  
  -- Inserir ou atualizar sessão ativa
  INSERT INTO sessao_ativa_funcionario (user_id, funcionario_id, empresa_id)
  VALUES (v_user_id, p_funcionario_id, v_empresa_id)
  ON CONFLICT (user_id)
  DO UPDATE SET
    funcionario_id = EXCLUDED.funcionario_id,
    atualizado_em = now();
  
  RETURN json_build_object(
    'success', true,
    'funcionario_id', p_funcionario_id,
    'nome', v_funcionario.nome
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- FUNÇÃO PARA OBTER FUNCIONÁRIO ATIVO
-- ========================================
CREATE OR REPLACE FUNCTION get_funcionario_ativo()
RETURNS json AS $$
DECLARE
  v_user_id uuid;
  v_sessao record;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não autenticado'
    );
  END IF;
  
  -- Buscar sessão ativa
  SELECT 
    s.funcionario_id,
    f.nome,
    f.email,
    f.tipo_admin,
    f.funcao_id
  INTO v_sessao
  FROM sessao_ativa_funcionario s
  JOIN funcionarios f ON f.id = s.funcionario_id
  WHERE s.user_id = v_user_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Nenhuma sessão ativa'
    );
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'funcionario_id', v_sessao.funcionario_id,
    'nome', v_sessao.nome,
    'email', v_sessao.email,
    'tipo_admin', v_sessao.tipo_admin,
    'funcao_id', v_sessao.funcao_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Testar funções
SELECT '✅ Tabela sessao_ativa_funcionario criada' as status;
SELECT '✅ Funções set_funcionario_ativo e get_funcionario_ativo criadas' as status;
