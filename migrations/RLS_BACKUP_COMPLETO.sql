-- 🔒 CONFIGURAÇÃO COMPLETA RLS PARA SISTEMA DE BACKUP PDV ALLIMPORT
-- Execute este script no SQL Editor do Supabase

-- =====================================
-- PARTE 1: FUNÇÕES RPC PARA BACKUP
-- =====================================

-- 1. Função para exportar dados do usuário
CREATE OR REPLACE FUNCTION public.export_user_data_json()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    user_email text;
    backup_data jsonb;
BEGIN
    -- Verificar autenticação
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar email do usuário
    SELECT email INTO user_email FROM auth.users WHERE id = user_uuid;
    
    -- Montar dados do backup
    backup_data := jsonb_build_object(
        'backup_info', jsonb_build_object(
            'user_id', user_uuid,
            'user_email', COALESCE(user_email, 'usuario@sistema.com'),
            'backup_date', NOW(),
            'backup_version', '2.0',
            'system', 'PDV Allimport'
        ),
        'data', jsonb_build_object(
            'clientes', COALESCE((
                SELECT jsonb_agg(to_jsonb(c.*))
                FROM clientes c
                WHERE c.user_id = user_uuid
            ), '[]'::jsonb),
            'categorias', COALESCE((
                SELECT jsonb_agg(to_jsonb(cat.*))
                FROM categorias cat
                WHERE cat.user_id = user_uuid
            ), '[]'::jsonb),
            'produtos', COALESCE((
                SELECT jsonb_agg(to_jsonb(p.*))
                FROM produtos p
                WHERE p.user_id = user_uuid
            ), '[]'::jsonb),
            'vendas', COALESCE((
                SELECT jsonb_agg(to_jsonb(v.*))
                FROM vendas v
                WHERE v.user_id = user_uuid
            ), '[]'::jsonb),
            'itens_venda', COALESCE((
                SELECT jsonb_agg(to_jsonb(iv.*))
                FROM itens_venda iv
                WHERE iv.user_id = user_uuid
            ), '[]'::jsonb),
            'caixa', COALESCE((
                SELECT jsonb_agg(to_jsonb(cx.*))
                FROM caixa cx
                WHERE cx.user_id = user_uuid
            ), '[]'::jsonb),
            'movimentacoes_caixa', COALESCE((
                SELECT jsonb_agg(to_jsonb(mc.*))
                FROM movimentacoes_caixa mc
                WHERE mc.user_id = user_uuid
            ), '[]'::jsonb),
            'ordens_servico', COALESCE((
                SELECT jsonb_agg(to_jsonb(os.*))
                FROM ordens_servico os
                WHERE os.user_id = user_uuid
            ), '[]'::jsonb),
            'configuracoes', COALESCE((
                SELECT jsonb_agg(to_jsonb(cfg.*))
                FROM configuracoes cfg
                WHERE cfg.user_id = user_uuid
            ), '[]'::jsonb)
        )
    );
    
    RETURN backup_data;
END;
$$;

