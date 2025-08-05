-- CORREÇÃO RÁPIDA - MÓDULO CAIXA PDV ALLIMPORT
-- Cole este SQL no Supabase Dashboard e clique RUN

-- Tabela principal do caixa
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

-- Tabela de movimentações
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

-- Desabilitar RLS
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- Função para abrir caixa
CREATE OR REPLACE FUNCTION abrir_caixa(user_id UUID, valor_inicial DECIMAL(10,2) DEFAULT 0.00)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    novo_caixa_id UUID;
    tem_caixa_aberto INTEGER;
BEGIN
    -- Verificar se já tem caixa aberto
    SELECT COUNT(*) INTO tem_caixa_aberto
    FROM public.caixa
    WHERE usuario_id = user_id AND status = 'aberto';
    
    IF tem_caixa_aberto > 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Já existe um caixa aberto para este usuário'
        );
    END IF;
    
    -- Inserir novo caixa
    INSERT INTO public.caixa (usuario_id, valor_inicial, status)
    VALUES (user_id, valor_inicial, 'aberto')
    RETURNING id INTO novo_caixa_id;
    
    -- Registrar movimentação inicial se valor > 0
    IF valor_inicial > 0 THEN
        INSERT INTO public.movimentacoes_caixa (caixa_id, tipo, descricao, valor, usuario_id)
        VALUES (novo_caixa_id, 'entrada', 'Abertura de caixa', valor_inicial, user_id);
    END IF;
    
    RETURN json_build_object(
        'success', true,
        'caixa_id', novo_caixa_id,
        'valor_inicial', valor_inicial,
        'message', 'Caixa aberto com sucesso'
    );
END;
$$;

-- Verificação final
SELECT 'CAIXA CONFIGURADO!' as status;
