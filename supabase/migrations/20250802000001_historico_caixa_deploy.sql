-- Migração para melhorias do sistema de caixa e histórico
-- Data: 2025-08-02
-- Descrição: Adicionar funcionalidades completas de histórico do caixa

-- ===== VERIFICAR E CRIAR TABELAS NECESSÁRIAS =====

-- 1. Verificar e criar tabela de caixa se não existir
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

-- 2. Verificar e criar tabela de movimentações do caixa se não existir
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

-- ===== CONFIGURAR RLS (ROW LEVEL SECURITY) =====

-- Habilitar RLS nas tabelas
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;

-- Políticas para tabela caixa
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = usuario_id);

-- Políticas para tabela movimentacoes_caixa
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

-- Índices para melhorar performance das consultas
CREATE INDEX IF NOT EXISTS idx_caixa_usuario_id ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario_id ON public.movimentacoes_caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- ===== FUNÇÕES PARA AUTOMATIZAR ATUALIZAÇÕES =====

-- Função para atualizar timestamp de atualização
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar automaticamente o campo atualizado_em
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
CREATE TRIGGER update_caixa_updated_at
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===== FUNÇÃO PARA CALCULAR DIFERENÇA NO FECHAMENTO =====

-- Função para calcular automaticamente a diferença ao fechar o caixa
CREATE OR REPLACE FUNCTION calcular_diferenca_caixa()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o status mudou para 'fechado' e valor_final foi definido
    IF NEW.status = 'fechado' AND NEW.valor_final IS NOT NULL THEN
        -- Calcular total de entradas
        WITH totais AS (
            SELECT 
                COALESCE(SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE 0 END), 0) as total_entradas,
                COALESCE(SUM(CASE WHEN tipo = 'saida' THEN valor ELSE 0 END), 0) as total_saidas
            FROM public.movimentacoes_caixa 
            WHERE caixa_id = NEW.id
        )
        SELECT 
            NEW.valor_final - (NEW.valor_inicial + total_entradas - total_saidas)
        INTO NEW.diferenca
        FROM totais;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para calcular diferença automaticamente
DROP TRIGGER IF EXISTS trigger_calcular_diferenca ON public.caixa;
CREATE TRIGGER trigger_calcular_diferenca
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION calcular_diferenca_caixa();

-- ===== GARANTIR CATEGORIAS FUNCIONAM =====

-- Verificar e criar tabela categories se necessário
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Desabilitar RLS em categories para acesso público
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;

-- ===== DADOS INICIAIS =====

-- Inserir categorias padrão se não existirem
INSERT INTO public.categories (name, description) 
SELECT 'Eletrônicos', 'Produtos eletrônicos e tecnológicos'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Eletrônicos');

INSERT INTO public.categories (name, description) 
SELECT 'Roupas', 'Vestuário e acessórios'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Roupas');

INSERT INTO public.categories (name, description) 
SELECT 'Casa e Jardim', 'Produtos para casa e jardim'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Casa e Jardim');

INSERT INTO public.categories (name, description) 
SELECT 'Esportes', 'Artigos esportivos e fitness'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Esportes');

INSERT INTO public.categories (name, description) 
SELECT 'Livros', 'Livros e material educativo'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Livros');

-- ===== VERIFICAÇÕES FINAIS =====

-- Verificar se todas as tabelas foram criadas
SELECT 
    'caixa' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
         THEN '✅ Criada' ELSE '❌ Erro' END as status
UNION ALL
SELECT 
    'movimentacoes_caixa' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
         THEN '✅ Criada' ELSE '❌ Erro' END as status
UNION ALL
SELECT 
    'categories' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') 
         THEN '✅ Criada' ELSE '❌ Erro' END as status;

-- Verificar se as políticas RLS estão ativas
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'categories')
AND schemaname = 'public';

SELECT '🎉 Migração concluída com sucesso! Sistema de caixa e histórico configurado.' as resultado;
