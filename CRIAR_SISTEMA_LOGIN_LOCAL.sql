-- ========================================
-- SISTEMA DE LOGIN LOCAL COM SELEÇÃO VISUAL DE USUÁRIOS
-- ========================================
-- Este script cria a estrutura para login local sem email
-- Usuários aparecem em cards visuais e escolhem sua senha

-- 1. ADICIONAR COLUNA DE SENHA LOCAL NA TABELA FUNCIONARIOS
ALTER TABLE funcionarios
ADD COLUMN IF NOT EXISTS senha_hash TEXT,
ADD COLUMN IF NOT EXISTS senha_definida BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS foto_perfil TEXT,
ADD COLUMN IF NOT EXISTS primeiro_acesso BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS usuario_ativo BOOLEAN DEFAULT FALSE;

-- 2. COMENTÁRIOS DAS NOVAS COLUNAS
COMMENT ON COLUMN funcionarios.senha_hash IS 'Hash bcrypt da senha local do funcionário';
COMMENT ON COLUMN funcionarios.senha_definida IS 'Se o funcionário já definiu sua senha pessoal';
COMMENT ON COLUMN funcionarios.foto_perfil IS 'URL da foto de perfil do funcionário';
COMMENT ON COLUMN funcionarios.primeiro_acesso IS 'Se é o primeiro acesso do funcionário';
COMMENT ON COLUMN funcionarios.usuario_ativo IS 'Se o usuário foi ativado pelo admin';

-- 3. CRIAR TABELA DE SESSÕES LOCAIS
CREATE TABLE IF NOT EXISTS sessoes_locais (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  funcionario_id UUID NOT NULL REFERENCES funcionarios(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expira_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '8 hours',
  ip_address TEXT,
  user_agent TEXT,
  ativo BOOLEAN DEFAULT TRUE
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_sessoes_funcionario ON sessoes_locais(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_sessoes_token ON sessoes_locais(token);
CREATE INDEX IF NOT EXISTS idx_sessoes_expira ON sessoes_locais(expira_em);

COMMENT ON TABLE sessoes_locais IS 'Sessões de login local dos funcionários';

-- 4. RLS PARA SESSÕES LOCAIS
ALTER TABLE sessoes_locais ENABLE ROW LEVEL SECURITY;

-- Policy: Funcionário pode ver apenas suas próprias sessões
CREATE POLICY "Funcionários podem ver suas sessões"
ON sessoes_locais FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON f.empresa_id = e.id
    WHERE f.id = sessoes_locais.funcionario_id
    AND e.user_id = auth.uid()
  )
);

-- Policy: Sistema pode criar sessões
CREATE POLICY "Sistema pode criar sessões"
ON sessoes_locais FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON f.empresa_id = e.id
    WHERE f.id = funcionario_id
    AND e.user_id = auth.uid()
  )
);

-- Policy: Sistema pode atualizar sessões
CREATE POLICY "Sistema pode atualizar sessões"
ON sessoes_locais FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM funcionarios f
    JOIN empresas e ON f.empresa_id = e.id
    WHERE f.id = sessoes_locais.funcionario_id
    AND e.user_id = auth.uid()
  )
);

-- 5. FUNÇÃO PARA VALIDAR SENHA LOCAL
CREATE OR REPLACE FUNCTION validar_senha_local(
  p_funcionario_id UUID,
  p_senha TEXT
)
RETURNS TABLE (
  sucesso BOOLEAN,
  funcionario_id UUID,
  nome TEXT,
  email TEXT,
  tipo_admin TEXT,
  empresa_id UUID,
  token TEXT
) AS $$
DECLARE
  v_senha_hash TEXT;
  v_funcionario RECORD;
  v_token TEXT;
