-- =============================================
-- CORRIGIR BACKUP PARA SER INDIVIDUAL POR EMPRESA
-- =============================================

-- =============================================
-- 1. REMOVER FUNÇÃO ANTIGA (BACKUP GLOBAL)
-- =============================================

DROP FUNCTION IF EXISTS criar_backup_automatico_diario();

-- =============================================
-- 2. CRIAR FUNÇÃO DE BACKUP INDIVIDUAL
-- =============================================

CREATE OR REPLACE FUNCTION criar_backup_automatico_individual()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_backup_id uuid;
    v_empresa_id uuid;
    v_user_id uuid;
    v_total_clientes integer;
    v_total_produtos integer;
    v_total_vendas integer;
    v_dados_json jsonb;
    v_tamanho integer;
    v_resultado jsonb;
BEGIN
    -- Pegar empresa e usuário da sessão atual
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar empresa_id do usuário
    SELECT empresa_id INTO v_empresa_id
    FROM public.funcionarios
    WHERE user_id = v_user_id
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Empresa não encontrada para o usuário';
    END IF;
    
    -- =============================================
    -- CONTAR REGISTROS DA EMPRESA
    -- =============================================
    
    SELECT COUNT(*) INTO v_total_clientes
    FROM public.clientes
    WHERE empresa_id = v_empresa_id;
    
    SELECT COUNT(*) INTO v_total_produtos
    FROM public.produtos
    WHERE empresa_id = v_empresa_id;
    
    SELECT COUNT(*) INTO v_total_vendas
    FROM public.vendas
    WHERE empresa_id = v_empresa_id;
    
    -- =============================================
    -- COLETAR DADOS DA EMPRESA
    -- =============================================
    
    v_dados_json := jsonb_build_object(
        'empresa_id', v_empresa_id,
        'backup_date', NOW(),
        'clientes', (
            SELECT COALESCE(jsonb_agg(row_to_json(c.*)), '[]'::jsonb)
            FROM public.clientes c
            WHERE c.empresa_id = v_empresa_id
        ),
        'produtos', (
            SELECT COALESCE(jsonb_agg(row_to_json(p.*)), '[]'::jsonb)
            FROM public.produtos p
            WHERE p.empresa_id = v_empresa_id
        ),
        'vendas', (
            SELECT COALESCE(jsonb_agg(row_to_json(v.*)), '[]'::jsonb)
            FROM public.vendas v
            WHERE v.empresa_id = v_empresa_id
        ),
        'itens_venda', (
            SELECT COALESCE(jsonb_agg(row_to_json(iv.*)), '[]'::jsonb)
            FROM public.itens_venda iv
            INNER JOIN public.vendas v ON v.id = iv.venda_id
            WHERE v.empresa_id = v_empresa_id
        ),
        'categorias', (
            SELECT COALESCE(jsonb_agg(row_to_json(cat.*)), '[]'::jsonb)
            FROM public.categorias cat
            WHERE cat.empresa_id = v_empresa_id
        ),
        'caixa', (
            SELECT COALESCE(jsonb_agg(row_to_json(cx.*)), '[]'::jsonb)
            FROM public.caixa cx
            WHERE cx.empresa_id = v_empresa_id
        ),
        'movimentos_caixa', (
            SELECT COALESCE(jsonb_agg(row_to_json(mc.*)), '[]'::jsonb)
            FROM public.movimentos_caixa mc
            INNER JOIN public.caixa cx ON cx.id = mc.caixa_id
            WHERE cx.empresa_id = v_empresa_id
        ),
        'ordens_servico', (
            SELECT COALESCE(jsonb_agg(row_to_json(os.*)), '[]'::jsonb)
            FROM public.ordens_servico os
            WHERE os.empresa_id = v_empresa_id
        ),
        'fornecedores', (
            SELECT COALESCE(jsonb_agg(row_to_json(f.*)), '[]'::jsonb)
            FROM public.fornecedores f
            WHERE f.empresa_id = v_empresa_id
        ),
        'configuracoes_impressao', (
            SELECT row_to_json(ci.*)
            FROM public.configuracoes_impressao ci
            WHERE ci.empresa_id = v_empresa_id
            LIMIT 1
        ),
        'user_settings', (
            SELECT COALESCE(jsonb_agg(row_to_json(us.*)), '[]'::jsonb)
            FROM public.user_settings us
            WHERE us.empresa_id = v_empresa_id
        )
    );
    
    -- Calcular tamanho aproximado
    v_tamanho := LENGTH(v_dados_json::text);
    
    -- =============================================
    -- CRIAR REGISTRO DE BACKUP
    -- =============================================
    
    v_backup_id := gen_random_uuid();
    
    INSERT INTO public.backups (
        id,
        empresa_id,
        user_id,
        tipo,
        status,
        descricao,
        dados_json,
        total_clientes,
        total_produtos,
        total_vendas,
        tamanho_bytes,
        created_at,
        updated_at
    ) VALUES (
        v_backup_id,
        v_empresa_id,
        v_user_id,
        'automatico',
        'concluido',
        'Backup automático diário - ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI'),
        v_dados_json,
        v_total_clientes,
        v_total_produtos,
        v_total_vendas,
        v_tamanho,
        NOW(),
        NOW()
    );
    
    -- Retornar resultado
    v_resultado := jsonb_build_object(
        'success', true,
        'backup_id', v_backup_id,
        'empresa_id', v_empresa_id,
        'total_clientes', v_total_clientes,
        'total_produtos', v_total_produtos,
        'total_vendas', v_total_vendas,
        'tamanho_bytes', v_tamanho,
        'message', 'Backup criado com sucesso'
    );
    
    RETURN v_resultado;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao criar backup: %', SQLERRM;
END;
$$;

-- =============================================
-- 3. DAR PERMISSÕES PARA USUÁRIOS AUTENTICADOS
-- =============================================

GRANT EXECUTE ON FUNCTION criar_backup_automatico_individual() TO authenticated;

-- =============================================
-- 4. COMENTAR A FUNÇÃO
-- =============================================

COMMENT ON FUNCTION criar_backup_automatico_individual() IS 
'Cria backup automático apenas dos dados da empresa do usuário logado. Retorna JSON com ID do backup e estatísticas.';

-- =============================================
-- 5. TESTAR A FUNÇÃO
-- =============================================

SELECT 
    '✅ FUNÇÃO CRIADA COM SUCESSO!' as status,
    'Agora cada empresa terá seu backup individual e isolado' as descricao;

-- Ver a função criada
SELECT 
    proname as nome_funcao,
    pg_get_function_arguments(oid) as argumentos,
    pg_get_function_result(oid) as retorno
FROM pg_proc
WHERE proname = 'criar_backup_automatico_individual';
