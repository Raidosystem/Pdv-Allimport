-- ============================================
-- CORREÇÃO URGENTE: RPCs e Triggers Faltando
-- ============================================
-- Este script corrige os erros:
-- ❌ function public.criar_backup_automatico_diario() does not exist
-- ❌ /rest/v1/rpc/atualizar_cliente_seguro 404 (Not Found)
-- ❌ /rest/v1/rpc/atualizar_produto_seguro 404 (Not Found)
-- ============================================
-- AÇÃO:
-- 1. Remove triggers órfãos que chamam função inexistente
-- 2. Recria RPC atualizar_cliente_seguro
-- 3. Recria RPC atualizar_produto_seguro
-- ============================================

-- ============================================
-- PARTE 1: REMOVER TRIGGERS ÓRFÃOS
-- ============================================

DO $$
DECLARE
  v_trigger_count INTEGER;
  v_rec RECORD;
BEGIN
  RAISE NOTICE '🔍 Procurando triggers órfãos que chamam criar_backup_automatico_diario...';
  
  -- Contar triggers órfãos
  SELECT COUNT(*) INTO v_trigger_count
  FROM pg_trigger t
  JOIN pg_proc p ON t.tgfoid = p.oid
  WHERE p.proname = 'criar_backup_automatico_diario';
  
  IF v_trigger_count > 0 THEN
    RAISE NOTICE '📊 Encontrados % trigger(s) órfão(s)', v_trigger_count;
    
    -- Listar e remover cada trigger
    FOR v_rec IN 
      SELECT 
        t.tgname AS trigger_name,
        c.relname AS table_name
      FROM pg_trigger t
      JOIN pg_proc p ON t.tgfoid = p.oid
      JOIN pg_class c ON t.tgrelid = c.oid
      WHERE p.proname = 'criar_backup_automatico_diario'
    LOOP
      RAISE NOTICE '  🗑️  Removendo trigger % da tabela %', v_rec.trigger_name, v_rec.table_name;
      EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', v_rec.trigger_name, v_rec.table_name);
    END LOOP;
    
    RAISE NOTICE '✅ Triggers órfãos removidos com sucesso';
  ELSE
    RAISE NOTICE '✅ Nenhum trigger órfão encontrado';
  END IF;
  
  -- Remover a função se ainda existir (por segurança)
  DROP FUNCTION IF EXISTS public.criar_backup_automatico_diario() CASCADE;
  RAISE NOTICE '✅ Função criar_backup_automatico_diario removida (se existia)';
  
END $$;


-- ============================================
-- PARTE 2: CRIAR RPC atualizar_cliente_seguro
-- ============================================

RAISE NOTICE '🔧 Criando RPC atualizar_cliente_seguro...';

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
SET search_path = public
AS $$
DECLARE
  v_cliente json;
  v_empresa_id uuid;
  v_user_id uuid;
BEGIN
  -- Obter user_id autenticado
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- Obter empresa_id do usuário
  -- Prioridade: 1) metadata.empresa_id (funcionário) 2) empresas.id (admin)
  SELECT COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid,
    e.id
  ) INTO v_empresa_id
  FROM empresas e
  WHERE e.user_id = v_user_id OR e.id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid
  LIMIT 1;

  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION 'Empresa não encontrada para o usuário';
  END IF;

  RAISE NOTICE '🔍 [atualizar_cliente_seguro] Cliente: % | Empresa: %', p_cliente_id, v_empresa_id;

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
    RAISE EXCEPTION 'Cliente % não encontrado ou sem permissão para empresa %', p_cliente_id, v_empresa_id;
  END IF;

  -- Buscar cliente atualizado
  SELECT json_build_object(
    'id', id,
    'nome', nome,
    'cpf_cnpj', cpf_cnpj,
    'cpf_digits', cpf_digits,
    'email', email,
    'telefone', telefone,
    'endereco', endereco,
    'logradouro', logradouro,
    'numero', numero,
    'bairro', bairro,
    'cidade', cidade,
    'estado', estado,
    'cep', cep,
    'tipo', tipo,
    'atualizado_em', atualizado_em,
    'updated_at', updated_at
  ) INTO v_cliente
  FROM clientes
  WHERE id = p_cliente_id;

  RAISE NOTICE '✅ [atualizar_cliente_seguro] Cliente atualizado com sucesso';
  
  RETURN v_cliente;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION '❌ [atualizar_cliente_seguro] Erro: % | SQLSTATE: %', SQLERRM, SQLSTATE;
END;
$$;

-- Conceder permissão de execução
GRANT EXECUTE ON FUNCTION atualizar_cliente_seguro TO authenticated;

RAISE NOTICE '✅ RPC atualizar_cliente_seguro criada e permissões concedidas';


