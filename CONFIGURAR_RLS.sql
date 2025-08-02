-- 🔒 SCRIPT PARTE 2: Configurar RLS e Políticas
-- Execute após o RENOMEAR_SIMPLES.sql
-- Agora que as colunas user_id existem, podemos criar as políticas

-- 1. Criar tabela clientes se não existir
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

-- 2. Adicionar colunas que podem estar faltando na tabela caixa
ALTER TABLE public.caixa 
ADD COLUMN IF NOT EXISTS diferenca DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS observacoes TEXT,
ADD COLUMN IF NOT EXISTS criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 3. Habilitar RLS em todas as tabelas
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas para tabela caixa
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = user_id);

-- 5. Criar políticas para tabela movimentacoes_caixa
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

-- 6. Criar políticas para tabela clientes
CREATE POLICY "Usuários podem ver seus próprios clientes" ON public.clientes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar clientes" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios clientes" ON public.clientes
    FOR UPDATE USING (auth.uid() = user_id);

-- 7. Configurar categories (acesso global)
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

-- 8. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_caixa_user_id ON public.caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_user_id ON public.movimentacoes_caixa(user_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- 9. Função para atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10. Trigger para updated_at na tabela caixa
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
CREATE TRIGGER update_caixa_updated_at
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===== VERIFICAÇÕES FINAIS =====

-- Verificar RLS ativo
SELECT 
    'RLS STATUS:' as info,
    tablename,
    CASE WHEN rowsecurity THEN '🔒 RLS Ativo' ELSE '🔓 RLS Inativo' END as status
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'clientes', 'categories')
AND schemaname = 'public'
ORDER BY tablename;

-- Contar políticas criadas
SELECT 
    'POLÍTICAS CRIADAS:' as info,
    COUNT(*)::text as total
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('caixa', 'movimentacoes_caixa', 'clientes');

-- Verificar categorias
SELECT 
    'CATEGORIAS:' as info,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories' AND table_schema = 'public')
         THEN (SELECT COUNT(*)::text FROM public.categories)
         ELSE 'Tabela não existe' END as total;

SELECT '🎉 CONFIGURAÇÃO RLS CONCLUÍDA! Sistema PDV pronto para uso.' as resultado;
