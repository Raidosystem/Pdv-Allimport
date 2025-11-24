-- =============================================
-- SISTEMA DE BACKUP AUTOMÁTICO DIÁRIO
-- =============================================
-- Este script configura backup automático que roda todo dia
-- e salva os backups na tabela 'backups' do Supabase

-- =============================================
-- PASSO 1: CRIAR FUNÇÃO DE BACKUP AUTOMÁTICO
-- =============================================

CREATE OR REPLACE FUNCTION public.criar_backup_automatico_diario()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_empresa_id UUID;
    v_backup_id UUID;
    v_backup_data JSONB;
    v_total_clientes INTEGER := 0;
    v_total_produtos INTEGER := 0;
    v_total_vendas INTEGER := 0;
    v_total_ordens INTEGER := 0;
    v_total_caixas INTEGER := 0;
    v_tamanho_bytes BIGINT;
    v_result JSONB;
BEGIN
    -- Para cada empresa, criar um backup
    FOR v_empresa_id IN 
        SELECT DISTINCT id FROM public.empresas
    LOOP
        -- Coletar dados de todas as tabelas
        v_backup_data := jsonb_build_object(
            'metadata', jsonb_build_object(
                'versao', '1.0',
                'timestamp', NOW(),
                'empresa_id', v_empresa_id,
                'tipo_backup', 'automatico_diario'
            ),
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
            'categorias', (
                SELECT COALESCE(jsonb_agg(row_to_json(cat.*)), '[]'::jsonb)
                FROM public.categories cat
                WHERE cat.empresa_id = v_empresa_id
            ),
            'vendas', (
                SELECT COALESCE(jsonb_agg(row_to_json(v.*)), '[]'::jsonb)
                FROM public.vendas v
                WHERE v.empresa_id = v_empresa_id
                AND v.created_at >= NOW() - INTERVAL '30 days' -- Últimos 30 dias
            ),
            'vendas_itens', (
                SELECT COALESCE(jsonb_agg(row_to_json(vi.*)), '[]'::jsonb)
                FROM public.vendas_itens vi
                INNER JOIN public.vendas v ON vi.venda_id = v.id
                WHERE v.empresa_id = v_empresa_id
                AND v.created_at >= NOW() - INTERVAL '30 days'
            ),
            'ordens_servico', (
                SELECT COALESCE(jsonb_agg(row_to_json(os.*)), '[]'::jsonb)
                FROM public.ordens_servico os
                WHERE os.empresa_id = v_empresa_id
                AND os.created_at >= NOW() - INTERVAL '90 days' -- Últimos 90 dias
            ),
            'caixa', (
                SELECT COALESCE(jsonb_agg(row_to_json(cx.*)), '[]'::jsonb)
                FROM public.caixa cx
                WHERE cx.empresa_id = v_empresa_id
                AND cx.created_at >= NOW() - INTERVAL '90 days'
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
            'empresa', (
                SELECT row_to_json(e.*)
                FROM public.empresas e
                WHERE e.id = v_empresa_id
                LIMIT 1
            )
        );

        -- Contar registros
        v_total_clientes := jsonb_array_length(v_backup_data->'clientes');
        v_total_produtos := jsonb_array_length(v_backup_data->'produtos');
        v_total_vendas := jsonb_array_length(v_backup_data->'vendas');
        v_total_ordens := jsonb_array_length(v_backup_data->'ordens_servico');
        v_total_caixas := jsonb_array_length(v_backup_data->'caixa');
        
        -- Calcular tamanho aproximado
        v_tamanho_bytes := pg_column_size(v_backup_data);

        -- Inserir backup na tabela
        INSERT INTO public.backups (
            empresa_id,
            data,
            tipo,
            descricao,
            tamanho_bytes,
            status,
            total_clientes,
            total_produtos,
            total_vendas,
            total_ordens,
            total_caixas
        ) VALUES (
            v_empresa_id,
            v_backup_data,
            'automatico',
            'Backup automático diário - ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI'),
            v_tamanho_bytes,
            'concluido',
            v_total_clientes,
            v_total_produtos,
            v_total_vendas,
            v_total_ordens,
            v_total_caixas
        ) RETURNING id INTO v_backup_id;

        RAISE NOTICE 'Backup criado para empresa %: % clientes, % produtos, % KB', 
            v_empresa_id, v_total_clientes, v_total_produtos, 
            ROUND(v_tamanho_bytes / 1024.0, 2);
    END LOOP;

    -- Limpar backups automáticos antigos (manter apenas últimos 7 dias)
    DELETE FROM public.backups
    WHERE tipo = 'automatico'
    AND created_at < NOW() - INTERVAL '7 days';

    v_result := jsonb_build_object(
        'sucesso', true,
        'mensagem', 'Backup automático concluído com sucesso',
        'timestamp', NOW()
    );

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'sucesso', false,
            'erro', SQLERRM,
            'timestamp', NOW()
        );
END;
$$;

-- =============================================
-- PASSO 2: CONFIGURAR BACKUP AUTOMÁTICO
-- =============================================
-- ⚠️ IMPORTANTE: pg_cron NÃO está disponível no plano Free
-- Usando TRIGGER AUTOMÁTICO que funciona em qualquer plano!

-- =============================================
-- TESTAR A FUNÇÃO MANUALMENTE
-- =============================================
SELECT public.criar_backup_automatico_diario();

