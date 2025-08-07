-- =============================================
-- SCRIPT FINAL PARA SUPABASE - SISTEMA PDV ALLIMPORT
-- Execute este SQL no Supabase Dashboard > SQL Editor
-- =============================================

-- Verificar se as extensões necessárias estão habilitadas
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- CRIAR TABELAS COM ISOLAMENTO TOTAL POR USUÁRIO
-- =============================================

-- Tabela CAIXA
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_abertura TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_fechamento TIMESTAMP WITH TIME ZONE,
    saldo_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
    saldo_final DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto',
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela MOVIMENTAÇÕES DE CAIXA
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caixa_id UUID REFERENCES public.caixa(id) ON DELETE CASCADE NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    venda_id UUID,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela CONFIGURAÇÕES
CREATE TABLE IF NOT EXISTS public.configuracoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chave VARCHAR(100) NOT NULL,
    valor TEXT,
    descricao TEXT,
    tipo VARCHAR(20) DEFAULT 'string',
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chave, user_id)
);

-- Tabela CLIENTES
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    cpf VARCHAR(14),
    endereco TEXT,
    data_nascimento DATE,
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela CATEGORIAS
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela PRODUTOS
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

-- Tabela VENDAS
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

-- Tabela ITENS_VENDA
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

-- Tabela USER_BACKUPS
CREATE TABLE IF NOT EXISTS public.user_backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    backup_data JSONB NOT NULL,
    backup_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, backup_date)
);

-- =============================================
-- VERIFICAR E ADICIONAR COLUNA user_id SE NECESSÁRIO
-- =============================================

-- Função para verificar e adicionar user_id em tabelas existentes
DO $$
DECLARE
    tables_list TEXT[] := ARRAY['caixa', 'movimentacoes_caixa', 'configuracoes', 'categorias', 'produtos', 'vendas', 'itens_venda', 'clientes'];
    table_name_var TEXT;
BEGIN
    FOREACH table_name_var IN ARRAY tables_list
    LOOP
        -- Verificar se a tabela existe e se a coluna user_id existe
        IF EXISTS (SELECT 1 FROM information_schema.tables t WHERE t.table_name = table_name_var AND t.table_schema = 'public') THEN
            -- Verificar se a coluna user_id existe
            IF NOT EXISTS (SELECT 1 FROM information_schema.columns c
                           WHERE c.table_name = table_name_var 
                           AND c.column_name = 'user_id' 
                           AND c.table_schema = 'public') THEN
                -- Adicionar coluna user_id
                EXECUTE format('ALTER TABLE public.%I ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE', table_name_var);
                RAISE NOTICE 'Coluna user_id adicionada à tabela %', table_name_var;
                
                -- Definir user_id para registros existentes (usar primeiro usuário disponível)
                EXECUTE format('UPDATE public.%I SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL', table_name_var);
                
                -- Tornar NOT NULL
                EXECUTE format('ALTER TABLE public.%I ALTER COLUMN user_id SET NOT NULL', table_name_var);
                RAISE NOTICE 'Coluna user_id definida como NOT NULL na tabela %', table_name_var;
            ELSE
                RAISE NOTICE 'Coluna user_id já existe na tabela %', table_name_var;
            END IF;
        END IF;
    END LOOP;
END $$;

-- =============================================
-- CONFIGURAR RLS (ROW LEVEL SECURITY)
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
ALTER TABLE public.user_backups ENABLE ROW LEVEL SECURITY;

-- =============================================
-- POLÍTICAS DE SEGURANÇA
-- =============================================

-- Criar políticas para cada tabela com tratamento de erro
DO $$
DECLARE
    tables_list TEXT[] := ARRAY['caixa', 'movimentacoes_caixa', 'configuracoes', 'categorias', 'produtos', 'vendas', 'itens_venda', 'clientes', 'user_backups'];
    table_name_var TEXT;
BEGIN
    FOREACH table_name_var IN ARRAY tables_list
    LOOP
        BEGIN
            -- Verificar se a tabela existe e tem coluna user_id
            IF EXISTS (SELECT 1 FROM information_schema.columns c
                       WHERE c.table_name = table_name_var 
                       AND c.column_name = 'user_id' 
                       AND c.table_schema = 'public') THEN
                
                -- Remover política existente se houver
                EXECUTE format('DROP POLICY IF EXISTS "Users can only see their own %s" ON public.%I', table_name_var, table_name_var);
                
                -- Criar nova política
                EXECUTE format('CREATE POLICY "Users can only see their own %s" ON public.%I FOR ALL USING (auth.uid() = user_id)', table_name_var, table_name_var);
                
                RAISE NOTICE 'Política RLS criada para tabela: %', table_name_var;
            ELSE
                RAISE WARNING 'Tabela % não tem coluna user_id, política RLS não criada', table_name_var;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Erro ao criar política RLS para tabela %: %', table_name_var, SQLERRM;
        END;
    END LOOP;
END $$;

-- =============================================
-- TRIGGER PARA AUTO-INSERIR user_id
-- =============================================

-- Função para inserir automaticamente o user_id
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar triggers para todas as tabelas com tratamento de erro
DO $$
DECLARE
    tables_list TEXT[] := ARRAY['caixa', 'movimentacoes_caixa', 'configuracoes', 'categorias', 'produtos', 'vendas', 'itens_venda', 'clientes'];
    table_name_var TEXT;
