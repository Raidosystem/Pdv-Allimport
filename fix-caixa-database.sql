-- 🚀 MÓDULO CAIXA - ESTRUTURA COMPLETA DO BANCO DE DADOS
-- Execute no Supabase SQL Editor

-- ===== PARTE 1: CRIAR TABELA CAIXA =====

-- Verificar se tabela caixa existe
SELECT 'Tabela caixa existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela caixa
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES auth.users(id),
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2) DEFAULT NULL,
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto',
    diferenca DECIMAL(10,2) DEFAULT NULL,
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ===== PARTE 2: CRIAR TABELA MOVIMENTAÇÕES =====

-- Verificar se tabela movimentacoes_caixa existe
SELECT 'Tabela movimentacoes_caixa existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela movimentacoes_caixa
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID NOT NULL REFERENCES public.caixa(id) ON DELETE CASCADE,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    usuario_id UUID NOT NULL REFERENCES auth.users(id),
    venda_id UUID DEFAULT NULL, -- Para ligar com vendas futuras
    data TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ===== PARTE 3: DESABILITAR RLS (COMO OUTRAS TABELAS) =====

-- Desabilitar RLS em ambas as tabelas
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- ===== PARTE 4: CRIAR ÍNDICES =====

-- Índices para caixa
CREATE INDEX IF NOT EXISTS idx_caixa_usuario ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_caixa_usuario_status ON public.caixa(usuario_id, status);

-- Índices para movimentacoes_caixa
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_tipo ON public.movimentacoes_caixa(tipo);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario ON public.movimentacoes_caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- ===== PARTE 5: CRIAR FUNÇÃO PARA CALCULAR SALDO =====

-- Função para calcular saldo atual do caixa
CREATE OR REPLACE FUNCTION calcular_saldo_caixa(caixa_uuid UUID)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    valor_inicial DECIMAL(10,2);
    total_entradas DECIMAL(10,2);
    total_saidas DECIMAL(10,2);
    saldo_atual DECIMAL(10,2);
BEGIN
    -- Buscar valor inicial
    SELECT c.valor_inicial INTO valor_inicial
    FROM public.caixa c
    WHERE c.id = caixa_uuid;
    
    -- Se não encontrar o caixa, retorna 0
    IF valor_inicial IS NULL THEN
        RETURN 0.00;
    END IF;
    
    -- Calcular total de entradas
    SELECT COALESCE(SUM(valor), 0.00) INTO total_entradas
    FROM public.movimentacoes_caixa
    WHERE caixa_id = caixa_uuid AND tipo = 'entrada';
    
    -- Calcular total de saídas
    SELECT COALESCE(SUM(valor), 0.00) INTO total_saidas
    FROM public.movimentacoes_caixa
    WHERE caixa_id = caixa_uuid AND tipo = 'saida';
    
    -- Calcular saldo atual
    saldo_atual := valor_inicial + total_entradas - total_saidas;
    
    RETURN saldo_atual;
END;
$$;

-- ===== PARTE 6: INSERIR DADOS DE TESTE =====

-- Inserir caixa de teste (só se não existir)
DO $$
DECLARE
    test_user_id UUID;
    test_caixa_id UUID;
BEGIN
    -- Pegar primeiro usuário disponível (ou criar um fictício para teste)
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    -- Se não houver usuários, criar um UUID fictício para teste
    IF test_user_id IS NULL THEN
        test_user_id := gen_random_uuid();
    END IF;
    
    -- Inserir caixa aberto de teste
    INSERT INTO public.caixa (usuario_id, valor_inicial, status, observacoes)
    SELECT test_user_id, 100.00, 'aberto', 'Caixa de teste - abertura do dia'
    WHERE NOT EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE usuario_id = test_user_id AND status = 'aberto'
    )
    RETURNING id INTO test_caixa_id;
    
    -- Se inseriu o caixa, inserir algumas movimentações de teste
    IF test_caixa_id IS NOT NULL THEN
        -- Entrada: Venda
        INSERT INTO public.movimentacoes_caixa (caixa_id, tipo, descricao, valor, usuario_id)
        VALUES (test_caixa_id, 'entrada', 'Venda #001 - Produto teste', 50.00, test_user_id);
        
        -- Saída: Troco
        INSERT INTO public.movimentacoes_caixa (caixa_id, tipo, descricao, valor, usuario_id)
        VALUES (test_caixa_id, 'saida', 'Troco para cliente', 10.00, test_user_id);
        
        -- Entrada: Outra venda
        INSERT INTO public.movimentacoes_caixa (caixa_id, tipo, descricao, valor, usuario_id)
        VALUES (test_caixa_id, 'entrada', 'Venda #002 - Produto teste 2', 75.00, test_user_id);
    END IF;
END $$;

-- ===== PARTE 7: VERIFICAR SE TUDO FUNCIONOU =====

-- Verificar caixas
SELECT 'CAIXAS:' as tabela, COUNT(*) as total FROM public.caixa;
SELECT 
    id, 
    usuario_id, 
    valor_inicial, 
    valor_final, 
    status, 
    data_abertura::date as data,
    diferenca
FROM public.caixa 
ORDER BY data_abertura DESC 
LIMIT 3;

-- Verificar movimentações
SELECT 'MOVIMENTAÇÕES:' as tabela, COUNT(*) as total FROM public.movimentacoes_caixa;
SELECT 
    m.id,
    m.tipo,
    m.descricao,
    m.valor,
    m.data::date as data
FROM public.movimentacoes_caixa m
ORDER BY m.data DESC 
LIMIT 5;

-- Teste da função de saldo
SELECT 'TESTE SALDO:' as info;
SELECT 
    c.id as caixa_id,
    c.valor_inicial,
    calcular_saldo_caixa(c.id) as saldo_atual
FROM public.caixa c
WHERE c.status = 'aberto'
LIMIT 1;

-- Mostrar estrutura das tabelas
SELECT 'ESTRUTURA CAIXA:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'caixa' ORDER BY ordinal_position;

SELECT 'ESTRUTURA MOVIMENTAÇÕES:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'movimentacoes_caixa' ORDER BY ordinal_position;

-- Resultado final
SELECT '✅ MÓDULO CAIXA CRIADO COM SUCESSO!' as resultado;
