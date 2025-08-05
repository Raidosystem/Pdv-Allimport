-- 🚀 CORREÇÃO COMPLETA DO MÓDULO CAIXA
-- Execute no Supabase SQL Editor
-- Data: 05/08/2025

-- ===== VERIFICAÇÃO INICIAL =====
SELECT 'VERIFICANDO TABELAS EXISTENTES...' as status;

-- Verificar tabelas
SELECT 'Tabela caixa existe:' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
            THEN 'SIM' ELSE 'NÃO' END as existe;

SELECT 'Tabela movimentacoes_caixa existe:' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
            THEN 'SIM' ELSE 'NÃO' END as existe;

-- ===== CRIAR TABELA CAIXA =====
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

-- ===== CRIAR TABELA MOVIMENTAÇÕES =====
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

-- ===== DESABILITAR RLS (COMO OUTRAS TABELAS DO SISTEMA) =====
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- ===== CRIAR ÍNDICES =====
CREATE INDEX IF NOT EXISTS idx_caixa_usuario ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_caixa_usuario_status ON public.caixa(usuario_id, status);

CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_tipo ON public.movimentacoes_caixa(tipo);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario ON public.movimentacoes_caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- ===== CRIAR FUNÇÕES NECESSÁRIAS =====

-- Função para calcular saldo atual do caixa
CREATE OR REPLACE FUNCTION calcular_saldo_caixa(caixa_uuid UUID)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    saldo_atual DECIMAL(10,2) := 0;
    valor_inicial_caixa DECIMAL(10,2) := 0;
BEGIN
    -- Buscar valor inicial do caixa
    SELECT valor_inicial INTO valor_inicial_caixa 
    FROM public.caixa 
    WHERE id = caixa_uuid;
    
    -- Se não encontrou o caixa, retornar 0
    IF valor_inicial_caixa IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Calcular saldo com movimentações
    SELECT 
        valor_inicial_caixa + COALESCE(
            SUM(CASE 
                WHEN tipo = 'entrada' THEN valor 
                WHEN tipo = 'saida' THEN -valor 
                ELSE 0 
            END), 0
        ) INTO saldo_atual
    FROM public.movimentacoes_caixa 
    WHERE caixa_id = caixa_uuid;
    
    RETURN COALESCE(saldo_atual, valor_inicial_caixa);
END;
$$;

-- Função para verificar se usuário tem caixa aberto
CREATE OR REPLACE FUNCTION usuario_tem_caixa_aberto(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    caixa_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO caixa_count
    FROM public.caixa
    WHERE usuario_id = user_id AND status = 'aberto';
    
    RETURN caixa_count > 0;
END;
$$;

-- Função para obter caixa aberto do usuário
CREATE OR REPLACE FUNCTION obter_caixa_aberto(user_id UUID)
RETURNS TABLE(
    id UUID,
    valor_inicial DECIMAL(10,2),
    data_abertura TIMESTAMP WITH TIME ZONE,
    saldo_atual DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.valor_inicial,
        c.data_abertura,
        calcular_saldo_caixa(c.id) as saldo_atual
    FROM public.caixa c
    WHERE c.usuario_id = user_id AND c.status = 'aberto'
    ORDER BY c.data_abertura DESC
    LIMIT 1;
END;
$$;

-- Função para abrir novo caixa
CREATE OR REPLACE FUNCTION abrir_caixa(user_id UUID, valor_inicial DECIMAL(10,2) DEFAULT 0.00)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    novo_caixa_id UUID;
    tem_caixa_aberto BOOLEAN;
BEGIN
    -- Verificar se já tem caixa aberto
    SELECT usuario_tem_caixa_aberto(user_id) INTO tem_caixa_aberto;
    
    IF tem_caixa_aberto THEN
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

-- Função para fechar caixa
CREATE OR REPLACE FUNCTION fechar_caixa(user_id UUID, valor_final DECIMAL(10,2), observacoes TEXT DEFAULT NULL)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    caixa_ativo_id UUID;
    saldo_calculado DECIMAL(10,2);
    diferenca_valor DECIMAL(10,2);
BEGIN
    -- Buscar caixa aberto do usuário
    SELECT id INTO caixa_ativo_id
    FROM public.caixa
    WHERE usuario_id = user_id AND status = 'aberto'
    ORDER BY data_abertura DESC
    LIMIT 1;
    
    IF caixa_ativo_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Nenhum caixa aberto encontrado'
        );
    END IF;
    
    -- Calcular saldo atual
    SELECT calcular_saldo_caixa(caixa_ativo_id) INTO saldo_calculado;
    
    -- Calcular diferença
    diferenca_valor := valor_final - saldo_calculado;
    
    -- Atualizar caixa
    UPDATE public.caixa
    SET 
        status = 'fechado',
        data_fechamento = NOW(),
        valor_final = valor_final,
        diferenca = diferenca_valor,
        observacoes = COALESCE(observacoes, ''),
        atualizado_em = NOW()
    WHERE id = caixa_ativo_id;
    
    RETURN json_build_object(
        'success', true,
        'caixa_id', caixa_ativo_id,
        'valor_final', valor_final,
        'saldo_calculado', saldo_calculado,
        'diferenca', diferenca_valor,
        'message', 'Caixa fechado com sucesso'
    );
END;
$$;

-- ===== TRIGGER PARA ATUALIZAR updated_at =====
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger na tabela caixa
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
CREATE TRIGGER update_caixa_updated_at
    BEFORE UPDATE ON public.caixa
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===== VERIFICAÇÃO FINAL =====
SELECT '✅ CRIAÇÃO DAS TABELAS CONCLUÍDA!' as status;

-- Verificar tabelas criadas
SELECT 'Tabela caixa:' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
            THEN '✅ CRIADA' ELSE '❌ ERRO' END as status;

SELECT 'Tabela movimentacoes_caixa:' as tabela, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
            THEN '✅ CRIADA' ELSE '❌ ERRO' END as status;

-- Verificar funções
SELECT 'Função calcular_saldo_caixa:' as funcao,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'calcular_saldo_caixa')
            THEN '✅ CRIADA' ELSE '❌ ERRO' END as status;

SELECT 'Função abrir_caixa:' as funcao,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'abrir_caixa')
            THEN '✅ CRIADA' ELSE '❌ ERRO' END as status;

SELECT 'Função fechar_caixa:' as funcao,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'fechar_caixa')
            THEN '✅ CRIADA' ELSE '❌ ERRO' END as status;

SELECT '🎉 MÓDULO CAIXA CONFIGURADO COM SUCESSO!' as resultado;
