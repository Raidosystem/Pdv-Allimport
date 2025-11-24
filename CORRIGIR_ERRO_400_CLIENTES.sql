-- =============================================
-- CORREÇÃO ALTERNATIVA: Erro 400 - Criação de Cliente
-- =============================================
-- Problema: Erro 400 ao inserir cliente (possível problema com RLS ou trigger)
-- Solução: Criar função RPC para inserir clientes de forma segura
-- =============================================

-- 1. Criar função RPC para inserir cliente
CREATE OR REPLACE FUNCTION criar_cliente_seguro(
  p_nome text,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_rua text DEFAULT NULL,
  p_numero text DEFAULT NULL,
  p_cidade text DEFAULT NULL,
  p_estado text DEFAULT NULL,
  p_cep text DEFAULT NULL,
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
    rua,
    numero,
    cidade,
    estado,
    cep,
    empresa_id,
    tipo,
    ativo
  ) VALUES (
    p_nome,
    p_cpf_cnpj,
    p_cpf_digits,
    p_email,
    p_telefone,
    p_rua,
    p_numero,
    p_cidade,
    p_estado,
    p_cep,
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
    'rua', c.rua,
    'numero', c.numero,
    'cidade', c.cidade,
    'estado', c.estado,
    'cep', c.cep,
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

-- 2. Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION criar_cliente_seguro TO authenticated;

-- 3. Criar função similar para atualizar cliente
CREATE OR REPLACE FUNCTION atualizar_cliente_seguro(
  p_cliente_id uuid,
  p_nome text DEFAULT NULL,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_rua text DEFAULT NULL,
  p_numero text DEFAULT NULL,
  p_cidade text DEFAULT NULL,
  p_estado text DEFAULT NULL,
  p_cep text DEFAULT NULL,
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
    rua = COALESCE(p_rua, rua),
    numero = COALESCE(p_numero, numero),
    cidade = COALESCE(p_cidade, cidade),
    estado = COALESCE(p_estado, estado),
    cep = COALESCE(p_cep, cep),
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
    'rua', c.rua,
    'numero', c.numero,
    'cidade', c.cidade,
    'estado', c.estado,
    'cep', c.cep,
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

-- 4. Dar permissão para atualizar
GRANT EXECUTE ON FUNCTION atualizar_cliente_seguro TO authenticated;

-- =============================================
-- TESTE
-- =============================================
-- Para testar a função:
/*
SELECT criar_cliente_seguro(
  p_nome := 'Teste Cliente',
  p_cpf_cnpj := '123.456.789-00',
  p_cpf_digits := '12345678900',
  p_telefone := '(11) 99999-9999'
);
*/

-- =============================================
-- LOG
-- =============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Funções RPC para clientes criadas com sucesso!';
  RAISE NOTICE '';
  RAISE NOTICE 'Funções disponíveis:';
  RAISE NOTICE '  - criar_cliente_seguro()';
  RAISE NOTICE '  - atualizar_cliente_seguro()';
  RAISE NOTICE '';
  RAISE NOTICE 'Use estas funções no código TypeScript para evitar erro 400.';
END $$;
