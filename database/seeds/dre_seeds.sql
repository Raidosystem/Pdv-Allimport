-- ============================================
-- SEEDS - DADOS DE EXEMPLO PARA TESTE
-- Sistema DRE Completo
-- ============================================

-- IMPORTANTE: Substitua os UUIDs pelos valores reais do seu sistema
-- Execute: SELECT id FROM auth.users LIMIT 1; para pegar seu user_id
-- Execute: SELECT id FROM public.empresas WHERE user_id = 'seu-user-id' LIMIT 1; para pegar empresa_id

-- Variáveis de exemplo (AJUSTE CONFORME SEU SISTEMA)
DO $$
DECLARE
    v_user_id UUID := 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'; -- SUBSTITUA pelo seu user_id
    v_empresa_id UUID; -- Será buscado automaticamente
    v_produto1_id UUID;
    v_produto2_id UUID;
    v_produto3_id UUID;
    v_compra1_id UUID;
    v_venda1_id UUID;
BEGIN
    -- Buscar empresa do usuário
    SELECT id INTO v_empresa_id FROM public.empresas WHERE user_id = v_user_id LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Empresa não encontrada para o usuário especificado';
    END IF;

    RAISE NOTICE 'Usando empresa_id: %', v_empresa_id;

    -- ============================================
    -- 1. CRIAR PRODUTOS DE EXEMPLO
    -- ============================================
    
    -- Produto 1: Mouse Gamer
    INSERT INTO public.produtos (
        id, empresa_id, user_id, nome, codigo_barras, preco, 
        custo_medio, quantidade_estoque, controla_estoque, categoria, ativo
    ) VALUES (
        gen_random_uuid(), v_empresa_id, v_user_id,
        'Mouse Gamer RGB', '7891234567890', 89.90,
        0, 0, true, 'Informática', true
    ) RETURNING id INTO v_produto1_id;

    -- Produto 2: Teclado Mecânico
    INSERT INTO public.produtos (
        id, empresa_id, user_id, nome, codigo_barras, preco,
        custo_medio, quantidade_estoque, controla_estoque, categoria, ativo
    ) VALUES (
        gen_random_uuid(), v_empresa_id, v_user_id,
        'Teclado Mecânico RGB', '7891234567891', 259.90,
        0, 0, true, 'Informática', true
    ) RETURNING id INTO v_produto2_id;

    -- Produto 3: Headset Gamer
    INSERT INTO public.produtos (
        id, empresa_id, user_id, nome, codigo_barras, preco,
        custo_medio, quantidade_estoque, controla_estoque, categoria, ativo
    ) VALUES (
        gen_random_uuid(), v_empresa_id, v_user_id,
        'Headset Gamer 7.1', '7891234567892', 149.90,
        0, 0, true, 'Informática', true
    ) RETURNING id INTO v_produto3_id;

    RAISE NOTICE 'Produtos criados com sucesso';

    -- ============================================
    -- 2. CRIAR COMPRA DE EXEMPLO
    -- ============================================
    
    INSERT INTO public.compras (
        id, empresa_id, user_id, numero_nota, fornecedor_nome, fornecedor_cnpj,
        data_compra, valor_total, status, observacoes
    ) VALUES (
        gen_random_uuid(), v_empresa_id, v_user_id,
        'NF-12345', 'Fornecedor Tech LTDA', '12.345.678/0001-90',
        NOW() - INTERVAL '10 days', 5000.00, 'pendente',
        'Primeira compra de estoque'
    ) RETURNING id INTO v_compra1_id;

    -- Itens da compra
    INSERT INTO public.itens_compra (compra_id, produto_id, empresa_id, user_id, quantidade, custo_unitario)
    VALUES
        (v_compra1_id, v_produto1_id, v_empresa_id, v_user_id, 50, 45.00),  -- Mouse: 50 unid x R$45
        (v_compra1_id, v_produto2_id, v_empresa_id, v_user_id, 30, 120.00), -- Teclado: 30 unid x R$120
        (v_compra1_id, v_produto3_id, v_empresa_id, v_user_id, 20, 70.00);  -- Headset: 20 unid x R$70

    -- Aplicar compra (atualiza estoque e custo médio)
    PERFORM fn_aplicar_compra(v_compra1_id);
    
    RAISE NOTICE 'Compra criada e aplicada: %', v_compra1_id;

    -- ============================================
    -- 3. CRIAR VENDAS DE EXEMPLO
    -- ============================================
    
    -- Venda 1
    INSERT INTO public.vendas (
        id, empresa_id, user_id, cliente_id, sale_date, payment_method,
        total_amount, discount_amount, final_amount, status
    ) VALUES (
        gen_random_uuid(), v_empresa_id, v_user_id, NULL,
        NOW() - INTERVAL '5 days', 'dinheiro',
        449.50, 0, 449.50, 'completed'
    ) RETURNING id INTO v_venda1_id;

    -- Itens da venda
    INSERT INTO public.vendas_itens (venda_id, produto_id, empresa_id, user_id, quantidade, preco_unitario)
    VALUES
        (v_venda1_id, v_produto1_id, v_empresa_id, v_user_id, 3, 89.90),   -- 3 Mouse
        (v_venda1_id, v_produto3_id, v_empresa_id, v_user_id, 1, 149.90);  -- 1 Headset

    -- Aplicar venda (baixa estoque)
    PERFORM fn_aplicar_venda(v_venda1_id);

    RAISE NOTICE 'Venda criada e aplicada: %', v_venda1_id;

    -- ============================================
    -- 4. CRIAR DESPESAS OPERACIONAIS DE EXEMPLO
    -- ============================================
    
    INSERT INTO public.despesas (
        empresa_id, user_id, descricao, categoria, valor, data_despesa, status
    ) VALUES
        (v_empresa_id, v_user_id, 'Aluguel da Loja - Novembro', 'aluguel', 2500.00, CURRENT_DATE - 15, 'pago'),
        (v_empresa_id, v_user_id, 'Conta de Energia Elétrica', 'energia', 350.00, CURRENT_DATE - 10, 'pago'),
        (v_empresa_id, v_user_id, 'Internet e Telefone', 'telefone', 150.00, CURRENT_DATE - 8, 'pago'),
        (v_empresa_id, v_user_id, 'Material de Limpeza', 'material', 80.00, CURRENT_DATE - 5, 'pago'),
        (v_empresa_id, v_user_id, 'Marketing - Redes Sociais', 'marketing', 300.00, CURRENT_DATE - 3, 'pago');

    RAISE NOTICE 'Despesas operacionais criadas';

    -- ============================================
    -- 5. CRIAR OUTRAS RECEITAS/DESPESAS
    -- ============================================
    
    INSERT INTO public.outras_movimentacoes_financeiras (
        empresa_id, user_id, tipo, descricao, categoria, valor, data_movimentacao
    ) VALUES
        (v_empresa_id, v_user_id, 'receita', 'Juros de aplicação financeira', 'juros_recebidos', 50.00, CURRENT_DATE - 2),
        (v_empresa_id, v_user_id, 'despesa', 'Juros pagos - empréstimo', 'juros_pagos', 120.00, CURRENT_DATE - 1);

    RAISE NOTICE 'Outras movimentações financeiras criadas';

    -- ============================================
    -- 6. TESTAR CÁLCULO DO DRE
    -- ============================================
    
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE 'TESTE DO DRE - ÚLTIMO MÊS';
    RAISE NOTICE '═══════════════════════════════════════';
    
    -- Calcular DRE para os últimos 30 dias
    PERFORM * FROM fn_calcular_dre(
        CURRENT_DATE - INTERVAL '30 days',
        CURRENT_DATE,
        v_empresa_id
    );

    RAISE NOTICE 'Seeds instalados com sucesso! ✅';
    RAISE NOTICE '';
    RAISE NOTICE 'Para ver o DRE, execute:';
    RAISE NOTICE 'SELECT * FROM fn_calcular_dre(CURRENT_DATE - INTERVAL ''30 days'', CURRENT_DATE, ''%'');', v_empresa_id;
    