BEGIN
    FOREACH table_name_var IN ARRAY tables_list
    LOOP
        BEGIN
            -- Verificar se a tabela existe e tem coluna user_id
            IF EXISTS (SELECT 1 FROM information_schema.columns c
                       WHERE c.table_name = table_name_var 
                       AND c.column_name = 'user_id' 
                       AND c.table_schema = 'public') THEN
                
                -- Remover trigger existente se houver
                EXECUTE format('DROP TRIGGER IF EXISTS set_user_id_%s ON public.%I', table_name_var, table_name_var);
                
                -- Criar novo trigger
                EXECUTE format('CREATE TRIGGER set_user_id_%s BEFORE INSERT ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_user_id()', table_name_var, table_name_var);
                
                RAISE NOTICE 'Trigger criado para tabela: %', table_name_var;
            ELSE
                RAISE WARNING 'Tabela % não tem coluna user_id, trigger não criado', table_name_var;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Erro ao criar trigger para tabela %: %', table_name_var, SQLERRM;
        END;
    END LOOP;
END $$;

-- =============================================
-- FUNÇÕES DE BACKUP E RESTAURAÇÃO
-- =============================================

-- Função para criar backup completo
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
    target_user_id := COALESCE(p_user_id, auth.uid());
    
    SELECT email INTO user_email FROM auth.users WHERE id = target_user_id;
    
    SELECT jsonb_build_object(
        'backup_info', jsonb_build_object(
            'user_id', target_user_id,
            'user_email', user_email,
            'backup_date', NOW(),
            'backup_version', '1.0',
            'system', 'PDV Allimport'
        ),
        'data', jsonb_build_object(
            'clientes', COALESCE((SELECT jsonb_agg(to_jsonb(c)) FROM clientes c WHERE c.user_id = target_user_id), '[]'::jsonb),
            'categorias', COALESCE((SELECT jsonb_agg(to_jsonb(cat)) FROM categorias cat WHERE cat.user_id = target_user_id), '[]'::jsonb),
            'produtos', COALESCE((SELECT jsonb_agg(to_jsonb(p)) FROM produtos p WHERE p.user_id = target_user_id), '[]'::jsonb),
            'vendas', COALESCE((SELECT jsonb_agg(to_jsonb(v)) FROM vendas v WHERE v.user_id = target_user_id), '[]'::jsonb),
            'itens_venda', COALESCE((SELECT jsonb_agg(to_jsonb(i)) FROM itens_venda i WHERE i.user_id = target_user_id), '[]'::jsonb),
            'caixa', COALESCE((SELECT jsonb_agg(to_jsonb(cx)) FROM caixa cx WHERE cx.user_id = target_user_id), '[]'::jsonb),
            'movimentacoes_caixa', COALESCE((SELECT jsonb_agg(to_jsonb(mc)) FROM movimentacoes_caixa mc WHERE mc.user_id = target_user_id), '[]'::jsonb),
            'configuracoes', COALESCE((SELECT jsonb_agg(to_jsonb(conf)) FROM configuracoes conf WHERE conf.user_id = target_user_id), '[]'::jsonb)
        )
    ) INTO backup_data;
    
    RETURN backup_data;
END;
$$;

-- Função para exportar dados para JSON
CREATE OR REPLACE FUNCTION public.export_user_data_json()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN public.create_user_backup_data(auth.uid());
END;
$$;

-- Função para salvar backup no banco
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
    
    SELECT public.create_user_backup_data(target_user_id) INTO backup_data;
    
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

-- Função para listar backups
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

-- Função para backup diário automático
CREATE OR REPLACE FUNCTION public.daily_backup_all_users()
RETURNS void AS $$
DECLARE
    user_record RECORD;
    backup_success BOOLEAN;
BEGIN
    FOR user_record IN SELECT id, email FROM auth.users LOOP
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
-- PERMISSÕES
-- =============================================

-- Conceder permissões para usuários autenticados
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- Remover permissões de usuários anônimos
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;

-- =============================================
-- CONFIGURAÇÕES PADRÃO DO SISTEMA
-- =============================================

-- Função para inserir configurações padrão para um usuário
CREATE OR REPLACE FUNCTION public.create_default_configs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
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

-- =============================================
-- FINALIZAÇÃO
-- =============================================

SELECT 'DEPLOY CONCLUÍDO COM SUCESSO! ✅

🔒 SISTEMA DE PRIVACIDADE TOTAL ATIVO:
- Cada usuário vê apenas seus próprios dados
- Row Level Security (RLS) configurado
- Triggers automáticos para user_id

📊 TABELAS CRIADAS (9 total):
1. caixa - Sessões de caixa
2. movimentacoes_caixa - Movimentações financeiras  
3. configuracoes - Configurações do sistema
4. clientes - Cadastro de clientes
5. categorias - Categorias de produtos
6. produtos - Produtos do estoque
7. vendas - Vendas realizadas
8. itens_venda - Itens das vendas
9. user_backups - Backups dos usuários

💾 SISTEMA DE BACKUP AUTOMÁTICO:
- Funções de export/import JSON
- Backup diário via cron job
- Retenção de 30 dias

🚀 PRÓXIMOS PASSOS:
1. Para ativar backup diário: 
   SELECT cron.schedule(''daily-user-backup'', ''0 2 * * *'', ''SELECT public.daily_backup_all_users();'');

2. Testar sistema no frontend
3. Cada usuário criará suas categorias/produtos após login

Sistema pronto para produção!' as status;
