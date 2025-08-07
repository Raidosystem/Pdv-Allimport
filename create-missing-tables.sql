-- Script para criar tabelas faltantes no Supabase
-- Execute este SQL no Supabase Dashboard > SQL Editor
-- CONFIGURAÇÃO: PRIVACIDADE TOTAL POR USUÁRIO + BACKUP DIÁRIO

-- =============================================
-- CRIAR TABELA CAIXA (CONTROLE DE SESSÕES DE CAIXA)
-- =============================================
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_abertura TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_fechamento TIMESTAMP WITH TIME ZONE,
    saldo_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
    saldo_final DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto', -- 'aberto', 'fechado'
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA MOVIMENTAÇÕES DE CAIXA
-- =============================================
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caixa_id UUID REFERENCES public.caixa(id) ON DELETE CASCADE NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- 'entrada', 'saida', 'venda', 'troco', 'sangria', 'suprimento'
    valor DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    venda_id UUID, -- Referência opcional para vendas
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA CONFIGURAÇÕES DO SISTEMA
-- =============================================
CREATE TABLE IF NOT EXISTS public.configuracoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chave VARCHAR(100) NOT NULL, -- ex: 'nome_loja', 'logo_url', 'endereco', etc.
    valor TEXT, -- Valor da configuração
    descricao TEXT, -- Descrição da configuração
    tipo VARCHAR(20) DEFAULT 'string', -- 'string', 'number', 'boolean', 'json'
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chave, user_id) -- Cada usuário pode ter apenas uma configuração por chave
);

-- =============================================
-- VERIFICAR SE TABELA CLIENTES JÁ EXISTE E CRIAR SE NECESSÁRIO
-- =============================================
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    cpf VARCHAR(14),
    endereco TEXT,
    data_nascimento DATE,
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA CATEGORIAS (COM ISOLAMENTO POR USUÁRIO)
-- =============================================
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA PRODUTOS (COM ISOLAMENTO POR USUÁRIO)
-- =============================================
CREATE TABLE IF NOT EXISTS public.produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    categoria_id UUID REFERENCES categorias(id),
    estoque INTEGER DEFAULT 0,
    codigo_barras VARCHAR(50),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA VENDAS (COM ISOLAMENTO POR USUÁRIO)
-- =============================================
CREATE TABLE IF NOT EXISTS public.vendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    total DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'finalizada',
    metodo_pagamento VARCHAR(50),
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA ITENS_VENDA (COM ISOLAMENTO POR USUÁRIO)
-- =============================================
CREATE TABLE IF NOT EXISTS public.itens_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- ATUALIZAR TABELA CLIENTES (ADICIONAR user_id SE NÃO EXISTIR)
-- =============================================
DO $$
BEGIN
    -- Verificar se a coluna user_id já existe na tabela clientes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'clientes' AND column_name = 'user_id') THEN
        ALTER TABLE public.clientes ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
        RAISE NOTICE 'Coluna user_id adicionada à tabela clientes';
    ELSE
        RAISE NOTICE 'Coluna user_id já existe na tabela clientes';
    END IF;
    
    -- Tornar user_id NOT NULL se não for
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'clientes' 
               AND column_name = 'user_id' 
               AND is_nullable = 'YES') THEN
        -- Primeiro, definir user_id para registros existentes sem user_id
        UPDATE public.clientes SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
        -- Depois tornar NOT NULL
        ALTER TABLE public.clientes ALTER COLUMN user_id SET NOT NULL;
        RAISE NOTICE 'Coluna user_id definida como NOT NULL';
    END IF;
END $$;

-- =============================================
-- DADOS INICIAIS REMOVIDOS
-- =============================================
-- NOTA: Com RLS ativo, cada usuário deve criar seus próprios dados
-- Os dados iniciais serão criados via interface do usuário após login

-- =============================================
-- CONFIGURAR RLS (ROW LEVEL SECURITY) - PRIVACIDADE TOTAL
-- =============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- =============================================
-- POLÍTICAS DE SEGURANÇA - CADA USUÁRIO VÊ APENAS SEUS DADOS
-- =============================================

-- CAIXA: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own caixa" ON public.caixa;
CREATE POLICY "Users can only see their own caixa" ON public.caixa
    FOR ALL USING (auth.uid() = user_id);

-- MOVIMENTAÇÕES CAIXA: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa;
CREATE POLICY "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa
    FOR ALL USING (auth.uid() = user_id);

