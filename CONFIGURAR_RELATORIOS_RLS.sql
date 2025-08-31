-- SISTEMA COMPLETO DE RELATÓRIOS E ANALYTICS COM RLS
-- Configurar tabelas para relatórios com isolamento por usuário

-- 1. Verificar se existe tabela de vendas (sales)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales') THEN
        CREATE TABLE sales (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            cliente_id UUID REFERENCES clientes(id) ON DELETE SET NULL,
            vendedor VARCHAR(100) DEFAULT 'Sistema',
            data_venda TIMESTAMP DEFAULT NOW(),
            subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
            desconto DECIMAL(10,2) DEFAULT 0,
            total DECIMAL(10,2) NOT NULL,
            forma_pagamento VARCHAR(50) DEFAULT 'Dinheiro',
            status VARCHAR(20) DEFAULT 'concluida',
            observacoes TEXT,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW()
        );
    END IF;
END $$;

-- 2. Criar tabela de itens de venda se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sale_items') THEN
        CREATE TABLE sale_items (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
            product_id UUID NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            produto_nome VARCHAR(255) NOT NULL,
            quantidade INTEGER NOT NULL DEFAULT 1,
            preco_unitario DECIMAL(10,2) NOT NULL,
            subtotal DECIMAL(10,2) NOT NULL,
            created_at TIMESTAMP DEFAULT NOW()
        );
    END IF;
END $$;

-- 3. Criar tabela de movimentações financeiras se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'financial_movements') THEN
        CREATE TABLE financial_movements (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida')),
            categoria VARCHAR(50) NOT NULL,
            descricao TEXT NOT NULL,
            valor DECIMAL(10,2) NOT NULL,
            data_movimento DATE NOT NULL DEFAULT CURRENT_DATE,
            referencia_id UUID, -- pode referenciar venda, compra, etc
            observacoes TEXT,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW()
        );
    END IF;
END $$;

-- 4. Habilitar RLS em todas as tabelas
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_movements ENABLE ROW LEVEL SECURITY;

-- 5. Criar políticas RLS para SALES
DROP POLICY IF EXISTS "sales_isolation_policy" ON sales;
CREATE POLICY "sales_isolation_policy" ON sales
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 6. Criar políticas RLS para SALE_ITEMS
DROP POLICY IF EXISTS "sale_items_isolation_policy" ON sale_items;
CREATE POLICY "sale_items_isolation_policy" ON sale_items
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 7. Criar políticas RLS para FINANCIAL_MOVEMENTS
DROP POLICY IF EXISTS "financial_movements_isolation_policy" ON financial_movements;
CREATE POLICY "financial_movements_isolation_policy" ON financial_movements
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 8. Inserir dados de exemplo para demonstração
INSERT INTO sales (user_id, cliente_id, vendedor, data_venda, subtotal, desconto, total, forma_pagamento, status) 
SELECT 
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID,
    c.id,
    'Atendente Sistema',
    NOW() - (random() * interval '30 days'),
    (random() * 500 + 50)::DECIMAL(10,2),
    (random() * 50)::DECIMAL(10,2),
    ((random() * 500 + 50) - (random() * 50))::DECIMAL(10,2),
    CASE (random() * 4)::INTEGER
        WHEN 0 THEN 'Dinheiro'
        WHEN 1 THEN 'Cartão Crédito'
        WHEN 2 THEN 'Cartão Débito'
        ELSE 'PIX'
    END,
    'concluida'
FROM clientes c 
WHERE c.user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID
LIMIT 20
ON CONFLICT DO NOTHING;

-- 9. Inserir itens de venda de exemplo
WITH sales_sample AS (
    SELECT id as sale_id, user_id, total
    FROM sales 
    WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID
    LIMIT 10
),
produtos_sample AS (
    SELECT id as product_id, nome, preco
    FROM produtos 
    WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID
    LIMIT 50
)
INSERT INTO sale_items (sale_id, product_id, user_id, produto_nome, quantidade, preco_unitario, subtotal)
SELECT 
    s.sale_id,
    p.product_id,
    s.user_id,
    p.nome,
    (random() * 3 + 1)::INTEGER,
    p.preco,
    (p.preco * (random() * 3 + 1)::INTEGER)::DECIMAL(10,2)
FROM sales_sample s
CROSS JOIN LATERAL (
    SELECT * FROM produtos_sample ORDER BY random() LIMIT 2
) p
ON CONFLICT DO NOTHING;

-- 10. Inserir movimentações financeiras de exemplo
INSERT INTO financial_movements (user_id, tipo, categoria, descricao, valor, data_movimento) 
SELECT 
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID,
    CASE (random())::INTEGER WHEN 0 THEN 'entrada' ELSE 'saida' END,
    CASE (random() * 5)::INTEGER
        WHEN 0 THEN 'Vendas'
        WHEN 1 THEN 'Fornecedores'
        WHEN 2 THEN 'Despesas'
        WHEN 3 THEN 'Impostos'
        ELSE 'Outros'
    END,
    CASE (random() * 3)::INTEGER
        WHEN 0 THEN 'Venda de produtos'
        WHEN 1 THEN 'Compra de mercadoria'
        ELSE 'Despesa operacional'
    END,
    (random() * 1000 + 10)::DECIMAL(10,2),
    (NOW() - (random() * interval '60 days'))::DATE
FROM generate_series(1, 50)
ON CONFLICT DO NOTHING;

-- 11. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_sales_user_id_date ON sales(user_id, data_venda);
CREATE INDEX IF NOT EXISTS idx_sales_cliente_id ON sales(cliente_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_user_id ON sale_items(user_id);
CREATE INDEX IF NOT EXISTS idx_financial_movements_user_id_date ON financial_movements(user_id, data_movimento);

-- 12. Verificação final
SELECT 
    'RELATÓRIOS CONFIGURADOS!' as status,
    (SELECT COUNT(*) FROM sales WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID) as vendas_exemplo,
    (SELECT COUNT(*) FROM sale_items WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID) as itens_exemplo,
    (SELECT COUNT(*) FROM financial_movements WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID) as movimentacoes_exemplo;
