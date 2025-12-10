-- =============================================
-- CORREÇÃO URGENTE: Criar RPCs para Clientes
-- =============================================
-- Execute este script no SQL Editor do Supabase
-- =============================================

-- 1. Remover TODAS as versões antigas das funções (FORÇADO)
DROP FUNCTION IF EXISTS criar_cliente_seguro CASCADE;
DROP FUNCTION IF EXISTS atualizar_cliente_seguro CASCADE;

-- Remover também por assinatura específica (caso exista)
DROP FUNCTION IF EXISTS criar_cliente_seguro(text, text, text, text, text, text, uuid, text) CASCADE;
DROP FUNCTION IF EXISTS atualizar_cliente_seguro(uuid, text, text, text, text, text, text, text) CASCADE;

-- Aguardar um momento para garantir que foi removido
DO $$ 
BEGIN 
  PERFORM pg_sleep(0.1);
END $$;

-- 2. Criar função RPC para inserir cliente
CREATE OR REPLACE FUNCTION criar_cliente_seguro(
  p_nome text,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_logradouro text DEFAULT NULL,
  p_numero text DEFAULT NULL,
  p_bairro text DEFAULT NULL,
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

  -- Inserir cliente (endereco será gerado automaticamente via trigger)
  INSERT INTO clientes (
    nome,
    cpf_cnpj,
    cpf_digits,
    email,
    telefone,
    logradouro,
    numero,
    bairro,
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
    p_logradouro,
    p_numero,
    p_bairro,
    p_cidade,
    p_estado,
    p_cep,
    v_empresa_id,
    p_tipo,
    true
  )
  RETURNING id INTO v_cliente_id;

  -- Buscar cliente criado para retornar (DEPOIS do trigger gerar endereco)
  SELECT json_build_object(
    'id', id,
    'nome', nome,
    'cpf_cnpj', cpf_cnpj,
    'cpf_digits', cpf_digits,
    'email', email,
    'telefone', telefone,
    'logradouro', logradouro,
    'numero', numero,
    'bairro', bairro,
    'cidade', cidade,
    'estado', estado,
    'cep', cep,
    'endereco', endereco,
    'empresa_id', empresa_id,
    'tipo', tipo,
    'ativo', ativo,
    'criado_em', criado_em
  ) INTO v_cliente
  FROM clientes
  WHERE id = v_cliente_id;

  RETURN v_cliente;
END;
$$;

-- 3. Criar função para atualizar cliente
CREATE OR REPLACE FUNCTION atualizar_cliente_seguro(
  p_cliente_id uuid,
  p_nome text DEFAULT NULL,
  p_cpf_cnpj text DEFAULT NULL,
  p_cpf_digits text DEFAULT NULL,
  p_email text DEFAULT NULL,
  p_telefone text DEFAULT NULL,
  p_logradouro text DEFAULT NULL,
  p_numero text DEFAULT NULL,
  p_bairro text DEFAULT NULL,
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
  -- Atualizar apenas campos não nulos (endereco será gerado via trigger)
  UPDATE clientes
  SET
    nome = COALESCE(p_nome, nome),
    cpf_cnpj = COALESCE(p_cpf_cnpj, cpf_cnpj),
    cpf_digits = COALESCE(p_cpf_digits, cpf_digits),
    email = COALESCE(p_email, email),
    telefone = COALESCE(p_telefone, telefone),
    logradouro = COALESCE(p_logradouro, logradouro),
    numero = COALESCE(p_numero, numero),
    bairro = COALESCE(p_bairro, bairro),
    cidade = COALESCE(p_cidade, cidade),
    estado = COALESCE(p_estado, estado),
    cep = COALESCE(p_cep, cep),
    tipo = COALESCE(p_tipo, tipo),
    atualizado_em = now()
  WHERE id = p_cliente_id
    AND empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    );

  -- Buscar cliente atualizado (DEPOIS do trigger atualizar endereco)
  SELECT json_build_object(
    'id', id,
    'nome', nome,
    'cpf_cnpj', cpf_cnpj,
    'cpf_digits', cpf_digits,
    'email', email,
    'telefone', telefone,
    'logradouro', logradouro,
    'numero', numero,
    'bairro', bairro,
    'cidade', cidade,
    'estado', estado,
    'cep', cep,
    'endereco', endereco,
    'empresa_id', empresa_id,
    'tipo', tipo,
    'ativo', ativo,
    'criado_em', criado_em,
    'atualizado_em', atualizado_em
  ) INTO v_cliente
  FROM clientes
  WHERE id = p_cliente_id;

  RETURN v_cliente;
END;
$$;

-- 4. Dar permissões
GRANT EXECUTE ON FUNCTION criar_cliente_seguro TO authenticated;
GRANT EXECUTE ON FUNCTION atualizar_cliente_seguro TO authenticated;

-- 5. Verificar se as funções foram criadas
SELECT 
  proname as nome_funcao,
  pg_get_function_arguments(oid) as parametros
FROM pg_proc
WHERE proname IN ('criar_cliente_seguro', 'atualizar_cliente_seguro')
ORDER BY proname;