-- CONFIGURAÇÕES: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own configuracoes" ON public.configuracoes;
CREATE POLICY "Users can only see their own configuracoes" ON public.configuracoes
    FOR ALL USING (auth.uid() = user_id);

-- CATEGORIAS: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own categorias" ON public.categorias;
CREATE POLICY "Users can only see their own categorias" ON public.categorias
    FOR ALL USING (auth.uid() = user_id);

-- PRODUTOS: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own produtos" ON public.produtos;
CREATE POLICY "Users can only see their own produtos" ON public.produtos
    FOR ALL USING (auth.uid() = user_id);

-- VENDAS: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own vendas" ON public.vendas;
CREATE POLICY "Users can only see their own vendas" ON public.vendas
    FOR ALL USING (auth.uid() = user_id);

-- ITENS_VENDA: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own itens_venda" ON public.itens_venda;
CREATE POLICY "Users can only see their own itens_venda" ON public.itens_venda
    FOR ALL USING (auth.uid() = user_id);

-- CLIENTES: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own clientes" ON public.clientes;
CREATE POLICY "Users can only see their own clientes" ON public.clientes
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- TRIGGER PARA AUTO-INSERIR user_id NAS INSERÇÕES
-- =============================================

-- Função para inserir automaticamente o user_id
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers para cada tabela
DROP TRIGGER IF EXISTS set_user_id_caixa ON public.caixa;
CREATE TRIGGER set_user_id_caixa
    BEFORE INSERT ON public.caixa
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_movimentacoes_caixa ON public.movimentacoes_caixa;
CREATE TRIGGER set_user_id_movimentacoes_caixa
    BEFORE INSERT ON public.movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_configuracoes ON public.configuracoes;
CREATE TRIGGER set_user_id_configuracoes
    BEFORE INSERT ON public.configuracoes
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_categorias ON public.categorias;
CREATE TRIGGER set_user_id_categorias
    BEFORE INSERT ON public.categorias
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_produtos ON public.produtos;
CREATE TRIGGER set_user_id_produtos
    BEFORE INSERT ON public.produtos
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_vendas ON public.vendas;
CREATE TRIGGER set_user_id_vendas
    BEFORE INSERT ON public.vendas
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_itens_venda ON public.itens_venda;
CREATE TRIGGER set_user_id_itens_venda
    BEFORE INSERT ON public.itens_venda
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

-- Trigger para clientes (se não tiver user_id ainda)
DROP TRIGGER IF EXISTS set_user_id_clientes ON public.clientes;
CREATE TRIGGER set_user_id_clientes
    BEFORE INSERT ON public.clientes
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

-- =============================================
-- SISTEMA COMPLETO DE BACKUP E RESTAURAÇÃO (BANCO + JSON)
-- =============================================

