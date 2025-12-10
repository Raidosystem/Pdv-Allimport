-- SQL PARA SUPABASE - MÓDULO CAIXA PDV ALLIMPORT
-- Cole APENAS este conteúdo no SQL Editor do Supabase
-- https://supabase.com/dashboard/project/your-project-ref/sql

-- Verificar se as tabelas já existem
SELECT 'Verificando tabela caixa...' as status;
SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
    THEN 'Tabela caixa JÁ EXISTE ✅' 
    ELSE 'Tabela caixa NÃO EXISTE ❌' 
END as resultado;

SELECT 'Verificando tabela movimentacoes_caixa...' as status;
SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
    THEN 'Tabela movimentacoes_caixa JÁ EXISTE ✅' 
    ELSE 'Tabela movimentacoes_caixa NÃO EXISTE ❌' 
END as resultado;

-- Criar tabela caixa (se não existir)
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2) DEFAULT NULL,
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto',
    diferenca DECIMAL(10,2) DEFAULT NULL,
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Criar tabela movimentacoes_caixa (se não existir)
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID NOT NULL REFERENCES public.caixa(id) ON DELETE CASCADE,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    venda_id UUID DEFAULT NULL,
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Desabilitar RLS (Row Level Security)
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_caixa_usuario ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_tipo ON public.movimentacoes_caixa(tipo);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario ON public.movimentacoes_caixa(usuario_id);

-- Verificação final
SELECT 'DEPLOY CONCLUÍDO!' as status;
SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
    THEN '✅ Tabela caixa criada com sucesso' 
    ELSE '❌ Erro na criação da tabela caixa' 
END as resultado_caixa;

SELECT CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
    THEN '✅ Tabela movimentacoes_caixa criada com sucesso' 
    ELSE '❌ Erro na criação da tabela movimentacoes_caixa' 
END as resultado_movimentacoes;

SELECT '🎉 Módulo Caixa pronto para uso!' as conclusao;
