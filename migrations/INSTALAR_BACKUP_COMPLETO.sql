-- =============================================
-- BACKUP OTIMIZADO - CRIAR/ATUALIZAR TABELA
-- =============================================
-- Esta versão detecta a estrutura existente e adapta

-- =============================================
-- 1. CRIAR TABELA BACKUPS (SE NÃO EXISTIR)
-- =============================================

CREATE TABLE IF NOT EXISTS public.backups (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    empresa_id uuid NOT NULL,
    user_id uuid NOT NULL,
    tipo text NOT NULL DEFAULT 'manual',
    status text NOT NULL DEFAULT 'pendente',
    descricao text,
    storage_path text,
    file_size bigint,
    total_clientes integer DEFAULT 0,
    total_produtos integer DEFAULT 0,
    total_vendas integer DEFAULT 0,
    tamanho_bytes integer DEFAULT 0,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- =============================================
-- 2. ADICIONAR COLUNAS SE NÃO EXISTIREM
-- =============================================

-- Adicionar storage_path se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'backups' AND column_name = 'storage_path'
    ) THEN
        ALTER TABLE public.backups ADD COLUMN storage_path text;
    END IF;
END $$;

-- Adicionar file_size se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'backups' AND column_name = 'file_size'
    ) THEN
        ALTER TABLE public.backups ADD COLUMN file_size bigint;
    END IF;
END $$;

-- Adicionar user_id se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'backups' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.backups ADD COLUMN user_id uuid;
    END IF;
END $$;

-- =============================================
-- 3. CRIAR ÍNDICES
-- =============================================