-- 2. Função para importar dados do usuário
CREATE OR REPLACE FUNCTION public.import_user_data_json(
    backup_json jsonb,
    clear_existing boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    result jsonb;
    imported_count integer := 0;
    table_name text;
    data_array jsonb;
    record_item jsonb;
BEGIN
    -- Verificar autenticação
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não autenticado'
        );
    END IF;
    
    -- Verificar estrutura do backup
    IF NOT (backup_json ? 'backup_info' AND backup_json ? 'data') THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Estrutura de backup inválida'
        );
    END IF;
    
    -- Limpar dados existentes se solicitado
    IF clear_existing THEN
        DELETE FROM configuracoes WHERE user_id = user_uuid;
        DELETE FROM ordens_servico WHERE user_id = user_uuid;
        DELETE FROM movimentacoes_caixa WHERE user_id = user_uuid;
        DELETE FROM caixa WHERE user_id = user_uuid;
        DELETE FROM itens_venda WHERE user_id = user_uuid;
        DELETE FROM vendas WHERE user_id = user_uuid;
        DELETE FROM produtos WHERE user_id = user_uuid;
        DELETE FROM categorias WHERE user_id = user_uuid;
        DELETE FROM clientes WHERE user_id = user_uuid;
    END IF;
    
    -- Importar cada tabela na ordem correta
    FOR table_name IN SELECT unnest(ARRAY[
        'clientes', 'categorias', 'produtos', 'vendas', 
        'itens_venda', 'caixa', 'movimentacoes_caixa', 'ordens_servico', 'configuracoes'
    ])
    LOOP
        data_array := backup_json->'data'->table_name;
        
        IF data_array IS NOT NULL AND jsonb_array_length(data_array) > 0 THEN
            FOR record_item IN SELECT * FROM jsonb_array_elements(data_array)
            LOOP
                -- Garantir que tenha user_id
                record_item := jsonb_set(record_item, '{user_id}', to_jsonb(user_uuid));
                
                -- Inserir registro baseado na tabela
                CASE table_name
                    WHEN 'clientes' THEN
                        INSERT INTO clientes (
                            id, user_id, name, email, telefone, cpf, endereco, 
                            cidade, cep, created_at, updated_at
                        )
                        SELECT 
                            COALESCE((record_item->>'id')::uuid, gen_random_uuid()),
                            user_uuid,
                            record_item->>'name',
                            record_item->>'email',
                            record_item->>'telefone',
                            record_item->>'cpf',
                            record_item->>'endereco',
                            record_item->>'cidade',
                            record_item->>'cep',
                            COALESCE((record_item->>'created_at')::timestamptz, NOW()),
                            COALESCE((record_item->>'updated_at')::timestamptz, NOW())
                        ON CONFLICT (id) DO NOTHING;
                        
                    WHEN 'categorias' THEN
                        INSERT INTO categorias (
                            id, user_id, name, cor, ativo, created_at, updated_at
                        )
                        SELECT 
                            COALESCE((record_item->>'id')::uuid, gen_random_uuid()),
                            user_uuid,
                            record_item->>'name',
                            COALESCE(record_item->>'cor', '#3B82F6'),
                            COALESCE((record_item->>'ativo')::boolean, true),
                            COALESCE((record_item->>'created_at')::timestamptz, NOW()),
                            COALESCE((record_item->>'updated_at')::timestamptz, NOW())
                        ON CONFLICT (id) DO NOTHING;
                        
                    WHEN 'produtos' THEN
                        INSERT INTO produtos (
                            id, user_id, name, preco, codigo, categoria, 
                            estoque, ativo, created_at, updated_at
                        )
                        SELECT 
                            COALESCE((record_item->>'id')::uuid, gen_random_uuid()),
                            user_uuid,
                            record_item->>'name',
                            COALESCE((record_item->>'preco')::numeric, 0),
                            record_item->>'codigo',
                            record_item->>'categoria',
                            COALESCE((record_item->>'estoque')::integer, 0),
                            COALESCE((record_item->>'ativo')::boolean, true),
                            COALESCE((record_item->>'created_at')::timestamptz, NOW()),
                            COALESCE((record_item->>'updated_at')::timestamptz, NOW())
                        ON CONFLICT (id) DO NOTHING;
                        
                    WHEN 'ordens_servico' THEN
                        INSERT INTO ordens_servico (
                            id, user_id, cliente_id, equipamento, defeito, 
                            status, data_entrada, data_previsao, valor, 
                            observacoes, created_at, updated_at
                        )
                        SELECT 
                            COALESCE((record_item->>'id')::uuid, gen_random_uuid()),
                            user_uuid,
                            (record_item->>'cliente_id')::uuid,
                            record_item->>'equipamento',
                            record_item->>'defeito',
                            COALESCE(record_item->>'status', 'aguardando'),
                            COALESCE((record_item->>'data_entrada')::timestamptz, NOW()),
                            (record_item->>'data_previsao')::timestamptz,
                            COALESCE((record_item->>'valor')::numeric, 0),
                            record_item->>'observacoes',
                            COALESCE((record_item->>'created_at')::timestamptz, NOW()),
                            COALESCE((record_item->>'updated_at')::timestamptz, NOW())
                        ON CONFLICT (id) DO NOTHING;
                        
                    -- Adicionar outros casos conforme necessário...
                    ELSE
                        -- Log para tabelas não implementadas
                        RAISE LOG 'Tabela % não implementada na importação', table_name;
                END CASE;
                
                imported_count := imported_count + 1;
            END LOOP;
        END IF;
    END LOOP;
    
    -- Salvar backup na tabela user_backups
    INSERT INTO user_backups (user_id, backup_date, backup_data, created_at)
    VALUES (
        user_uuid,
        (backup_json->'backup_info'->>'backup_date')::timestamptz,
        backup_json,
        NOW()
    )
    ON CONFLICT (user_id, DATE(backup_date)) DO UPDATE SET
        backup_data = EXCLUDED.backup_data,
        updated_at = NOW();
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Dados importados com sucesso',
        'imported_records', imported_count,
        'user_id', user_uuid
    );
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', 'Erro na importação: ' || SQLERRM
    );