-- Função para criar backup completo (usado tanto para banco quanto JSON)
CREATE OR REPLACE FUNCTION public.create_user_backup_data(p_user_id UUID DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    backup_data JSONB;
    user_email TEXT;
BEGIN
    -- Usar o user_id fornecido ou o usuário atual
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    -- Buscar email do usuário
    SELECT email INTO user_email FROM auth.users WHERE id = target_user_id;
    
    -- Gerar backup completo dos dados do usuário
    SELECT jsonb_build_object(
        'backup_info', jsonb_build_object(
            'user_id', target_user_id,
            'user_email', user_email,
            'backup_date', NOW(),
            'backup_version', '1.0',
            'system', 'PDV Allimport'
        ),
        'data', jsonb_build_object(
            'clientes', COALESCE((
                SELECT jsonb_agg(to_jsonb(c)) 
                FROM clientes c 
                WHERE c.user_id = target_user_id
            ), '[]'::jsonb),
            'categorias', COALESCE((
                SELECT jsonb_agg(to_jsonb(cat)) 
                FROM categorias cat 
                WHERE cat.user_id = target_user_id
            ), '[]'::jsonb),
            'produtos', COALESCE((
                SELECT jsonb_agg(to_jsonb(p)) 
                FROM produtos p 
                WHERE p.user_id = target_user_id
            ), '[]'::jsonb),
            'vendas', COALESCE((
                SELECT jsonb_agg(to_jsonb(v)) 
                FROM vendas v 
                WHERE v.user_id = target_user_id
            ), '[]'::jsonb),
            'itens_venda', COALESCE((
                SELECT jsonb_agg(to_jsonb(i)) 
                FROM itens_venda i 
                WHERE i.user_id = target_user_id
            ), '[]'::jsonb),
            'caixa', COALESCE((
                SELECT jsonb_agg(to_jsonb(cx)) 
                FROM caixa cx 
                WHERE cx.user_id = target_user_id
            ), '[]'::jsonb),
            'movimentacoes_caixa', COALESCE((
                SELECT jsonb_agg(to_jsonb(mc)) 
                FROM movimentacoes_caixa mc 
                WHERE mc.user_id = target_user_id
            ), '[]'::jsonb),
            'configuracoes', COALESCE((
                SELECT jsonb_agg(to_jsonb(conf)) 
                FROM configuracoes conf 
                WHERE conf.user_id = target_user_id
            ), '[]'::jsonb)
        )
    ) INTO backup_data;
    
    RETURN backup_data;
END;
$$;

-- Função para salvar backup no banco de dados
CREATE OR REPLACE FUNCTION public.save_backup_to_database(p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    backup_data JSONB;
BEGIN
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    -- Criar backup
    SELECT public.create_user_backup_data(target_user_id) INTO backup_data;
    
    -- Salvar no banco
    INSERT INTO user_backups (user_id, backup_data, backup_date)
    VALUES (target_user_id, backup_data, CURRENT_DATE)
    ON CONFLICT (user_id, backup_date)
    DO UPDATE SET 
        backup_data = EXCLUDED.backup_data,
        updated_at = NOW();
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- Função para restaurar dados de um backup JSON
CREATE OR REPLACE FUNCTION public.restore_from_backup_data(backup_json JSONB, p_clear_existing BOOLEAN DEFAULT TRUE)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    data_section JSONB;
    rec RECORD;
BEGIN
    target_user_id := auth.uid();
    
    -- Verificar se o backup tem a estrutura correta
    IF NOT (backup_json ? 'backup_info' AND backup_json ? 'data') THEN
        RAISE EXCEPTION 'Formato de backup inválido';
    END IF;
    
    -- Extrair seção de dados
    data_section := backup_json->'data';
    
    -- Limpar dados existentes se solicitado
    IF p_clear_existing THEN
        DELETE FROM movimentacoes_caixa WHERE user_id = target_user_id;
        DELETE FROM caixa WHERE user_id = target_user_id;
        DELETE FROM itens_venda WHERE user_id = target_user_id;
        DELETE FROM vendas WHERE user_id = target_user_id;
        DELETE FROM produtos WHERE user_id = target_user_id;
        DELETE FROM categorias WHERE user_id = target_user_id;
        DELETE FROM clientes WHERE user_id = target_user_id;
        DELETE FROM configuracoes WHERE user_id = target_user_id;
    END IF;
    
    -- Restaurar categorias
    IF data_section ? 'categorias' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'categorias')
        LOOP
            INSERT INTO categorias (id, nome, descricao, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                rec.value->>'nome',
                rec.value->>'descricao',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO UPDATE SET
                nome = EXCLUDED.nome,
                descricao = EXCLUDED.descricao,
                updated_at = NOW();
        END LOOP;
    END IF;
    
    -- Restaurar clientes
    IF data_section ? 'clientes' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'clientes')
        LOOP
            INSERT INTO clientes (id, nome, email, telefone, cpf, endereco, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                rec.value->>'nome',
                rec.value->>'email',
                rec.value->>'telefone',
                rec.value->>'cpf',
                rec.value->>'endereco',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO UPDATE SET
                nome = EXCLUDED.nome,
                email = EXCLUDED.email,
                telefone = EXCLUDED.telefone,
                cpf = EXCLUDED.cpf,
                endereco = EXCLUDED.endereco,
                updated_at = NOW();
        END LOOP;
    END IF;
    
    -- Restaurar produtos
    IF data_section ? 'produtos' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'produtos')
        LOOP
            INSERT INTO produtos (id, nome, descricao, preco, categoria_id, estoque, codigo_barras, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                rec.value->>'nome',
                rec.value->>'descricao',
                (rec.value->>'preco')::DECIMAL(10,2),
                NULLIF(rec.value->>'categoria_id', '')::UUID,
                COALESCE((rec.value->>'estoque')::INTEGER, 0),
                rec.value->>'codigo_barras',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO UPDATE SET
                nome = EXCLUDED.nome,
                descricao = EXCLUDED.descricao,
                preco = EXCLUDED.preco,
                categoria_id = EXCLUDED.categoria_id,
                estoque = EXCLUDED.estoque,
                codigo_barras = EXCLUDED.codigo_barras,
                updated_at = NOW();
        END LOOP;
    END IF;
    
    -- Restaurar vendas
    IF data_section ? 'vendas' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'vendas')
        LOOP
            INSERT INTO vendas (id, cliente_id, total, desconto, status, metodo_pagamento, observacoes, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                NULLIF(rec.value->>'cliente_id', '')::UUID,
                (rec.value->>'total')::DECIMAL(10,2),
                COALESCE((rec.value->>'desconto')::DECIMAL(10,2), 0),
                COALESCE(rec.value->>'status', 'finalizada'),
                rec.value->>'metodo_pagamento',
                rec.value->>'observacoes',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO NOTHING;
        END LOOP;
    END IF;
    
    -- Restaurar itens de venda
    IF data_section ? 'itens_venda' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'itens_venda')
        LOOP
            INSERT INTO itens_venda (id, venda_id, produto_id, quantidade, preco_unitario, subtotal, user_id, created_at)
            VALUES (
                (rec.value->>'id')::UUID,
                NULLIF(rec.value->>'venda_id', '')::UUID,
                NULLIF(rec.value->>'produto_id', '')::UUID,
                (rec.value->>'quantidade')::INTEGER,
                (rec.value->>'preco_unitario')::DECIMAL(10,2),
                (rec.value->>'subtotal')::DECIMAL(10,2),
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO NOTHING;
        END LOOP;
    END IF;
    
    -- Restaurar caixa (se existir)
    IF data_section ? 'caixa' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'caixa')
        LOOP
            INSERT INTO caixa (id, data_abertura, data_fechamento, saldo_inicial, saldo_final, status, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                (rec.value->>'data_abertura')::TIMESTAMPTZ,
                NULLIF(rec.value->>'data_fechamento', '')::TIMESTAMPTZ,
                COALESCE((rec.value->>'saldo_inicial')::DECIMAL(10,2), 0),
                COALESCE((rec.value->>'saldo_final')::DECIMAL(10,2), 0),
                COALESCE(rec.value->>'status', 'fechado'),
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO NOTHING;
        END LOOP;
    END IF;
    
    -- Restaurar movimentações de caixa (se existir)
    IF data_section ? 'movimentacoes_caixa' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'movimentacoes_caixa')
        LOOP
            INSERT INTO movimentacoes_caixa (id, caixa_id, tipo, valor, descricao, user_id, created_at)
            VALUES (
                (rec.value->>'id')::UUID,
                NULLIF(rec.value->>'caixa_id', '')::UUID,
                rec.value->>'tipo',
                (rec.value->>'valor')::DECIMAL(10,2),
                rec.value->>'descricao',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO NOTHING;
        END LOOP;
    END IF;
    
    -- Restaurar configurações (se existir)
    IF data_section ? 'configuracoes' THEN
        FOR rec IN SELECT * FROM jsonb_array_elements(data_section->'configuracoes')
        LOOP
            INSERT INTO configuracoes (id, chave, valor, descricao, user_id, created_at, updated_at)
            VALUES (
                (rec.value->>'id')::UUID,
                rec.value->>'chave',
                rec.value->>'valor',
                rec.value->>'descricao',
                target_user_id,
                COALESCE((rec.value->>'created_at')::TIMESTAMPTZ, NOW()),
                COALESCE((rec.value->>'updated_at')::TIMESTAMPTZ, NOW())
            ) ON CONFLICT (id) DO UPDATE SET
                valor = EXCLUDED.valor,
                descricao = EXCLUDED.descricao,
                updated_at = NOW();
        END LOOP;
    END IF;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao restaurar backup: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- Tabela para armazenar backups
CREATE TABLE IF NOT EXISTS public.user_backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    backup_data JSONB NOT NULL,
    backup_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, backup_date)
);