CREATE INDEX IF NOT EXISTS idx_backups_empresa_id ON public.backups(empresa_id);
CREATE INDEX IF NOT EXISTS idx_backups_user_id ON public.backups(user_id);
CREATE INDEX IF NOT EXISTS idx_backups_storage_path ON public.backups(storage_path);
CREATE INDEX IF NOT EXISTS idx_backups_created_at ON public.backups(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_backups_status ON public.backups(status);

-- =============================================
-- 4. HABILITAR RLS
-- =============================================

ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Usuários podem ver seus backups" ON public.backups;
DROP POLICY IF EXISTS "Usuários podem criar backups" ON public.backups;
DROP POLICY IF EXISTS "Usuários podem atualizar seus backups" ON public.backups;
DROP POLICY IF EXISTS "Usuários podem deletar seus backups" ON public.backups;

-- Criar políticas RLS
CREATE POLICY "Usuários podem ver seus backups"
ON public.backups FOR SELECT
TO authenticated
USING (
    user_id = auth.uid() OR
    empresa_id IN (
        SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem criar backups"
ON public.backups FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid() OR
    empresa_id IN (
        SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem atualizar seus backups"
ON public.backups FOR UPDATE
TO authenticated
USING (
    user_id = auth.uid() OR
    empresa_id IN (
        SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Usuários podem deletar seus backups"
ON public.backups FOR DELETE
TO authenticated
USING (
    user_id = auth.uid() OR
    empresa_id IN (
        SELECT empresa_id FROM funcionarios WHERE user_id = auth.uid()
    )
);

-- =============================================
-- 5. CRIAR BUCKET NO STORAGE
-- =============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'backups',
    'backups',
    false,
    52428800,  -- 50 MB
    ARRAY['application/json', 'application/zip', 'application/gzip', 'application/octet-stream']::text[]
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = 52428800,
    allowed_mime_types = ARRAY['application/json', 'application/zip', 'application/gzip', 'application/octet-stream']::text[];

-- =============================================
-- 6. POLÍTICAS RLS PARA STORAGE
-- =============================================

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Usuários podem fazer upload de backups" ON storage.objects;
DROP POLICY IF EXISTS "Usuários podem baixar seus backups" ON storage.objects;
DROP POLICY IF EXISTS "Usuários podem deletar seus backups" ON storage.objects;

-- Upload
CREATE POLICY "Usuários podem fazer upload de backups"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Download
CREATE POLICY "Usuários podem baixar seus backups"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Delete
CREATE POLICY "Usuários podem deletar seus backups"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'backups' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- 7. REMOVER FUNÇÕES ANTIGAS
-- =============================================

DROP FUNCTION IF EXISTS criar_backup_automatico_diario();
DROP FUNCTION IF EXISTS criar_backup_automatico_individual();
DROP FUNCTION IF EXISTS finalizar_backup_storage(uuid, bigint);
DROP FUNCTION IF EXISTS limpar_backups_antigos();

-- =============================================
-- 8. FUNÇÃO PRINCIPAL DE BACKUP
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
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    SELECT empresa_id INTO v_empresa_id
    FROM public.funcionarios
    WHERE user_id = v_user_id
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Empresa não encontrada para o usuário';
    END IF;
    
    -- Contar registros
    SELECT COUNT(*) INTO v_total_clientes
    FROM public.clientes WHERE empresa_id = v_empresa_id;
    
    SELECT COUNT(*) INTO v_total_produtos
    FROM public.produtos WHERE empresa_id = v_empresa_id;
    
    SELECT COUNT(*) INTO v_total_vendas
    FROM public.vendas WHERE empresa_id = v_empresa_id;
    
    -- Coletar dados
    v_dados_json := jsonb_build_object(
        'empresa_id', v_empresa_id,
        'backup_date', NOW(),
        'clientes', (
            SELECT COALESCE(jsonb_agg(row_to_json(c.*)), '[]'::jsonb)
            FROM public.clientes c WHERE c.empresa_id = v_empresa_id
        ),
        'produtos', (
            SELECT COALESCE(jsonb_agg(row_to_json(p.*)), '[]'::jsonb)
            FROM public.produtos p WHERE p.empresa_id = v_empresa_id
        ),
        'vendas', (
            SELECT COALESCE(jsonb_agg(row_to_json(v.*)), '[]'::jsonb)
            FROM public.vendas v WHERE v.empresa_id = v_empresa_id
        ),
        'itens_venda', (
            SELECT COALESCE(jsonb_agg(row_to_json(iv.*)), '[]'::jsonb)
            FROM public.itens_venda iv
            INNER JOIN public.vendas v ON v.id = iv.venda_id
            WHERE v.empresa_id = v_empresa_id
        ),
        'categorias', (
            SELECT COALESCE(jsonb_agg(row_to_json(cat.*)), '[]'::jsonb)
            FROM public.categorias cat WHERE cat.empresa_id = v_empresa_id
        ),
        'caixa', (
            SELECT COALESCE(jsonb_agg(row_to_json(cx.*)), '[]'::jsonb)
            FROM public.caixa cx WHERE cx.empresa_id = v_empresa_id
        ),
        'movimentos_caixa', (
            SELECT COALESCE(jsonb_agg(row_to_json(mc.*)), '[]'::jsonb)
            FROM public.movimentos_caixa mc
            INNER JOIN public.caixa cx ON cx.id = mc.caixa_id
            WHERE cx.empresa_id = v_empresa_id
        ),
        'ordens_servico', (
            SELECT COALESCE(jsonb_agg(row_to_json(os.*)), '[]'::jsonb)
            FROM public.ordens_servico os WHERE os.empresa_id = v_empresa_id
        ),
        'fornecedores', (
            SELECT COALESCE(jsonb_agg(row_to_json(f.*)), '[]'::jsonb)
            FROM public.fornecedores f WHERE f.empresa_id = v_empresa_id
        ),
        'configuracoes_impressao', (
            SELECT row_to_json(ci.*)
            FROM public.configuracoes_impressao ci
            WHERE ci.empresa_id = v_empresa_id LIMIT 1
        ),
        'user_settings', (
            SELECT COALESCE(jsonb_agg(row_to_json(us.*)), '[]'::jsonb)
            FROM public.user_settings us WHERE us.empresa_id = v_empresa_id
        )
    );
    
    -- Criar registro
    v_backup_id := gen_random_uuid();
    v_storage_path := v_user_id || '/' || v_empresa_id || '/backup_' || 
                      TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS') || '.json';
    
    INSERT INTO public.backups (
        id, empresa_id, user_id, tipo, status, descricao,
        storage_path, total_clientes, total_produtos, total_vendas,
        tamanho_bytes, created_at, updated_at
    ) VALUES (
        v_backup_id, v_empresa_id, v_user_id, 'automatico', 'pendente',
        'Backup automático diário - ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI'),
        v_storage_path, v_total_clientes, v_total_produtos, v_total_vendas,
        LENGTH(v_dados_json::text), NOW(), NOW()
    );
    
    v_resultado := jsonb_build_object(
        'success', true,
        'backup_id', v_backup_id,
        'empresa_id', v_empresa_id,
        'storage_path', v_storage_path,
        'dados', v_dados_json,
        'total_clientes', v_total_clientes,
        'total_produtos', v_total_produtos,
        'total_vendas', v_total_vendas,
        'tamanho_bytes', LENGTH(v_dados_json::text),
        'message', 'Backup criado com sucesso'
    );
    
    RETURN v_resultado;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao criar backup: %', SQLERRM;
END;
$$;

-- =============================================
-- 9. FUNÇÃO PARA FINALIZAR BACKUP
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
    
    UPDATE public.backups
    SET status = 'concluido', file_size = p_file_size, updated_at = NOW()
    WHERE id = p_backup_id AND user_id = v_user_id;
    
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
-- 10. FUNÇÃO PARA LIMPAR BACKUPS ANTIGOS
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
BEGIN
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    SELECT empresa_id INTO v_empresa_id
    FROM public.funcionarios
    WHERE user_id = v_user_id
    LIMIT 1;
    
    DELETE FROM public.backups
    WHERE empresa_id = v_empresa_id
        AND created_at < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS v_deletados = ROW_COUNT;
    
    RETURN jsonb_build_object(
        'success', true,
        'deletados', v_deletados,
        'message', format('Deletados %s backups antigos', v_deletados)
    );
END;
$$;

-- =============================================
-- 11. PERMISSÕES
-- =============================================

GRANT EXECUTE ON FUNCTION criar_backup_automatico_individual() TO authenticated;
GRANT EXECUTE ON FUNCTION finalizar_backup_storage(uuid, bigint) TO authenticated;
GRANT EXECUTE ON FUNCTION limpar_backups_antigos() TO authenticated;

-- =============================================
-- 12. COMENTÁRIOS
-- =============================================

COMMENT ON TABLE backups IS 'Registro de backups por empresa (dados no Storage)';
COMMENT ON FUNCTION criar_backup_automatico_individual() IS 'Cria backup individual da empresa no Storage';
COMMENT ON FUNCTION finalizar_backup_storage(uuid, bigint) IS 'Finaliza backup após upload no Storage';
COMMENT ON FUNCTION limpar_backups_antigos() IS 'Remove backups com mais de 30 dias';

-- =============================================
-- 13. VERIFICAÇÃO FINAL
-- =============================================

SELECT '✅ SISTEMA DE BACKUP INSTALADO COM SUCESSO!' as status;

-- Ver estrutura da tabela
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'backups'
ORDER BY ordinal_position;

-- Ver bucket
SELECT id, name, public, file_size_limit / 1024 / 1024 as max_mb
FROM storage.buckets
WHERE id = 'backups';

-- Ver funções criadas
SELECT proname, pg_get_function_arguments(oid) as args
FROM pg_proc
WHERE proname LIKE '%backup%'
    AND pronamespace = 'public'::regnamespace;
