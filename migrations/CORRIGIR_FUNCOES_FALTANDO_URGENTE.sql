-- ============================================
-- CORREÇÃO URGENTE: Funções e Triggers Faltando
-- ============================================
-- Este script corrige 3 problemas críticos:
-- 1. Remove triggers que chamam função inexistente criar_backup_automatico_diario()
-- 2. Cria RPC atualizar_cliente_seguro
-- 3. Cria RPC atualizar_produto_seguro (mesmo problema)
-- ============================================

-- ============================================
-- PARTE 1: REMOVER TRIGGERS DE BACKUP AUTOMÁTICO
-- ============================================

DO $$
DECLARE
  v_trigger_count INTEGER;
BEGIN
  -- Verificar quantos triggers chamam a função
  SELECT COUNT(*) INTO v_trigger_count
  FROM pg_trigger t
  JOIN pg_proc p ON t.tgfoid = p.oid
  WHERE p.proname = 'criar_backup_automatico_diario';
  
  RAISE NOTICE '📊 Triggers encontrados que chamam criar_backup_automatico_diario: %', v_trigger_count;
  
  -- Remover triggers dinamicamente (apenas das tabelas que existem)
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON vendas CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL; -- Ignora se tabela não existe
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON produtos CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON clientes CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON ordens_servico CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON caixa CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON movimentacoes_caixa CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON empresas CASCADE';
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  
  -- Remover a função se ainda existir
  DROP FUNCTION IF EXISTS public.criar_backup_automatico_diario() CASCADE;
  
  RAISE NOTICE '✅ Triggers de backup automático removidos';
END $$;


-- ============================================
-- PARTE 2: CRIAR RPC atualizar_cliente_seguro
-- ============================================

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
  v_empresa_id uuid;
BEGIN
  -- Obter empresa_id do usuário autenticado
  -- Se for funcionário, busca empresa_id do metadata
  -- Se for admin, busca empresa onde user_id = auth.uid()
  SELECT COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid,
    id
  ) INTO v_empresa_id
  FROM empresas
  WHERE user_id = auth.uid() OR id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid
  LIMIT 1;

  RAISE NOTICE '🔍 Atualizando cliente % para empresa %', p_cliente_id, v_empresa_id;

  -- Atualizar apenas campos não nulos
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
    atualizado_em = now(),
    updated_at = now()
  WHERE id = p_cliente_id
    AND empresa_id = v_empresa_id;

  -- Verificar se atualizou
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente não encontrado ou sem permissão';
  END IF;

  -- Buscar cliente atualizado
  SELECT json_build_object(
    'id', id,
    'nome', nome,
    'cpf_cnpj', cpf_cnpj,
    'email', email,
    'telefone', telefone,
    'endereco', endereco,
    'logradouro', logradouro,
    'numero', numero,
    'bairro', bairro,
    'cidade', cidade,
    'estado', estado,
    'cep', cep,
    'tipo', tipo
  ) INTO v_cliente
  FROM clientes
  WHERE id = p_cliente_id;

  RETURN v_cliente;
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_cliente_seguro TO authenticated;


-- ============================================
-- PARTE 3: CRIAR RPC atualizar_produto_seguro
-- ============================================

CREATE OR REPLACE FUNCTION atualizar_produto_seguro(
  p_produto_id uuid,
  p_nome text DEFAULT NULL,
  p_descricao text DEFAULT NULL,
  p_sku text DEFAULT NULL,
  p_codigo_barras text DEFAULT NULL,
  p_preco numeric DEFAULT NULL,
  p_preco_custo numeric DEFAULT NULL,
  p_estoque numeric DEFAULT NULL,
  p_estoque_minimo numeric DEFAULT NULL,
  p_categoria_id uuid DEFAULT NULL,
  p_fornecedor_id uuid DEFAULT NULL,
  p_unidade text DEFAULT NULL,
  p_ativo boolean DEFAULT NULL,
  p_imagem_url text DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_produto json;
  v_empresa_id uuid;
BEGIN
  -- Obter empresa_id do usuário autenticado
  SELECT COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid,
    id
  ) INTO v_empresa_id
  FROM empresas
  WHERE user_id = auth.uid() OR id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid
  LIMIT 1;

  RAISE NOTICE '🔍 Atualizando produto % para empresa %', p_produto_id, v_empresa_id;

  -- Atualizar apenas campos não nulos
  UPDATE produtos
  SET
    name = COALESCE(p_nome, name),
    description = COALESCE(p_descricao, description),
    codigo_interno = COALESCE(p_sku, codigo_interno),
    barcode = COALESCE(p_codigo_barras, barcode),
    price = COALESCE(p_preco, price),
    preco_custo = COALESCE(p_preco_custo, preco_custo),
    stock = COALESCE(p_estoque, stock),
    stock_min = COALESCE(p_estoque_minimo, stock_min),
    categoria_id = COALESCE(p_categoria_id, categoria_id),
    fornecedor_id = COALESCE(p_fornecedor_id, fornecedor_id),
    unidade = COALESCE(p_unidade, unidade),
    ativo = COALESCE(p_ativo, ativo),
    image = COALESCE(p_imagem_url, image),
    updated_at = now()
  WHERE id = p_produto_id
    AND user_id = v_empresa_id;

  -- Verificar se atualizou
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Produto não encontrado ou sem permissão';
  END IF;

  -- Buscar produto atualizado
  SELECT json_build_object(
    'id', id,
    'name', name,
    'description', description,
    'codigo_interno', codigo_interno,
    'barcode', barcode,
    'price', price,
    'preco_custo', preco_custo,
    'stock', stock,
    'stock_min', stock_min,
    'categoria_id', categoria_id,
    'fornecedor_id', fornecedor_id,
    'unidade', unidade,
    'ativo', ativo,
    'image', image
  ) INTO v_produto
  FROM produtos
  WHERE id = p_produto_id;

  RETURN v_produto;
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_produto_seguro TO authenticated;


-- ============================================
-- PARTE 4: VERIFICAR RESULTADO
-- ============================================

DO $$
DECLARE
  v_backup_triggers INTEGER;
  v_rpc_cliente BOOLEAN;
  v_rpc_produto BOOLEAN;
BEGIN
  -- Contar triggers restantes
  SELECT COUNT(*) INTO v_backup_triggers
  FROM pg_trigger t
  JOIN pg_proc p ON t.tgfoid = p.oid
  WHERE p.proname = 'criar_backup_automatico_diario';
  
  -- Verificar RPCs
  SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'atualizar_cliente_seguro') INTO v_rpc_cliente;
  SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'atualizar_produto_seguro') INTO v_rpc_produto;
  
  RAISE NOTICE '';
  RAISE NOTICE '📊 ========== RESULTADO DA CORREÇÃO ==========';
  RAISE NOTICE '🗑️  Triggers de backup restantes: %', v_backup_triggers;
  RAISE NOTICE '% RPC atualizar_cliente_seguro', CASE WHEN v_rpc_cliente THEN '✅' ELSE '❌' END;
  RAISE NOTICE '% RPC atualizar_produto_seguro', CASE WHEN v_rpc_produto THEN '✅' ELSE '❌' END;
  RAISE NOTICE '=============================================';
  
  IF v_backup_triggers = 0 AND v_rpc_cliente AND v_rpc_produto THEN
    RAISE NOTICE '🎉 CORREÇÃO COMPLETA! Todos os problemas foram resolvidos.';
  ELSE
    RAISE WARNING '⚠️  Alguns problemas ainda existem. Revise os logs acima.';
  END IF;
END $$;