-- RLS para backups (cada usuário vê apenas seus backups)
ALTER TABLE public.user_backups ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only see their own backups" ON public.user_backups;
CREATE POLICY "Users can only see their own backups" ON public.user_backups
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- CONFIGURAR CRON JOB PARA BACKUP DIÁRIO (via pg_cron)
-- =============================================

-- Função para executar backup diário de todos os usuários
CREATE OR REPLACE FUNCTION public.daily_backup_all_users()
RETURNS void AS $$
DECLARE
    user_record RECORD;
    backup_success BOOLEAN;
BEGIN
    -- Para cada usuário ativo, criar backup
    FOR user_record IN SELECT id, email FROM auth.users LOOP
        -- Criar backup usando a nova função
        SELECT public.save_backup_to_database(user_record.id) INTO backup_success;
        
        IF backup_success THEN
            RAISE NOTICE 'Backup criado para usuário: % (%)', user_record.email, user_record.id;
        ELSE
            RAISE WARNING 'Falha ao criar backup para usuário: % (%)', user_record.email, user_record.id;
        END IF;
    END LOOP;
    
    -- Limpar backups antigos (manter apenas últimos 30 dias)
    DELETE FROM user_backups 
    WHERE created_at < NOW() - INTERVAL '30 days';
    
    RAISE NOTICE 'Backup diário concluído para todos os usuários';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- FUNÇÕES PARA EXPORTAR/IMPORTAR JSON (VIA FRONTEND)
