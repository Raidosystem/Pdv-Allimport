-- ============================================
-- SISTEMA DRE COMPLETO - MIGRAÇÃO
-- Demonstração do Resultado do Exercício
-- Custo Médio Móvel + Multi-tenant + RLS
-- ============================================

-- 1. ADICIONAR CAMPOS DE CUSTO E ESTOQUE EM PRODUTOS
ALTER TABLE public.produtos 
ADD COLUMN IF NOT EXISTS custo_medio DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS quantidade_estoque INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS estoque_minimo INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS controla_estoque BOOLEAN DEFAULT true;

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_produtos_empresa_id ON public.produtos(empresa_id);
CREATE INDEX IF NOT EXISTS idx_produtos_user_id ON public.produtos(user_id);

-- 2. TABELA DE COMPRAS (PURCHASES)
CREATE TABLE IF NOT EXISTS public.compras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    numero_nota TEXT,
    fornecedor_nome TEXT NOT NULL,
    fornecedor_cnpj TEXT,
    data_compra TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    observacoes TEXT,
    status TEXT CHECK (status IN ('pendente', 'finalizada', 'cancelada')) DEFAULT 'finalizada',
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_compras_empresa_id ON public.compras(empresa_id);
CREATE INDEX IF NOT EXISTS idx_compras_user_id ON public.compras(user_id);
CREATE INDEX IF NOT EXISTS idx_compras_data ON public.compras(data_compra);

-- 3. TABELA DE ITENS DE COMPRA
CREATE TABLE IF NOT EXISTS public.itens_compra (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    compra_id UUID REFERENCES public.compras(id) ON DELETE CASCADE NOT NULL,
    produto_id UUID REFERENCES public.produtos(id) ON DELETE RESTRICT NOT NULL,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    custo_unitario DECIMAL(10, 2) NOT NULL CHECK (custo_unitario >= 0),
    custo_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantidade * custo_unitario) STORED,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_itens_compra_compra_id ON public.itens_compra(compra_id);
CREATE INDEX IF NOT EXISTS idx_itens_compra_produto_id ON public.itens_compra(produto_id);
CREATE INDEX IF NOT EXISTS idx_itens_compra_empresa_id ON public.itens_compra(empresa_id);