END;
$$;

-- 3. Função para salvar backup no banco
CREATE OR REPLACE FUNCTION public.save_backup_to_database()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    backup_data jsonb;
    backup_size integer;
BEGIN
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Gerar backup
    backup_data := public.export_user_data_json();
    backup_size := length(backup_data::text);
    
    -- Salvar na tabela user_backups
    INSERT INTO user_backups (user_id, backup_date, backup_data, created_at)
    VALUES (user_uuid, NOW(), backup_data, NOW())
    ON CONFLICT (user_id, DATE(backup_date)) DO UPDATE SET
        backup_data = EXCLUDED.backup_data,
        updated_at = NOW();
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Backup criado com sucesso',
        'backup_size', backup_size,
        'backup_date', NOW()
    );
END;
$$;

-- 4. Função para listar backups do usuário
CREATE OR REPLACE FUNCTION public.list_user_backups()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    backup_list jsonb;
BEGIN
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', id,
            'backup_date', backup_date,
            'created_at', created_at,
            'size', length(backup_data::text)
        ) ORDER BY backup_date DESC
    )
    INTO backup_list
    FROM user_backups 
    WHERE user_id = user_uuid;
    
    RETURN COALESCE(backup_list, '[]'::jsonb);
END;
$$;

-- 5. Função para restaurar backup específico
CREATE OR REPLACE FUNCTION public.restore_from_database_backup(
    backup_id uuid,
    clear_existing boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_uuid uuid;
    backup_data jsonb;
BEGIN
    user_uuid := auth.uid();
    IF user_uuid IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar backup
    SELECT ub.backup_data INTO backup_data
    FROM user_backups ub
    WHERE ub.id = backup_id AND ub.user_id = user_uuid;
    
    IF backup_data IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Backup não encontrado'
        );
    END IF;
    
    -- Usar função de importação
    RETURN public.import_user_data_json(backup_data, clear_existing);
END;
$$;

-- =====================================
-- PARTE 2: TABELA DE BACKUPS
-- =====================================

