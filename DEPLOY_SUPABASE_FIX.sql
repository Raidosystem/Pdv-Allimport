-- 🔧 DEPLOY SUPABASE FIX: Corrigir estrutura existente
-- Data: 2025-08-02
-- Projeto: PDV Allimport

-- ===== VERIFICAR E CORRIGIR ESTRUTURA EXISTENTE =====

-- 1. Renomear cash_registers para caixa se necessário
DO $$
BEGIN
    -- Se cash_registers existe mas caixa não, renomear
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cash_registers' AND table_schema = 'public') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa' AND table_schema = 'public') THEN
        ALTER TABLE public.cash_registers RENAME TO caixa;
    END IF;
    
    -- Se caixa existe e tem usuario_id, renomear para user_id
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa' AND column_name = 'usuario_id' AND table_schema = 'public') THEN
        ALTER TABLE public.caixa RENAME COLUMN usuario_id TO user_id;
    END IF;
    
    -- Adicionar colunas que podem estar faltando na tabela caixa
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa' AND table_schema = 'public') THEN
        ALTER TABLE public.caixa 
        ADD COLUMN IF NOT EXISTS diferenca DECIMAL(10,2),
        ADD COLUMN IF NOT EXISTS observacoes TEXT,
        ADD COLUMN IF NOT EXISTS criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        ADD COLUMN IF NOT EXISTS atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- 2. Criar tabela caixa se não existir
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2),
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto' NOT NULL,
    diferenca DECIMAL(10,2),
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. Criar tabela movimentacoes_caixa
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID NOT NULL,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    venda_id UUID,
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 4. Corrigir tabela clientes se necessário
DO $$
BEGIN
    -- Se clientes existe e tem usuario_id, renomear para user_id
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'usuario_id' AND table_schema = 'public') THEN
        ALTER TABLE public.clientes RENAME COLUMN usuario_id TO user_id;
    END IF;
END $$;

-- 5. Criar tabela clientes se não existir
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome TEXT NOT NULL,
    telefone TEXT NOT NULL,
    cpf_cnpj TEXT,
    email TEXT,
    endereco TEXT,
    tipo TEXT CHECK (tipo IN ('Física', 'Jurídica')) DEFAULT 'Física',
    observacoes TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- ===== CONFIGURAR RLS =====

-- Habilitar RLS
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes (se existirem)
DO $$
BEGIN
    -- Políticas para caixa
    DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
    DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
    
    -- Políticas para movimentacoes_caixa
    DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
    DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;
    
    -- Políticas para clientes
    DROP POLICY IF EXISTS "Usuários podem ver seus próprios clientes" ON public.clientes;
    DROP POLICY IF EXISTS "Usuários podem criar clientes" ON public.clientes;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios clientes" ON public.clientes;
EXCEPTION WHEN OTHERS THEN
    NULL; -- Ignorar erros se políticas não existirem
END $$;

-- Criar políticas para caixa
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = user_id);

-- Criar políticas para movimentacoes_caixa
CREATE POLICY "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.user_id = auth.uid()
        )
    );

CREATE POLICY "Usuários podem criar movimentações" ON public.movimentacoes_caixa
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.user_id = auth.uid()
        )
    );

-- Criar políticas para clientes
CREATE POLICY "Usuários podem ver seus próprios clientes" ON public.clientes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar clientes" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios clientes" ON public.clientes
    FOR UPDATE USING (auth.uid() = user_id);

-- ===== CONFIGURAR CATEGORIES =====

-- Desabilitar RLS em categories para acesso global
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') THEN
        ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Inserir categorias padrão (se a tabela existir)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') THEN
        INSERT INTO public.categories (name, description) 
        VALUES 
            ('Eletrônicos', 'Produtos eletrônicos e tecnológicos'),
            ('Roupas', 'Vestuário e acessórios'),
            ('Casa e Jardim', 'Produtos para casa e jardim'),
            ('Esportes', 'Artigos esportivos e fitness'),
            ('Livros', 'Livros e material educativo'),
            ('Alimentação', 'Produtos alimentícios'),
            ('Saúde e Beleza', 'Produtos de saúde e cosméticos'),
            ('Automotivo', 'Peças e acessórios automotivos'),
            ('Informática', 'Equipamentos de informática'),
            ('Ferramentas', 'Ferramentas e equipamentos')
        ON CONFLICT (name) DO NOTHING;
    END IF;
END $$;

-- ===== ÍNDICES PARA PERFORMANCE =====

CREATE INDEX IF NOT EXISTS idx_caixa_user_id ON public.caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_user_id ON public.movimentacoes_caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- ===== FUNÇÕES AUTOMÁTICAS =====

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
CREATE TRIGGER update_caixa_updated_at
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===== VERIFICAÇÕES FINAIS =====

-- Verificar tabelas criadas
SELECT 
    'caixa' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa' AND table_schema = 'public') 
         THEN '✅ OK' ELSE '❌ ERRO' END as status
UNION ALL
SELECT 
    'movimentacoes_caixa' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa' AND table_schema = 'public') 
         THEN '✅ OK' ELSE '❌ ERRO' END as status
UNION ALL
SELECT 
    'clientes' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes' AND table_schema = 'public') 
         THEN '✅ OK' ELSE '❌ ERRO' END as status
UNION ALL
SELECT 
    'categories' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') 
         THEN '✅ OK' ELSE '❌ ERRO' END as status;

-- Verificar se colunas estão corretas
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('caixa', 'clientes') 
AND column_name LIKE '%user%'
AND table_schema = 'public'
ORDER BY table_name, column_name;

SELECT '🎉 DEPLOY SUPABASE FIX CONCLUÍDO! Estrutura corrigida e compatível.' as resultado;