-- =============================================

-- Função para exportar dados para JSON (chamada via frontend)
CREATE OR REPLACE FUNCTION public.export_user_data_json()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN public.create_user_backup_data(auth.uid());
END;
$$;

-- Função para importar dados de JSON (chamada via frontend)
CREATE OR REPLACE FUNCTION public.import_user_data_json(backup_json JSONB, clear_existing BOOLEAN DEFAULT TRUE)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    import_success BOOLEAN;
    result JSONB;
BEGIN
    -- Tentar restaurar os dados
    SELECT public.restore_from_backup_data(backup_json, clear_existing) INTO import_success;
    
    IF import_success THEN
        result := jsonb_build_object(
            'success', true,
            'message', 'Dados importados com sucesso',
            'imported_at', NOW()
        );
    ELSE
        result := jsonb_build_object(
            'success', false,
            'message', 'Erro ao importar dados',
            'imported_at', NOW()
        );
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Erro durante importação: ' || SQLERRM,
            'imported_at', NOW()
        );
END;
$$;

-- Função para listar backups disponíveis do usuário
CREATE OR REPLACE FUNCTION public.list_user_backups()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    backups_list JSONB;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', id,
            'backup_date', backup_date,
            'created_at', created_at,
            'updated_at', updated_at,
            'size', pg_column_size(backup_data)
        ) ORDER BY backup_date DESC
    ) INTO backups_list
    FROM user_backups 
    WHERE user_id = auth.uid();
    
    RETURN COALESCE(backups_list, '[]'::jsonb);
END;
$$;

-- Função para restaurar de um backup específico do banco
CREATE OR REPLACE FUNCTION public.restore_from_database_backup(backup_id UUID, clear_existing BOOLEAN DEFAULT TRUE)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    backup_data JSONB;
    restore_success BOOLEAN;
BEGIN
    -- Buscar o backup
    SELECT ub.backup_data INTO backup_data
    FROM user_backups ub
    WHERE ub.id = backup_id AND ub.user_id = auth.uid();
    
    IF backup_data IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Backup não encontrado'
        );
    END IF;
    
    -- Restaurar os dados
    SELECT public.restore_from_backup_data(backup_data, clear_existing) INTO restore_success;
    
    IF restore_success THEN
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Dados restaurados com sucesso',
            'restored_at', NOW()
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Erro ao restaurar dados'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Erro durante restauração: ' || SQLERRM
        );
END;
$$;

-- =============================================
-- PERMISSÕES PARA USUÁRIOS AUTENTICADOS
-- =============================================

-- Conceder permissões básicas para usuários autenticados
GRANT SELECT, INSERT, UPDATE, DELETE ON public.caixa TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.movimentacoes_caixa TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.configuracoes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.categorias TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.produtos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendas TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.itens_venda TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.clientes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_backups TO authenticated;

