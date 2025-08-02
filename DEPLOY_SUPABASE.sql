-- 🚀 DEPLOY SUPABASE: Histórico do Caixa - Execute no SQL Editor
-- Data: 2025-08-02
-- Projeto: PDV Allimport

-- ===== CRIAR/VERIFICAR TABELAS DE CAIXA =====

-- 1. Criar tabela caixa (substitui cash_registers)
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
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

-- 2. Criar tabela movimentacoes_caixa
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID REFERENCES public.caixa(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    venda_id UUID, -- Referência opcional para vendas
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ===== CONFIGURAR RLS =====

-- Habilitar RLS
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes
DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;

-- Criar políticas para caixa
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = usuario_id);

-- Criar políticas para movimentacoes_caixa
CREATE POLICY "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.usuario_id = auth.uid()
        )
    );

CREATE POLICY "Usuários podem criar movimentações" ON public.movimentacoes_caixa
    FOR INSERT WITH CHECK (
        auth.uid() = usuario_id AND
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.usuario_id = auth.uid()
        )
    );

-- ===== ÍNDICES PARA PERFORMANCE =====

CREATE INDEX IF NOT EXISTS idx_caixa_usuario_id ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario_id ON public.movimentacoes_caixa(usuario_id);
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

-- ===== GARANTIR TABELA CLIENTES =====

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
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- RLS para clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem ver seus próprios clientes" ON public.clientes;
DROP POLICY IF EXISTS "Usuários podem criar clientes" ON public.clientes;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios clientes" ON public.clientes;

CREATE POLICY "Usuários podem ver seus próprios clientes" ON public.clientes
    FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar clientes" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar seus próprios clientes" ON public.clientes
    FOR UPDATE USING (auth.uid() = usuario_id);

-- ===== GARANTIR CATEGORIES SEM RLS =====

-- Desabilitar RLS em categories para acesso global
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;

-- Inserir categorias padrão
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

-- ===== DADOS DE TESTE PARA O SISTEMA =====

-- Inserir um usuário de teste se não existir (apenas para desenvolvimento)
-- NOTA: Em produção, os usuários serão criados via signup normal

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

-- Verificar RLS
SELECT 
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '🔒 RLS Ativo' ELSE '🔓 RLS Inativo' END as seguranca
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'clientes', 'categories')
AND schemaname = 'public'
ORDER BY tablename;

-- Contar categorias inseridas
SELECT 
    'Total de categorias:' as info,
    COUNT(*)::text as valor
FROM public.categories;

SELECT '🎉 DEPLOY SUPABASE CONCLUÍDO! Todas as tabelas e políticas configuradas.' as resultado;