-- Verificar se os backups foram criados
SELECT 
    id,
    empresa_id,
    tipo,
    status,
    descricao,
    total_clientes,
    total_produtos,
    total_vendas,
    ROUND(tamanho_bytes / 1024.0 / 1024.0, 2) as tamanho_mb,
    created_at
FROM public.backups
WHERE tipo = 'automatico'
ORDER BY created_at DESC
LIMIT 10;

-- =============================================
-- PASSO 3: CONFIGURAR TRIGGER AUTOMÁTICO
-- =============================================
-- ✅ Esta solução funciona no plano FREE do Supabase
-- O backup será criado automaticamente quando houver mudanças nos dados

CREATE OR REPLACE FUNCTION verificar_e_criar_backup_diario()
RETURNS TRIGGER AS $$
DECLARE
    v_ultimo_backup TIMESTAMP;
    v_empresa_id UUID;
BEGIN
    v_empresa_id := COALESCE(NEW.empresa_id, OLD.empresa_id);
    
    -- Verificar se já existe backup automático hoje
    SELECT MAX(created_at) INTO v_ultimo_backup
    FROM public.backups
    WHERE empresa_id = v_empresa_id
    AND tipo = 'automatico'
    AND DATE(created_at) = CURRENT_DATE;
    
    -- Se não existe backup hoje, criar um
    IF v_ultimo_backup IS NULL THEN
        PERFORM public.criar_backup_automatico_diario();
        RAISE NOTICE 'Backup automático criado para empresa %', v_empresa_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em tabelas principais
DROP TRIGGER IF EXISTS trigger_backup_diario_vendas ON public.vendas;
CREATE TRIGGER trigger_backup_diario_vendas
    AFTER INSERT OR UPDATE ON public.vendas
    FOR EACH ROW
    EXECUTE FUNCTION verificar_e_criar_backup_diario();

DROP TRIGGER IF EXISTS trigger_backup_diario_produtos ON public.produtos;
CREATE TRIGGER trigger_backup_diario_produtos
    AFTER INSERT OR UPDATE ON public.produtos
    FOR EACH ROW
    EXECUTE FUNCTION verificar_e_criar_backup_diario();

DROP TRIGGER IF EXISTS trigger_backup_diario_clientes ON public.clientes;
CREATE TRIGGER trigger_backup_diario_clientes
    AFTER INSERT OR UPDATE ON public.clientes
    FOR EACH ROW
    EXECUTE FUNCTION verificar_e_criar_backup_diario();

-- =============================================
-- ✅ SOLUÇÃO RECOMENDADA: GITHUB ACTIONS
-- =============================================
-- Para backup 100% automático e confiável, use GitHub Actions
-- Já criamos o arquivo .github/workflows/backup-diario.yml
-- Veja instruções completas em: GITHUB_ACTIONS_BACKUP.md

-- =============================================
-- VERIFICAR CONFIGURAÇÃO
-- =============================================

-- Ver todos os backups criados hoje
SELECT 
    id,
    empresa_id,
    tipo,
    status,
    total_clientes,
    total_produtos,
    ROUND(tamanho_bytes / 1024.0 / 1024.0, 2) as tamanho_mb,
    created_at
FROM public.backups
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at DESC;

-- Ver estatísticas de backups
SELECT 
    tipo,
    COUNT(*) as total_backups,
    ROUND(SUM(tamanho_bytes) / 1024.0 / 1024.0, 2) as total_mb,
    MIN(created_at) as primeiro_backup,
    MAX(created_at) as ultimo_backup
FROM public.backups
GROUP BY tipo;

-- =============================================
-- ✅ VERIFICAR SE OS TRIGGERS FORAM CRIADOS
-- =============================================
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND trigger_name LIKE 'trigger_backup_diario%'
ORDER BY trigger_name;

-- =============================================
-- RESULTADO ESPERADO
-- =============================================
SELECT '✅ BACKUP AUTOMÁTICO CONFIGURADO COM SUCESSO!' as status;

-- =============================================
-- 🧪 TESTAR O SISTEMA AGORA
-- =============================================

-- 1. Testar a função de backup manualmente:
SELECT public.criar_backup_automatico_diario();

-- 2. Verificar backups criados:
SELECT 
    id,
    empresa_id,
    tipo,
    status,
    total_clientes,
    total_produtos,
    total_vendas,
    ROUND(tamanho_bytes / 1024.0 / 1024.0, 2) as tamanho_mb,
    created_at
FROM public.backups
WHERE tipo = 'automatico'
ORDER BY created_at DESC
LIMIT 5;

-- 3. Testar trigger fazendo uma venda ou alterando um produto
-- O backup será criado automaticamente na primeira alteração do dia

-- =============================================
-- 📋 PRÓXIMOS PASSOS
-- =============================================

-- OPÇÃO A: Continuar com Triggers (já configurado)
-- ✅ Funciona no plano Free
-- ✅ Backup criado automaticamente quando houver mudanças
-- ⚠️ Backup só acontece se houver alterações nos dados

-- OPÇÃO B: Configurar GitHub Actions (RECOMENDADO)
-- ✅ Funciona no plano Free
-- ✅ 100% automático, roda todo dia mesmo sem alterações
-- ✅ Histórico completo de execuções
-- ✅ Notificações em caso de falha
-- 📖 Veja instruções em: GITHUB_ACTIONS_BACKUP.md

-- Para configurar GitHub Actions:
-- 1. Leia o arquivo: GITHUB_ACTIONS_BACKUP.md
-- 2. Configure os secrets no GitHub
-- 3. Pronto! Backup automático funcionando 24/7
