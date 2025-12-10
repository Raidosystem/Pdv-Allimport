-- =============================================
-- BACKUP OTIMIZADO COM SUPABASE STORAGE
-- =============================================
-- Esta versão salva arquivos no Storage em vez de JSONB no banco
-- Economiza espaço e melhora performance

-- =============================================
-- 1. ATUALIZAR TABELA BACKUPS
-- =============================================

-- Adicionar coluna para caminho do Storage
ALTER TABLE public.backups 
ADD COLUMN IF NOT EXISTS storage_path text,
ADD COLUMN IF NOT EXISTS file_size bigint;

-- Tornar dados_json opcional (pode ser NULL agora)
ALTER TABLE public.backups 
ALTER COLUMN dados_json DROP NOT NULL;

-- Adicionar índice para busca por storage_path
CREATE INDEX IF NOT EXISTS idx_backups_storage_path ON public.backups(storage_path);

-- Adicionar constraint para garantir que tenha dados_json OU storage_path
ALTER TABLE public.backups
ADD CONSTRAINT chk_backup_data CHECK (
    dados_json IS NOT NULL OR storage_path IS NOT NULL
);

-- =============================================
-- 2. CRIAR BUCKET NO STORAGE
-- =============================================

-- Criar bucket 'backups' (se não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'backups',
    'backups',
    false,  -- Privado
    52428800,  -- 50 MB por arquivo
    ARRAY['application/json', 'application/zip', 'application/gzip']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- 3. POLÍTICAS RLS PARA O BUCKET
-- =============================================

-- Permitir upload apenas para usuários autenticados
CREATE POLICY "Usuários podem fazer upload de backups"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Permitir download apenas dos próprios backups
CREATE POLICY "Usuários podem baixar seus backups"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Permitir deletar apenas os próprios backups
CREATE POLICY "Usuários podem deletar seus backups"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- 4. REMOVER FUNÇÃO ANTIGA
-- =============================================

DROP FUNCTION IF EXISTS criar_backup_automatico_individual();

-- =============================================
-- 5. CRIAR FUNÇÃO OTIMIZADA (SEM DADOS NO BANCO)
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
    v_storage_path text;
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
    -- COLETAR DADOS DA EMPRESA (PARA RETORNAR)
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
    
    -- =============================================
    -- CRIAR REGISTRO DE BACKUP (SEM dados_json)
    -- =============================================
    
    v_backup_id := gen_random_uuid();
    v_storage_path := v_user_id || '/' || v_empresa_id || '/backup_' || 
                      TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS') || '.json';
    
    INSERT INTO public.backups (
        id,
        empresa_id,
        user_id,
        tipo,
        status,
        descricao,
        storage_path,
        dados_json,  -- NULL (cliente fará upload)
        total_clientes,
        total_produtos,
        total_vendas,
        tamanho_bytes,
        file_size,
        created_at,
        updated_at
    ) VALUES (
        v_backup_id,
        v_empresa_id,
        v_user_id,
        'automatico',
        'pendente',  -- Será 'concluido' após upload
        'Backup automático diário - ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI'),
        v_storage_path,
        NULL,  -- Não salvar no banco
        v_total_clientes,
        v_total_produtos,
        v_total_vendas,
        LENGTH(v_dados_json::text),
        NULL,  -- Será atualizado após upload
        NOW(),
        NOW()
    );
    
    -- Retornar dados para o cliente fazer upload
    v_resultado := jsonb_build_object(
        'success', true,
        'backup_id', v_backup_id,
        'empresa_id', v_empresa_id,
        'storage_path', v_storage_path,
        'dados', v_dados_json,  -- Dados para upload
        'total_clientes', v_total_clientes,
        'total_produtos', v_total_produtos,
        'total_vendas', v_total_vendas,
        'tamanho_bytes', LENGTH(v_dados_json::text),
        'message', 'Backup criado. Faça upload dos dados para o Storage.'
    );
    
    RETURN v_resultado;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao criar backup: %', SQLERRM;
END;
$$;

-- =============================================
-- 6. FUNÇÃO PARA FINALIZAR BACKUP APÓS UPLOAD
-- =============================================

CREATE OR REPLACE FUNCTION finalizar_backup_storage(
    p_backup_id uuid,
    p_file_size bigint
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Atualizar status do backup
    UPDATE public.backups
    SET 
        status = 'concluido',
        file_size = p_file_size,
        updated_at = NOW()
    WHERE 
        id = p_backup_id 
        AND user_id = v_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Backup não encontrado ou sem permissão';
    END IF;
    
    RETURN jsonb_build_object(
        'success', true,
        'backup_id', p_backup_id,
        'message', 'Backup finalizado com sucesso'
    );
END;
$$;

-- =============================================
-- 7. FUNÇÃO PARA LIMPAR BACKUPS ANTIGOS
-- =============================================

CREATE OR REPLACE FUNCTION limpar_backups_antigos()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid;
    v_empresa_id uuid;
    v_deletados integer := 0;
    v_backup record;
BEGIN
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar empresa
    SELECT empresa_id INTO v_empresa_id
    FROM public.funcionarios
    WHERE user_id = v_user_id
    LIMIT 1;
    
    -- Deletar backups com mais de 30 dias
    FOR v_backup IN
        DELETE FROM public.backups
        WHERE 
            empresa_id = v_empresa_id
            AND created_at < NOW() - INTERVAL '30 days'
        RETURNING id, storage_path
    LOOP
        v_deletados := v_deletados + 1;
        
        -- Nota: Deletar arquivo do Storage deve ser feito pelo cliente
        -- usando storage.from('backups').remove([storage_path])
    END LOOP;
    
    RETURN jsonb_build_object(
        'success', true,
        'deletados', v_deletados,
        'message', format('Deletados %s backups antigos', v_deletados)
    );
END;
$$;

-- =============================================
-- 8. DAR PERMISSÕES
-- =============================================

GRANT EXECUTE ON FUNCTION criar_backup_automatico_individual() TO authenticated;
GRANT EXECUTE ON FUNCTION finalizar_backup_storage(uuid, bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION limpar_backups_antigos() TO authenticated;

-- =============================================
-- 9. COMENTÁRIOS
-- =============================================

COMMENT ON FUNCTION criar_backup_automatico_individual() IS 
'Cria backup individual da empresa. Retorna dados para upload no Storage.';

COMMENT ON FUNCTION finalizar_backup_storage(uuid, bigint) IS 
'Finaliza backup após upload bem-sucedido no Storage.';

COMMENT ON FUNCTION limpar_backups_antigos() IS 
'Remove backups com mais de 30 dias automaticamente.';

COMMENT ON COLUMN backups.storage_path IS 
'Caminho do arquivo no Supabase Storage (bucket: backups)';

COMMENT ON COLUMN backups.file_size IS 
'Tamanho do arquivo após compressão (bytes)';

-- =============================================
-- 10. VERIFICAÇÃO
-- =============================================

SELECT 
    '✅ SISTEMA DE BACKUP OTIMIZADO CRIADO!' as status,
    'Backups agora são salvos no Storage, não no banco de dados' as descricao;

-- Ver estrutura atualizada
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'backups'
    AND column_name IN ('storage_path', 'file_size', 'dados_json')
ORDER BY ordinal_position;

-- Ver bucket criado
SELECT 
    id,
    name,
    public,
    file_size_limit / 1024 / 1024 as max_size_mb
FROM storage.buckets
WHERE id = 'backups';