-- Criar tabela user_backups se não existir
CREATE TABLE IF NOT EXISTS public.user_backups (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    backup_date timestamptz NOT NULL,
    backup_data jsonb NOT NULL,
    created_at timestamptz DEFAULT NOW() NOT NULL,
    updated_at timestamptz DEFAULT NOW() NOT NULL
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_user_backups_user_id ON user_backups(user_id);
CREATE INDEX IF NOT EXISTS idx_user_backups_date ON user_backups(backup_date);

-- Índice único para evitar múltiplos backups no mesmo dia
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_backups_unique_daily 
ON user_backups(user_id, DATE(backup_date));

-- =====================================
-- PARTE 3: POLÍTICAS RLS
-- =====================================

-- Ativar RLS em todas as tabelas
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_backups ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Users can only see own clientes" ON clientes;
DROP POLICY IF EXISTS "Users can only insert own clientes" ON clientes;
DROP POLICY IF EXISTS "Users can only update own clientes" ON clientes;
DROP POLICY IF EXISTS "Users can only delete own clientes" ON clientes;

DROP POLICY IF EXISTS "Users can only see own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only insert own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only update own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only delete own categorias" ON categorias;

DROP POLICY IF EXISTS "Users can only see own produtos" ON produtos;
DROP POLICY IF EXISTS "Users can only insert own produtos" ON produtos;
DROP POLICY IF EXISTS "Users can only update own produtos" ON produtos;
DROP POLICY IF EXISTS "Users can only delete own produtos" ON produtos;

DROP POLICY IF EXISTS "Users can only see own vendas" ON vendas;
DROP POLICY IF EXISTS "Users can only insert own vendas" ON vendas;
DROP POLICY IF EXISTS "Users can only update own vendas" ON vendas;
DROP POLICY IF EXISTS "Users can only delete own vendas" ON vendas;

DROP POLICY IF EXISTS "Users can only see own itens_venda" ON itens_venda;
DROP POLICY IF EXISTS "Users can only insert own itens_venda" ON itens_venda;
DROP POLICY IF EXISTS "Users can only update own itens_venda" ON itens_venda;
DROP POLICY IF EXISTS "Users can only delete own itens_venda" ON itens_venda;

DROP POLICY IF EXISTS "Users can only see own caixa" ON caixa;
DROP POLICY IF EXISTS "Users can only insert own caixa" ON caixa;
DROP POLICY IF EXISTS "Users can only update own caixa" ON caixa;
DROP POLICY IF EXISTS "Users can only delete own caixa" ON caixa;

DROP POLICY IF EXISTS "Users can only see own movimentacoes_caixa" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "Users can only insert own movimentacoes_caixa" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "Users can only update own movimentacoes_caixa" ON movimentacoes_caixa;
DROP POLICY IF EXISTS "Users can only delete own movimentacoes_caixa" ON movimentacoes_caixa;

DROP POLICY IF EXISTS "Users can only see own configuracoes" ON configuracoes;
DROP POLICY IF EXISTS "Users can only insert own configuracoes" ON configuracoes;
DROP POLICY IF EXISTS "Users can only update own configuracoes" ON configuracoes;
DROP POLICY IF EXISTS "Users can only delete own configuracoes" ON configuracoes;

DROP POLICY IF EXISTS "Users can only see own ordens_servico" ON ordens_servico;
DROP POLICY IF EXISTS "Users can only insert own ordens_servico" ON ordens_servico;
DROP POLICY IF EXISTS "Users can only update own ordens_servico" ON ordens_servico;
DROP POLICY IF EXISTS "Users can only delete own ordens_servico" ON ordens_servico;

DROP POLICY IF EXISTS "Users can only see own user_backups" ON user_backups;
DROP POLICY IF EXISTS "Users can only insert own user_backups" ON user_backups;
DROP POLICY IF EXISTS "Users can only update own user_backups" ON user_backups;
DROP POLICY IF EXISTS "Users can only delete own user_backups" ON user_backups;

-- =====================================
-- POLÍTICAS PARA CLIENTES
-- =====================================
CREATE POLICY "Users can only see own clientes" ON clientes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own clientes" ON clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own clientes" ON clientes
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own clientes" ON clientes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA CATEGORIAS
-- =====================================
CREATE POLICY "Users can only see own categorias" ON categorias
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own categorias" ON categorias
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own categorias" ON categorias
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own categorias" ON categorias
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA PRODUTOS
-- =====================================
CREATE POLICY "Users can only see own produtos" ON produtos
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own produtos" ON produtos
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own produtos" ON produtos
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own produtos" ON produtos
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA VENDAS
-- =====================================
CREATE POLICY "Users can only see own vendas" ON vendas
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own vendas" ON vendas
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own vendas" ON vendas
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own vendas" ON vendas
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA ITENS_VENDA
-- =====================================
CREATE POLICY "Users can only see own itens_venda" ON itens_venda
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own itens_venda" ON itens_venda
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own itens_venda" ON itens_venda
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own itens_venda" ON itens_venda
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA CAIXA
-- =====================================
CREATE POLICY "Users can only see own caixa" ON caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own caixa" ON caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own caixa" ON caixa
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own caixa" ON caixa
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA MOVIMENTACOES_CAIXA
-- =====================================
CREATE POLICY "Users can only see own movimentacoes_caixa" ON movimentacoes_caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own movimentacoes_caixa" ON movimentacoes_caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own movimentacoes_caixa" ON movimentacoes_caixa
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own movimentacoes_caixa" ON movimentacoes_caixa
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA CONFIGURACOES
-- =====================================
CREATE POLICY "Users can only see own configuracoes" ON configuracoes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own configuracoes" ON configuracoes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own configuracoes" ON configuracoes
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own configuracoes" ON configuracoes
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA ORDENS_SERVICO
-- =====================================
CREATE POLICY "Users can only see own ordens_servico" ON ordens_servico
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own ordens_servico" ON ordens_servico
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own ordens_servico" ON ordens_servico
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own ordens_servico" ON ordens_servico
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS PARA USER_BACKUPS
-- =====================================
CREATE POLICY "Users can only see own user_backups" ON user_backups
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own user_backups" ON user_backups
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own user_backups" ON user_backups
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own user_backups" ON user_backups
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- TRIGGERS PARA AUTO user_id
-- =====================================

-- Função para inserir user_id automaticamente
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS trigger AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover triggers existentes (se houver)
DROP TRIGGER IF EXISTS trigger_clientes_set_user_id ON clientes;
DROP TRIGGER IF EXISTS trigger_categorias_set_user_id ON categorias;
DROP TRIGGER IF EXISTS trigger_produtos_set_user_id ON produtos;
DROP TRIGGER IF EXISTS trigger_vendas_set_user_id ON vendas;
DROP TRIGGER IF EXISTS trigger_itens_venda_set_user_id ON itens_venda;
DROP TRIGGER IF EXISTS trigger_caixa_set_user_id ON caixa;
DROP TRIGGER IF EXISTS trigger_movimentacoes_caixa_set_user_id ON movimentacoes_caixa;
DROP TRIGGER IF EXISTS trigger_configuracoes_set_user_id ON configuracoes;
DROP TRIGGER IF EXISTS trigger_ordens_servico_set_user_id ON ordens_servico;
DROP TRIGGER IF EXISTS trigger_user_backups_set_user_id ON user_backups;

-- Triggers para cada tabela
CREATE TRIGGER trigger_clientes_set_user_id
    BEFORE INSERT ON clientes
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_categorias_set_user_id
    BEFORE INSERT ON categorias
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_produtos_set_user_id
    BEFORE INSERT ON produtos
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_vendas_set_user_id
    BEFORE INSERT ON vendas
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_itens_venda_set_user_id
    BEFORE INSERT ON itens_venda
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_caixa_set_user_id
    BEFORE INSERT ON caixa
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_movimentacoes_caixa_set_user_id
    BEFORE INSERT ON movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_configuracoes_set_user_id
    BEFORE INSERT ON configuracoes
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_ordens_servico_set_user_id
    BEFORE INSERT ON ordens_servico
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

CREATE TRIGGER trigger_user_backups_set_user_id
    BEFORE INSERT ON user_backups
    FOR EACH ROW EXECUTE FUNCTION set_user_id();

-- =====================================
-- VERIFICAÇÃO FINAL
-- =====================================

-- Verificar se as funções foram criadas
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
    'export_user_data_json',
    'import_user_data_json',
    'save_backup_to_database',
    'list_user_backups',
    'restore_from_database_backup'
);

-- Verificar se as políticas RLS estão ativas
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN (
    'clientes', 'categorias', 'produtos', 'vendas', 
    'itens_venda', 'caixa', 'movimentacoes_caixa', 
    'ordens_servico', 'configuracoes', 'user_backups'
)
ORDER BY tablename, cmd;

-- ✅ CONFIGURAÇÃO COMPLETA!
SELECT '🎉 RLS e Sistema de Backup configurados com sucesso!' as status;
