-- 🚀 DEPLOY SUPABASE SIMPLES - Execute no SQL Editor
-- Data: 2025-08-02
-- Versão: Compatível com estruturas existentes

-- ===== VERIFICAR ESTRUTURA EXISTENTE =====

-- Primeiro, vamos verificar qual estrutura já existe
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('cash_registers', 'caixa', 'customers', 'clientes')
ORDER BY table_name, ordinal_position;

-- ===== CRIAR TABELAS FALTANTES =====

-- Tabela de caixa (usando nome padrão brasileiro)
CREATE TABLE IF NOT EXISTS public.caixa_historico (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2),
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto' NOT NULL,
    diferenca DECIMAL(10,2),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Tabela de movimentações do caixa
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID REFERENCES public.caixa_historico(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    venda_id UUID, -- Referência opcional
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ===== CONFIGURAR SEGURANÇA =====

-- Habilitar RLS
ALTER TABLE public.caixa_historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "users_select_own_caixa" ON public.caixa_historico;
DROP POLICY IF EXISTS "users_insert_own_caixa" ON public.caixa_historico;
DROP POLICY IF EXISTS "users_update_own_caixa" ON public.caixa_historico;
DROP POLICY IF EXISTS "users_select_own_movimentacoes" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "users_insert_own_movimentacoes" ON public.movimentacoes_caixa;

-- Criar políticas simples
CREATE POLICY "users_select_own_caixa" ON public.caixa_historico
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "users_insert_own_caixa" ON public.caixa_historico
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_update_own_caixa" ON public.caixa_historico
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "users_select_own_movimentacoes" ON public.movimentacoes_caixa
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "users_insert_own_movimentacoes" ON public.movimentacoes_caixa
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ===== ÍNDICES BÁSICOS =====

CREATE INDEX IF NOT EXISTS idx_caixa_historico_user_id ON public.caixa_historico(user_id);
CREATE INDEX IF NOT EXISTS idx_caixa_historico_status ON public.caixa_historico(status);
CREATE INDEX IF NOT EXISTS idx_caixa_historico_data ON public.caixa_historico(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_user_id ON public.movimentacoes_caixa(user_id);

-- ===== INSERIR DADOS DE TESTE =====

-- Inserir algumas categorias se a tabela existir
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        INSERT INTO public.categories (name, description) 
        VALUES 
            ('Eletrônicos', 'Produtos eletrônicos'),
            ('Roupas', 'Vestuário em geral'),
            ('Casa', 'Produtos para casa'),
            ('Esportes', 'Artigos esportivos'),
            ('Livros', 'Livros e materiais')
        ON CONFLICT (name) DO NOTHING;
    END IF;
END $$;

-- ===== FUNÇÃO PARA COMPATIBILIDADE COM CÓDIGO EXISTENTE =====

-- Criar view compatível se necessário
CREATE OR REPLACE VIEW public.caixa AS 
SELECT 
    id,
    user_id as usuario_id, -- Compatibilidade com código
    valor_inicial,
    valor_final,
    data_abertura,
    data_fechamento,
    status,
    diferenca,
    observacoes,
    created_at as criado_em,
    updated_at as atualizado_em
FROM public.caixa_historico;

-- Habilitar RLS na view também
ALTER VIEW public.caixa SET (security_barrier = true);

-- ===== VERIFICAÇÕES FINAIS =====

SELECT 
    'Verificação das tabelas criadas:' as titulo,
    '' as resultado
UNION ALL
SELECT 
    'caixa_historico' as titulo,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa_historico') 
         THEN '✅ Criada' ELSE '❌ Erro' END as resultado
UNION ALL
SELECT 
    'movimentacoes_caixa' as titulo,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
         THEN '✅ Criada' ELSE '❌ Erro' END as resultado;

-- Verificar se há usuários cadastrados
SELECT 
    'Total de usuários:' as info,
    COUNT(*)::text as valor
FROM auth.users;

SELECT '🎉 DEPLOY BÁSICO CONCLUÍDO! Sistema preparado para histórico do caixa.' as resultado;