-- 4. TABELA DE LIVRO DE ESTOQUE (STOCK LEDGER)
CREATE TABLE IF NOT EXISTS public.movimentacoes_estoque (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    produto_id UUID REFERENCES public.produtos(id) ON DELETE RESTRICT NOT NULL,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tipo_movimentacao TEXT CHECK (tipo_movimentacao IN ('entrada', 'saida', 'ajuste', 'inventario')) NOT NULL,
    quantidade INTEGER NOT NULL,
    custo_unitario DECIMAL(10, 2) NOT NULL,
    custo_medio_anterior DECIMAL(10, 2),
    custo_medio_novo DECIMAL(10, 2),
    estoque_anterior INTEGER,
    estoque_novo INTEGER,
    referencia_tipo TEXT CHECK (referencia_tipo IN ('compra', 'venda', 'ajuste', 'inventario')),
    referencia_id UUID,
    observacao TEXT,
    data_movimentacao TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_movimentacoes_estoque_produto_id ON public.movimentacoes_estoque(produto_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_estoque_empresa_id ON public.movimentacoes_estoque(empresa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_estoque_data ON public.movimentacoes_estoque(data_movimentacao);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_estoque_tipo ON public.movimentacoes_estoque(tipo_movimentacao);

-- 5. TABELA DE DESPESAS OPERACIONAIS
CREATE TABLE IF NOT EXISTS public.despesas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    descricao TEXT NOT NULL,
    categoria TEXT NOT NULL, -- 'aluguel', 'salarios', 'energia', 'agua', 'telefone', 'material', 'manutencao', 'marketing', 'outras'
    valor DECIMAL(10, 2) NOT NULL CHECK (valor >= 0),
    data_despesa DATE NOT NULL,
    data_vencimento DATE,
    data_pagamento DATE,
    status TEXT CHECK (status IN ('pendente', 'pago', 'cancelado')) DEFAULT 'pendente',
    forma_pagamento TEXT,
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_despesas_empresa_id ON public.despesas(empresa_id);
CREATE INDEX IF NOT EXISTS idx_despesas_user_id ON public.despesas(user_id);
CREATE INDEX IF NOT EXISTS idx_despesas_data ON public.despesas(data_despesa);
CREATE INDEX IF NOT EXISTS idx_despesas_categoria ON public.despesas(categoria);

-- 6. TABELA DE OUTRAS RECEITAS E DESPESAS (NÃO OPERACIONAIS)
CREATE TABLE IF NOT EXISTS public.outras_movimentacoes_financeiras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT CHECK (tipo IN ('receita', 'despesa')) NOT NULL,
    descricao TEXT NOT NULL,
    categoria TEXT NOT NULL, -- 'juros_recebidos', 'juros_pagos', 'desconto_obtido', 'desconto_concedido', 'multa', 'outras'
    valor DECIMAL(10, 2) NOT NULL CHECK (valor >= 0),
    data_movimentacao DATE NOT NULL,
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_outras_movimentacoes_empresa_id ON public.outras_movimentacoes_financeiras(empresa_id);
CREATE INDEX IF NOT EXISTS idx_outras_movimentacoes_user_id ON public.outras_movimentacoes_financeiras(user_id);
CREATE INDEX IF NOT EXISTS idx_outras_movimentacoes_data ON public.outras_movimentacoes_financeiras(data_movimentacao);

-- ============================================
-- HABILITAR RLS EM TODAS AS TABELAS
-- ============================================

ALTER TABLE public.compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_compra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_estoque ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.despesas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outras_movimentacoes_financeiras ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS RLS - ISOLAMENTO POR EMPRESA E USUÁRIO
-- ============================================

-- COMPRAS
DROP POLICY IF EXISTS "Usuários veem compras da sua empresa" ON public.compras;
CREATE POLICY "Usuários veem compras da sua empresa" ON public.compras
    FOR ALL USING (
        empresa_id IN (
            SELECT e.id FROM public.empresas e 
            WHERE e.id = compras.empresa_id
        )
        AND user_id = auth.uid()
    );

-- ITENS DE COMPRA
DROP POLICY IF EXISTS "Usuários veem itens de compra da sua empresa" ON public.itens_compra;
CREATE POLICY "Usuários veem itens de compra da sua empresa" ON public.itens_compra
    FOR ALL USING (
        empresa_id IN (
            SELECT e.id FROM public.empresas e 
            WHERE e.id = itens_compra.empresa_id
        )
        AND user_id = auth.uid()
    );

-- MOVIMENTAÇÕES DE ESTOQUE
DROP POLICY IF EXISTS "Usuários veem movimentações da sua empresa" ON public.movimentacoes_estoque;
CREATE POLICY "Usuários veem movimentações da sua empresa" ON public.movimentacoes_estoque
    FOR ALL USING (
        empresa_id IN (
            SELECT e.id FROM public.empresas e 
            WHERE e.id = movimentacoes_estoque.empresa_id
        )
        AND user_id = auth.uid()
    );

-- DESPESAS
DROP POLICY IF EXISTS "Usuários veem despesas da sua empresa" ON public.despesas;
CREATE POLICY "Usuários veem despesas da sua empresa" ON public.despesas
    FOR ALL USING (
        empresa_id IN (
            SELECT e.id FROM public.empresas e 
            WHERE e.id = despesas.empresa_id
        )
        AND user_id = auth.uid()
    );

-- OUTRAS MOVIMENTAÇÕES FINANCEIRAS
DROP POLICY IF EXISTS "Usuários veem outras movimentações da sua empresa" ON public.outras_movimentacoes_financeiras;
CREATE POLICY "Usuários veem outras movimentações da sua empresa" ON public.outras_movimentacoes_financeiras
    FOR ALL USING (
        empresa_id IN (
            SELECT e.id FROM public.empresas e 
            WHERE e.id = outras_movimentacoes_financeiras.empresa_id
        )
        AND user_id = auth.uid()
    );

-- ============================================
-- FUNÇÃO: RECALCULAR CUSTO MÉDIO MÓVEL
-- ============================================

CREATE OR REPLACE FUNCTION fn_recalc_custo_medio(
    p_produto_id UUID,
    p_quantidade INTEGER,
    p_custo_unitario DECIMAL(10, 2),
    p_tipo_movimentacao TEXT
)
RETURNS TABLE(
    custo_medio_novo DECIMAL(10, 2),
    estoque_novo INTEGER
) AS $$
DECLARE
    v_custo_medio_atual DECIMAL(10, 2);
    v_estoque_atual INTEGER;
    v_custo_medio_calculado DECIMAL(10, 2);
    v_estoque_calculado INTEGER;
BEGIN
    -- Buscar valores atuais do produto
    SELECT custo_medio, quantidade_estoque
    INTO v_custo_medio_atual, v_estoque_atual
    FROM public.produtos
    WHERE id = p_produto_id;

    -- Calcular novo custo médio e estoque
    IF p_tipo_movimentacao = 'entrada' THEN
        -- Fórmula: Custo Médio = (Estoque_Atual * Custo_Atual + Qtd_Entrada * Custo_Entrada) / (Estoque_Atual + Qtd_Entrada)
        IF (v_estoque_atual + p_quantidade) > 0 THEN
            v_custo_medio_calculado := 
                ((v_estoque_atual * v_custo_medio_atual) + (p_quantidade * p_custo_unitario)) 
                / (v_estoque_atual + p_quantidade);
        ELSE
            v_custo_medio_calculado := p_custo_unitario;
        END IF;
        v_estoque_calculado := v_estoque_atual + p_quantidade;
        
    ELSIF p_tipo_movimentacao = 'saida' THEN
        -- Saída: mantém custo médio, reduz estoque
        v_custo_medio_calculado := v_custo_medio_atual;
        v_estoque_calculado := v_estoque_atual - p_quantidade;
        
        -- Validar estoque negativo
        IF v_estoque_calculado < 0 THEN
            RAISE EXCEPTION 'Estoque insuficiente para o produto %', p_produto_id;
        END IF;
        
    ELSIF p_tipo_movimentacao IN ('ajuste', 'inventario') THEN
        -- Ajuste manual: pode definir novo custo médio
        v_custo_medio_calculado := p_custo_unitario;
        v_estoque_calculado := p_quantidade;
        
    ELSE
        RAISE EXCEPTION 'Tipo de movimentação inválido: %', p_tipo_movimentacao;
    END IF;

    -- Retornar resultados
    RETURN QUERY SELECT v_custo_medio_calculado, v_estoque_calculado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÃO: PROCESSAR COMPRA
-- ============================================

CREATE OR REPLACE FUNCTION fn_aplicar_compra(p_compra_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_item RECORD;
    v_custo_medio_novo DECIMAL(10, 2);
    v_estoque_novo INTEGER;
    v_empresa_id UUID;
    v_user_id UUID;
BEGIN
    -- Buscar empresa_id e user_id da compra
    SELECT empresa_id, user_id
    INTO v_empresa_id, v_user_id
    FROM public.compras
    WHERE id = p_compra_id;

    -- Processar cada item da compra
    FOR v_item IN 
        SELECT * FROM public.itens_compra WHERE compra_id = p_compra_id
    LOOP
        -- Recalcular custo médio
        SELECT * INTO v_custo_medio_novo, v_estoque_novo
        FROM fn_recalc_custo_medio(
            v_item.produto_id,
            v_item.quantidade,
            v_item.custo_unitario,
            'entrada'
        );

        -- Atualizar produto
        UPDATE public.produtos
        SET 
            custo_medio = v_custo_medio_novo,
            quantidade_estoque = v_estoque_novo,
            atualizado_em = NOW()
        WHERE id = v_item.produto_id;

        -- Registrar movimentação no livro de estoque
        INSERT INTO public.movimentacoes_estoque (
            produto_id,
            empresa_id,
            user_id,
            tipo_movimentacao,
            quantidade,
            custo_unitario,
            custo_medio_anterior,
            custo_medio_novo,
            estoque_anterior,
            estoque_novo,
            referencia_tipo,
            referencia_id,
            observacao
        )
        SELECT
            v_item.produto_id,
            v_empresa_id,
            v_user_id,
            'entrada',
            v_item.quantidade,
            v_item.custo_unitario,
            p.custo_medio AS custo_medio_anterior,
            v_custo_medio_novo,
            p.quantidade_estoque - v_item.quantidade AS estoque_anterior,
            v_estoque_novo,
            'compra',
            p_compra_id,
            'Entrada por compra'
        FROM public.produtos p
        WHERE p.id = v_item.produto_id;
    END LOOP;

    -- Marcar compra como finalizada
    UPDATE public.compras
    SET 
        status = 'finalizada',
        atualizado_em = NOW()
    WHERE id = p_compra_id;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao aplicar compra: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNÇÃO: PROCESSAR VENDA (BAIXA DE ESTOQUE)
-- ============================================

CREATE OR REPLACE FUNCTION fn_aplicar_venda(p_venda_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_item RECORD;
    v_custo_medio_novo DECIMAL(10, 2);
    v_estoque_novo INTEGER;
    v_empresa_id UUID;
    v_user_id UUID;
BEGIN
    -- Buscar empresa_id e user_id da venda
    SELECT empresa_id, user_id
    INTO v_empresa_id, v_user_id
    FROM public.vendas
    WHERE id = p_venda_id;

    -- Processar cada item da venda
    FOR v_item IN 
        SELECT * FROM public.vendas_itens WHERE venda_id = p_venda_id
    LOOP
        -- Buscar produto para pegar custo médio atual
        SELECT custo_medio INTO v_custo_medio_novo
        FROM public.produtos
        WHERE id = v_item.produto_id;

        -- Recalcular estoque (saída)
        SELECT * INTO v_custo_medio_novo, v_estoque_novo
        FROM fn_recalc_custo_medio(
            v_item.produto_id,
            v_item.quantidade,
            v_custo_medio_novo,
            'saida'
        );

        -- Atualizar produto
        UPDATE public.produtos
        SET 
            quantidade_estoque = v_estoque_novo,
            atualizado_em = NOW()
        WHERE id = v_item.produto_id;

        -- Registrar movimentação no livro de estoque
        INSERT INTO public.movimentacoes_estoque (
            produto_id,
            empresa_id,
            user_id,
            tipo_movimentacao,
            quantidade,
            custo_unitario,
            custo_medio_anterior,
            custo_medio_novo,
            estoque_anterior,
            estoque_novo,
            referencia_tipo,
            referencia_id,
            observacao
        )
        SELECT
            v_item.produto_id,
            v_empresa_id,
            v_user_id,
            'saida',
            v_item.quantidade,
            v_custo_medio_novo,
            p.custo_medio,
            v_custo_medio_novo,
            p.quantidade_estoque + v_item.quantidade AS estoque_anterior,
            v_estoque_novo,
            'venda',
            p_venda_id,
            'Saída por venda'
        FROM public.produtos p
        WHERE p.id = v_item.produto_id;
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao aplicar venda: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VIEW/FUNÇÃO: CÁLCULO DO DRE
-- ============================================

CREATE OR REPLACE FUNCTION fn_calcular_dre(
    p_data_inicio DATE,
    p_data_fim DATE,
    p_empresa_id UUID
)
RETURNS TABLE(
    receita_bruta DECIMAL(10, 2),
    deducoes DECIMAL(10, 2),
    receita_liquida DECIMAL(10, 2),
    cmv DECIMAL(10, 2),
    lucro_bruto DECIMAL(10, 2),
    despesas_operacionais DECIMAL(10, 2),
    resultado_operacional DECIMAL(10, 2),
    outras_receitas DECIMAL(10, 2),
    outras_despesas DECIMAL(10, 2),
    resultado_liquido DECIMAL(10, 2)
) AS $$
DECLARE
    v_receita_bruta DECIMAL(10, 2) := 0;
    v_deducoes DECIMAL(10, 2) := 0;
    v_cmv DECIMAL(10, 2) := 0;
    v_despesas_op DECIMAL(10, 2) := 0;
    v_outras_receitas DECIMAL(10, 2) := 0;
    v_outras_despesas DECIMAL(10, 2) := 0;
BEGIN
    -- 1. RECEITA BRUTA (vendas no período)
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_receita_bruta
    FROM public.vendas
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND DATE(sale_date) BETWEEN p_data_inicio AND p_data_fim
      AND status != 'cancelada';

    -- 2. DEDUÇÕES (descontos concedidos)
    SELECT COALESCE(SUM(discount_amount), 0)
    INTO v_deducoes
    FROM public.vendas
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND DATE(sale_date) BETWEEN p_data_inicio AND p_data_fim
      AND status != 'cancelada';

    -- 3. CMV (Custo da Mercadoria Vendida)
    -- Soma das saídas de estoque multiplicadas pelo custo médio
    SELECT COALESCE(SUM(quantidade * custo_unitario), 0)
    INTO v_cmv
    FROM public.movimentacoes_estoque
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND DATE(data_movimentacao) BETWEEN p_data_inicio AND p_data_fim
      AND tipo_movimentacao = 'saida'
      AND referencia_tipo = 'venda';

    -- 4. DESPESAS OPERACIONAIS
    SELECT COALESCE(SUM(valor), 0)
    INTO v_despesas_op
    FROM public.despesas
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND data_despesa BETWEEN p_data_inicio AND p_data_fim
      AND status = 'pago';

    -- 5. OUTRAS RECEITAS (não operacionais)
    SELECT COALESCE(SUM(valor), 0)
    INTO v_outras_receitas
    FROM public.outras_movimentacoes_financeiras
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND data_movimentacao BETWEEN p_data_inicio AND p_data_fim
      AND tipo = 'receita';

    -- 6. OUTRAS DESPESAS (não operacionais)
    SELECT COALESCE(SUM(valor), 0)
    INTO v_outras_despesas
    FROM public.outras_movimentacoes_financeiras
    WHERE empresa_id = p_empresa_id
      AND user_id = auth.uid()
      AND data_movimentacao BETWEEN p_data_inicio AND p_data_fim
      AND tipo = 'despesa';

    -- Retornar DRE calculado
    RETURN QUERY SELECT
        v_receita_bruta,
        v_deducoes,
        v_receita_bruta - v_deducoes AS receita_liquida_calc,
        v_cmv,
        (v_receita_bruta - v_deducoes - v_cmv) AS lucro_bruto_calc,
        v_despesas_op,
        (v_receita_bruta - v_deducoes - v_cmv - v_despesas_op) AS resultado_operacional_calc,
        v_outras_receitas,
        v_outras_despesas,
        (v_receita_bruta - v_deducoes - v_cmv - v_despesas_op + v_outras_receitas - v_outras_despesas) AS resultado_liquido_calc;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- GRANTS - PERMISSÕES
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON public.compras TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.itens_compra TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.movimentacoes_estoque TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.despesas TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.outras_movimentacoes_financeiras TO authenticated;

GRANT EXECUTE ON FUNCTION fn_recalc_custo_medio TO authenticated;
GRANT EXECUTE ON FUNCTION fn_aplicar_compra TO authenticated;
GRANT EXECUTE ON FUNCTION fn_aplicar_venda TO authenticated;
GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;

-- ============================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- ============================================

COMMENT ON TABLE public.compras IS 'Registro de compras de mercadorias/produtos';
COMMENT ON TABLE public.itens_compra IS 'Itens individuais de cada compra';
COMMENT ON TABLE public.movimentacoes_estoque IS 'Livro de estoque com todas as movimentações e custo médio';
COMMENT ON TABLE public.despesas IS 'Despesas operacionais da empresa';
COMMENT ON TABLE public.outras_movimentacoes_financeiras IS 'Receitas e despesas não operacionais';

COMMENT ON FUNCTION fn_recalc_custo_medio IS 'Recalcula custo médio móvel de um produto';
COMMENT ON FUNCTION fn_aplicar_compra IS 'Processa compra: atualiza estoque e custo médio';
COMMENT ON FUNCTION fn_aplicar_venda IS 'Processa venda: baixa estoque e registra CMV';
COMMENT ON FUNCTION fn_calcular_dre IS 'Calcula DRE (Demonstração do Resultado do Exercício) para um período';

-- ============================================
-- FIM DA MIGRAÇÃO
-- ============================================

SELECT '✅ Sistema DRE criado com sucesso!' AS resultado;
