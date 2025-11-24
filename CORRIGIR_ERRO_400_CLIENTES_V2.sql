-- =============================================
-- CORREÇÃO: Erro 400 - Criação de Cliente
-- =============================================
-- VERSÃO CORRIGIDA - Usando apenas coluna 'endereco'
-- =============================================

-- 1. Remover funções antigas se existirem
DROP FUNCTION IF EXISTS criar_cliente_seguro;
DROP FUNCTION IF EXISTS atualizar_cliente_seguro;

-- 2. Criar função RPC para inserir cliente (VERSÃO CORRIGIDA)
CREATE OR REPLACE FUNCTION criar_cliente_seguro(
  p_nome text,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_endereco text DEFAULT NULL,
  p_empresa_id uuid DEFAULT NULL,
  p_tipo text DEFAULT 'fisica'
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_empresa_id uuid;
  v_cliente_id uuid;
  v_cliente json;
BEGIN
  -- Se empresa_id não foi fornecido, buscar do usuário atual
  IF p_empresa_id IS NULL THEN
    SELECT id INTO v_empresa_id
    FROM empresas
    WHERE user_id = auth.uid()
    LIMIT 1;
  ELSE
    v_empresa_id := p_empresa_id;
  END IF;

  -- Verificar se empresa foi encontrada
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION 'Empresa não encontrada para o usuário';
  END IF;

  -- Inserir cliente
  INSERT INTO clientes (
    nome,
    cpf_cnpj,
    cpf_digits,
    email,
    telefone,
    endereco,
    empresa_id,
    tipo,
    ativo
  ) VALUES (
    p_nome,
    p_cpf_cnpj,
    p_cpf_digits,
    p_email,
    p_telefone,
    p_endereco,
    v_empresa_id,
    p_tipo,
    true
  )
  RETURNING id INTO v_cliente_id;

  -- Buscar cliente criado para retornar
  SELECT json_build_object(
    'id', c.id,
    'nome', c.nome,
    'cpf_cnpj', c.cpf_cnpj,
    'cpf_digits', c.cpf_digits,
    'email', c.email,
    'telefone', c.telefone,
    'endereco', c.endereco,
    'empresa_id', c.empresa_id,
    'tipo', c.tipo,
    'ativo', c.ativo,
    'criado_em', c.criado_em
  ) INTO v_cliente
  FROM clientes c
  WHERE c.id = v_cliente_id;

  RETURN v_cliente;
END;
$$;

-- 3. Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION criar_cliente_seguro TO authenticated;

-- 4. Criar função para atualizar cliente (VERSÃO CORRIGIDA)
CREATE OR REPLACE FUNCTION atualizar_cliente_seguro(
  p_cliente_id uuid,
  p_nome text DEFAULT NULL,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_endereco text DEFAULT NULL,
  p_tipo text DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_cliente json;
BEGIN
  -- Atualizar apenas campos não nulos
  UPDATE clientes
  SET
    nome = COALESCE(p_nome, nome),
    cpf_cnpj = COALESCE(p_cpf_cnpj, cpf_cnpj),
    cpf_digits = COALESCE(p_cpf_digits, cpf_digits),
    email = COALESCE(p_email, email),
    telefone = COALESCE(p_telefone, telefone),
    endereco = COALESCE(p_endereco, endereco),
    tipo = COALESCE(p_tipo, tipo),
    atualizado_em = now()
  WHERE id = p_cliente_id
    AND empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    );

  -- Buscar cliente atualizado
  SELECT json_build_object(
    'id', c.id,
    'nome', c.nome,
    'cpf_cnpj', c.cpf_cnpj,
    'cpf_digits', c.cpf_digits,
    'email', c.email,
    'telefone', c.telefone,
    'endereco', c.endereco,
    'empresa_id', c.empresa_id,
    'tipo', c.tipo,
    'ativo', c.ativo,
    'criado_em', c.criado_em,
    'atualizado_em', c.atualizado_em
  ) INTO v_cliente
  FROM clientes c
  WHERE c.id = p_cliente_id;

  RETURN v_cliente;
END;
$$;

-- 5. Dar permissão para atualizar
GRANT EXECUTE ON FUNCTION atualizar_cliente_seguro TO authenticated;

-- =============================================
-- LOG
-- =============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Funções RPC para clientes CORRIGIDAS com sucesso!';
  RAISE NOTICE '';
  RAISE NOTICE 'Funções disponíveis:';
  RAISE NOTICE '  - criar_cliente_seguro() - Usa apenas coluna endereco';
  RAISE NOTICE '  - atualizar_cliente_seguro() - Usa apenas coluna endereco';
  RAISE NOTICE '';
  RAISE NOTICE 'IMPORTANTE: Execute este script novamente no Supabase!';
END $$;