BEGIN
  -- Buscar funcionário e validar senha
  SELECT f.senha_hash, f.id, f.nome, f.email, f.tipo_admin, f.empresa_id
  INTO v_funcionario
  FROM funcionarios f
  WHERE f.id = p_funcionario_id
  AND f.usuario_ativo = TRUE
  AND f.senha_definida = TRUE;
  
  -- Verificar se encontrou o funcionário
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;
  
  -- Validar senha (usando crypt do pgcrypto)
  IF v_funcionario.senha_hash = crypt(p_senha, v_funcionario.senha_hash) THEN
    -- Gerar token de sessão
    v_token := encode(gen_random_bytes(32), 'base64');
    
    -- Criar sessão
    INSERT INTO sessoes_locais (funcionario_id, token)
    VALUES (v_funcionario.id, v_token);
    
    -- Atualizar primeiro_acesso
    UPDATE funcionarios
    SET primeiro_acesso = FALSE
    WHERE id = v_funcionario.id;
    
    -- Retornar sucesso com dados do funcionário
    RETURN QUERY SELECT 
      TRUE,
      v_funcionario.id,
      v_funcionario.nome,
      v_funcionario.email,
      v_funcionario.tipo_admin,
      v_funcionario.empresa_id,
      v_token;
  ELSE
    -- Senha incorreta
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. FUNÇÃO PARA DEFINIR SENHA LOCAL
CREATE OR REPLACE FUNCTION definir_senha_local(
  p_funcionario_id UUID,
  p_senha TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_senha_hash TEXT;
BEGIN
  -- Gerar hash bcrypt da senha
  v_senha_hash := crypt(p_senha, gen_salt('bf', 10));
  
  -- Atualizar funcionário
  UPDATE funcionarios
  SET 
    senha_hash = v_senha_hash,
    senha_definida = TRUE,
    usuario_ativo = TRUE,
    primeiro_acesso = TRUE
  WHERE id = p_funcionario_id;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO PARA LISTAR USUÁRIOS ATIVOS DA EMPRESA
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    f.email,
    f.foto_perfil,
    f.tipo_admin,
    f.senha_definida,
    f.primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
  AND f.usuario_ativo = TRUE
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO PARA VALIDAR SESSÃO
CREATE OR REPLACE FUNCTION validar_sessao(p_token TEXT)
RETURNS TABLE (
  valido BOOLEAN,
  funcionario_id UUID,
  nome TEXT,
  tipo_admin TEXT,
  empresa_id UUID
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    TRUE,
    f.id,
    f.nome,
    f.tipo_admin,
    f.empresa_id
  FROM sessoes_locais s
  JOIN funcionarios f ON s.funcionario_id = f.id
  WHERE s.token = p_token
  AND s.ativo = TRUE
  AND s.expira_em > NOW();
  
  -- Se não encontrou sessão válida
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::UUID;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. ATIVAR EXTENSÃO PGCRYPTO (necessária para bcrypt)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 10. VERIFICAR ESTRUTURA CRIADA
DO $$
BEGIN
  RAISE NOTICE '✅ Estrutura do sistema de login local criada com sucesso!';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Recursos criados:';
  RAISE NOTICE '   - Colunas em funcionarios: senha_hash, senha_definida, foto_perfil, primeiro_acesso, usuario_ativo';
  RAISE NOTICE '   - Tabela: sessoes_locais';
  RAISE NOTICE '   - Função: validar_senha_local()';
  RAISE NOTICE '   - Função: definir_senha_local()';
  RAISE NOTICE '   - Função: listar_usuarios_ativos()';
  RAISE NOTICE '   - Função: validar_sessao()';
  RAISE NOTICE '';
  RAISE NOTICE '🔐 Próximos passos:';
  RAISE NOTICE '   1. Admin acessa sistema pela primeira vez';
  RAISE NOTICE '   2. Sistema pede para definir senha do admin';
  RAISE NOTICE '   3. Admin vai em Administração > Ativar Usuários';
  RAISE NOTICE '   4. Admin cria funcionários com suas senhas';
  RAISE NOTICE '   5. Na tela de login, aparecem cards com todos os usuários';
  RAISE NOTICE '   6. Cada um clica em seu card e digita sua senha';
END $$;