-- ============================================
-- PARTE 3: CRIAR RPC atualizar_produto_seguro
-- ============================================

RAISE NOTICE '🔧 Criando RPC atualizar_produto_seguro...';

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
SET search_path = public
AS $$
DECLARE
  v_produto json;
  v_empresa_id uuid;
  v_user_id uuid;
BEGIN
  -- Obter user_id autenticado
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  -- Obter empresa_id do usuário
  SELECT COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid,
    e.id
  ) INTO v_empresa_id
  FROM empresas e
  WHERE e.user_id = v_user_id OR e.id = (auth.jwt() -> 'user_metadata' ->> 'empresa_id')::uuid
  LIMIT 1;

  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION 'Empresa não encontrada para o usuário';
  END IF;

  RAISE NOTICE '🔍 [atualizar_produto_seguro] Produto: % | Empresa: %', p_produto_id, v_empresa_id;

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
    RAISE EXCEPTION 'Produto % não encontrado ou sem permissão para empresa %', p_produto_id, v_empresa_id;
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
    'image', image,
    'updated_at', updated_at
  ) INTO v_produto
  FROM produtos
  WHERE id = p_produto_id;

  RAISE NOTICE '✅ [atualizar_produto_seguro] Produto atualizado com sucesso';

  RETURN v_produto;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION '❌ [atualizar_produto_seguro] Erro: % | SQLSTATE: %', SQLERRM, SQLSTATE;
END;
$$;

-- Conceder permissão de execução
GRANT EXECUTE ON FUNCTION atualizar_produto_seguro TO authenticated;

RAISE NOTICE '✅ RPC atualizar_produto_seguro criada e permissões concedidas';


-- ============================================
-- PARTE 4: VERIFICAÇÃO FINAL
-- ============================================

DO $$
DECLARE
  v_backup_triggers INTEGER;
  v_backup_function BOOLEAN;
  v_rpc_cliente BOOLEAN;
  v_rpc_produto BOOLEAN;
BEGIN
  -- Contar triggers restantes
  SELECT COUNT(*) INTO v_backup_triggers
  FROM pg_trigger t
  JOIN pg_proc p ON t.tgfoid = p.oid
  WHERE p.proname = 'criar_backup_automatico_diario';
  
  -- Verificar se função de backup ainda existe
  SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'criar_backup_automatico_diario') INTO v_backup_function;
  
  -- Verificar RPCs
  SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'atualizar_cliente_seguro') INTO v_rpc_cliente;
  SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'atualizar_produto_seguro') INTO v_rpc_produto;
  
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════';
  RAISE NOTICE '📊 VERIFICAÇÃO FINAL';
  RAISE NOTICE '════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🗑️  Triggers órfãos restantes: %', v_backup_triggers;
  RAISE NOTICE '🗑️  Função criar_backup_automatico_diario existe: %', v_backup_function;
  RAISE NOTICE '';
  RAISE NOTICE '% RPC atualizar_cliente_seguro', CASE WHEN v_rpc_cliente THEN '✅' ELSE '❌' END;
  RAISE NOTICE '% RPC atualizar_produto_seguro', CASE WHEN v_rpc_produto THEN '✅' ELSE '❌' END;
  RAISE NOTICE '';
  
  IF v_backup_triggers = 0 AND NOT v_backup_function AND v_rpc_cliente AND v_rpc_produto THEN
    RAISE NOTICE '🎉 CORREÇÃO COMPLETA!';
    RAISE NOTICE '   ✅ Triggers órfãos removidos';
    RAISE NOTICE '   ✅ Função de backup removida';
    RAISE NOTICE '   ✅ RPC atualizar_cliente_seguro criada';
    RAISE NOTICE '   ✅ RPC atualizar_produto_seguro criada';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 Próximos passos:';
    RAISE NOTICE '   1. Recarregue a página do sistema (Ctrl+F5)';
    RAISE NOTICE '   2. Teste atualização de cliente';
    RAISE NOTICE '   3. Teste atualização de produto';
  ELSE
    RAISE WARNING '⚠️  Alguns problemas ainda existem:';
    IF v_backup_triggers > 0 THEN
      RAISE WARNING '   ❌ Ainda existem % trigger(s) órfão(s)', v_backup_triggers;
    END IF;
    IF v_backup_function THEN
      RAISE WARNING '   ❌ Função criar_backup_automatico_diario ainda existe';
    END IF;
    IF NOT v_rpc_cliente THEN
      RAISE WARNING '   ❌ RPC atualizar_cliente_seguro não foi criada';
    END IF;
    IF NOT v_rpc_produto THEN
      RAISE WARNING '   ❌ RPC atualizar_produto_seguro não foi criada';
    END IF;
  END IF;
  
  RAISE NOTICE '════════════════════════════════════════════';
END $$;