END $$;

-- ============================================
-- VERIFICAÇÕES PÓS-SEED
-- ============================================

-- Ver produtos com estoque
SELECT 
    '📦 PRODUTOS COM ESTOQUE' as secao,
    nome,
    quantidade_estoque as estoque,
    custo_medio,
    preco,
    (preco - custo_medio) as margem,
    ROUND(((preco - custo_medio) / preco * 100), 2) as margem_percentual
FROM public.produtos
WHERE quantidade_estoque > 0
ORDER BY nome;

-- Ver movimentações de estoque
SELECT 
    '📋 MOVIMENTAÇÕES DE ESTOQUE' as secao,
    p.nome as produto,
    me.tipo_movimentacao,
    me.quantidade,
    me.custo_unitario,
    me.estoque_anterior,
    me.estoque_novo,
    me.custo_medio_anterior,
    me.custo_medio_novo,
    me.data_movimentacao
FROM public.movimentacoes_estoque me
JOIN public.produtos p ON p.id = me.produto_id
ORDER BY me.data_movimentacao DESC
LIMIT 10;

-- Ver despesas
SELECT 
    '💰 DESPESAS OPERACIONAIS' as secao,
    categoria,
    COUNT(*) as quantidade,
    SUM(valor) as total
FROM public.despesas
WHERE status = 'pago'
GROUP BY categoria
ORDER BY total DESC;

SELECT '✅ Instalação de seeds concluída!' as resultado;
