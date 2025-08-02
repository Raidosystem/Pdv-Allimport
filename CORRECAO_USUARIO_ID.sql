-- 🔧 CORREÇÃO ESPECÍFICA: Renomear usuario_id para user_id
-- Data: 2025-08-02
-- Projeto: PDV Allimport

-- Este script corrige as colunas usuario_id para user_id nas tabelas existentes

-- 1. PRIMEIRO: Desabilitar RLS temporariamente para evitar erros
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- 2. Remover todas as políticas existentes que podem usar usuario_id ou user_id
DO $$
BEGIN
    -- Remover políticas da tabela caixa
    DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
    DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
    DROP POLICY IF EXISTS "Users can view own cash registers" ON public.caixa;
    DROP POLICY IF EXISTS "Users can create cash registers" ON public.caixa;
    DROP POLICY IF EXISTS "Users can update own cash registers" ON public.caixa;
    
    -- Remover políticas da tabela movimentacoes_caixa
    DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
    DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;
    DROP POLICY IF EXISTS "Users can view own movements" ON public.movimentacoes_caixa;
    DROP POLICY IF EXISTS "Users can create movements" ON public.movimentacoes_caixa;
EXCEPTION WHEN OTHERS THEN
    NULL; -- Ignorar erros se políticas não existirem
END $$;

-- 3. Renomear usuario_id para user_id na tabela caixa
ALTER TABLE public.caixa RENAME COLUMN usuario_id TO user_id;

-- 4. Renomear usuario_id para user_id na tabela movimentacoes_caixa
ALTER TABLE public.movimentacoes_caixa RENAME COLUMN usuario_id TO user_id;

-- 5. Adicionar colunas que podem estar faltando na tabela caixa
ALTER TABLE public.caixa 
ADD COLUMN IF NOT EXISTS diferenca DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS observacoes TEXT,
ADD COLUMN IF NOT EXISTS criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 6. Verificar se tabela clientes existe, se não criar
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

-- 7. AGORA: Reabilitar RLS após as correções
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 8. Remover políticas clientes existentes (se existirem)
DO $$
BEGIN
    DROP POLICY IF EXISTS "Usuários podem ver seus próprios clientes" ON public.clientes;
    DROP POLICY IF EXISTS "Usuários podem criar clientes" ON public.clientes;
    DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios clientes" ON public.clientes;
    DROP POLICY IF EXISTS "Users can view own clients" ON public.clientes;
    DROP POLICY IF EXISTS "Users can create clients" ON public.clientes;
    DROP POLICY IF EXISTS "Users can update own clients" ON public.clientes;
EXCEPTION WHEN OTHERS THEN
    NULL; -- Ignorar erros se políticas não existirem
END $$;

-- 9. Criar políticas para caixa (APÓS renomear colunas)
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = user_id);

-- 10. Criar políticas para movimentacoes_caixa (APÓS renomear colunas)
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

-- 11. Criar políticas para clientes (APÓS renomear colunas)
CREATE POLICY "Usuários podem ver seus próprios clientes" ON public.clientes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar clientes" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios clientes" ON public.clientes
    FOR UPDATE USING (auth.uid() = user_id);

-- 12. Configurar categories (desabilitar RLS para acesso global)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public') THEN
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
    END IF;
END $$;

-- 13. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_caixa_user_id ON public.caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_user_id ON public.movimentacoes_caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- 14. Função para atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 15. Trigger para updated_at na tabela caixa
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
CREATE TRIGGER update_caixa_updated_at
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===== VERIFICAÇÕES FINAIS =====

-- Verificar se as colunas foram renomeadas corretamente
SELECT 
    'VERIFICAÇÃO - Colunas corrigidas:' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name IN ('caixa', 'movimentacoes_caixa', 'clientes')
AND column_name = 'user_id'
ORDER BY table_name;

-- Verificar RLS ativo
SELECT 
    'VERIFICAÇÃO - RLS:' as info,
    tablename,
    CASE WHEN rowsecurity THEN '🔒 RLS Ativo' ELSE '🔓 RLS Inativo' END as seguranca
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'clientes')
AND schemaname = 'public'
ORDER BY tablename;

-- Contar categorias (se existir)
SELECT 
    'VERIFICAÇÃO - Categorias:' as info,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public')
         THEN (SELECT COUNT(*)::text FROM public.categories)
         ELSE 'Tabela não existe' END as total;

SELECT '🎉 CORREÇÃO CONCLUÍDA! Colunas renomeadas de usuario_id para user_id.' as resultado;