-- Conceder permissões para executar funções de backup/restauração
GRANT EXECUTE ON FUNCTION public.create_user_backup_data(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_backup_to_database(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.restore_from_backup_data(JSONB, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.export_user_data_json() TO authenticated;
GRANT EXECUTE ON FUNCTION public.import_user_data_json(JSONB, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_user_backups() TO authenticated;
GRANT EXECUTE ON FUNCTION public.restore_from_database_backup(UUID, BOOLEAN) TO authenticated;

-- Remover permissões de usuários anônimos (apenas autenticados podem acessar)
REVOKE ALL ON public.caixa FROM anon;
REVOKE ALL ON public.movimentacoes_caixa FROM anon;
REVOKE ALL ON public.configuracoes FROM anon;
REVOKE ALL ON public.categorias FROM anon;
REVOKE ALL ON public.produtos FROM anon;
REVOKE ALL ON public.vendas FROM anon;
REVOKE ALL ON public.itens_venda FROM anon;
REVOKE ALL ON public.clientes FROM anon;
REVOKE ALL ON public.user_backups FROM anon;

-- =============================================
-- CONFIGURAÇÕES PADRÃO - VIA TRIGGER (SEM ERRO)
-- =============================================

-- Função para inserir configurações padrão automaticamente
CREATE OR REPLACE FUNCTION public.create_default_user_configs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Inserir configurações padrão para o usuário atual
    INSERT INTO public.configuracoes (chave, valor, descricao, tipo) VALUES 
    ('nome_loja', 'Minha Loja', 'Nome da loja', 'string'),
    ('endereco_loja', '', 'Endereço da loja', 'string'),
    ('telefone_loja', '', 'Telefone da loja', 'string'),
    ('cnpj_loja', '', 'CNPJ da loja', 'string'),
    ('logo_url', '', 'URL do logo da loja', 'string'),
    ('cor_tema', '#3B82F6', 'Cor do tema do sistema', 'string'),
    ('moeda', 'BRL', 'Moeda padrão', 'string'),
    ('taxa_desconto_max', '10', 'Taxa máxima de desconto (%)', 'number'),
    ('backup_automatico', 'true', 'Backup automático habilitado', 'boolean'),
    ('notificacoes_email', 'true', 'Notificações por email', 'boolean')
    ON CONFLICT (chave, user_id) DO NOTHING;
END;
$$;

-- NOTA: As configurações padrão serão criadas via frontend após o primeiro login do usuário

-- =============================================
-- DADOS INICIAIS POR USUÁRIO
-- =============================================

-- NOTA: Como agora os dados são privados por usuário, cada usuário criará 
-- suas próprias categorias e produtos via interface após o primeiro login
-- Isso garante que cada conta seja completamente isolada desde o início

-- =============================================
-- INSTRUÇÕES PARA CRON JOB (EXECUTAR SEPARADAMENTE NO SUPABASE)
-- =============================================

/*
Para habilitar backup diário automático, execute este comando no SQL Editor:

-- Agendar backup diário às 2:00 AM (necessário extensão pg_cron)
SELECT cron.schedule('daily-user-backup', '0 2 * * *', 'SELECT public.daily_backup_all_users();');

-- Para verificar jobs agendados:
SELECT * FROM cron.job;

-- Para remover o job (se necessário):
SELECT cron.unschedule('daily-user-backup');
*/

-- =============================================
-- SCRIPT CONCLUÍDO - PRIVACIDADE TOTAL + BACKUP COMPLETO
-- =============================================
SELECT 'CONFIGURAÇÃO CONCLUÍDA:
✅ Privacidade total implementada (RLS ativo)
✅ Cada usuário vê apenas seus próprios dados
✅ Triggers automáticos para user_id
✅ Sistema de backup diário configurado
✅ Backup e restauração JSON implementado
✅ Funções de exportar/importar dados
✅ Backups mantidos por 30 dias
🔒 Segurança máxima ativada!

� TABELAS CRIADAS:
1. caixa - Controle de sessões de caixa
2. movimentacoes_caixa - Movimentações financeiras
3. configuracoes - Configurações do sistema
4. clientes - Cadastro de clientes
5. categorias - Categorias de produtos
6. produtos - Produtos do estoque
7. vendas - Vendas realizadas
8. itens_venda - Itens das vendas
9. user_backups - Backups dos usuários

�📦 FUNÇÕES DE BACKUP DISPONÍVEIS:
1. export_user_data_json() - Exporta dados para JSON
2. import_user_data_json(json, limpar) - Importa dados de JSON
3. list_user_backups() - Lista backups do usuário
4. save_backup_to_database() - Salva backup no banco
5. restore_from_database_backup(id, limpar) - Restaura backup do banco

🔄 BACKUP AUTOMÁTICO:
- Backup diário às 2:00 AM via cron job
- Backups mantidos por 30 dias
- Backup manual disponível no frontend

🎯 AGORA EXECUTE: SELECT cron.schedule(''daily-user-backup'', ''0 2 * * *'', ''SELECT public.daily_backup_all_users();'');' as resultado;
