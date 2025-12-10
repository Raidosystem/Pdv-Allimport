-- INSERIR COM BYPASS COMPLETO
-- User ID: 28e56a69-90df-4852-b663-9b02f4358c6f

-- MÉTODO 1: Tentar com SET session_replication_role
SET session_replication_role = replica;

-- Inserir categorias
INSERT INTO public.categorias (id, user_id, nome) VALUES
('92a8c722-5727-4657-b834-0a6a07e3b1b1', '28e56a69-90df-4852-b663-9b02f4358c6f', 'CARTÃO DE MEMORIA'),
('048f8fbb-e6fb-48df-9b29-f67369e5e05a', '28e56a69-90df-4852-b663-9b02f4358c6f', 'PENDRIVE'),
('e16154ff-216b-4d50-93e8-a31f6ee73449', '28e56a69-90df-4852-b663-9b02f4358c6f', 'FONE SEM FIO'),
('d6260a2a-54e0-4ae6-8e9f-1cede84dd9da', '28e56a69-90df-4852-b663-9b02f4358c6f', 'EMBALAGEM MERCADO LIVRE'),
('7d07a402-3193-4e31-a780-02451dabbad2', '28e56a69-90df-4852-b663-9b02f4358c6f', 'SUPORTE PARA CELULAR')
ON CONFLICT (id) DO NOTHING;

-- Inserir produtos
INSERT INTO public.produtos (id, user_id, nome, preco) VALUES
('a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0', '28e56a69-90df-4852-b663-9b02f4358c6f', 'WIRELESS MICROPHONE', 160.00),
('17fd37b4-b9f0-484c-aeb1-6702b8b80b5f', '28e56a69-90df-4852-b663-9b02f4358c6f', 'MINI MICROFONE DE LAPELA', 24.99),
('1b843d2d-263a-4333-8bba-c2466a1bad27', '28e56a69-90df-4852-b663-9b02f4358c6f', 'CARTÃO DE MEMORIA A GOLD 64GB', 75.00),
('a2239653-68de-4ca3-aeea-7327ff7a2606', '28e56a69-90df-4852-b663-9b02f4358c6f', 'CARTÃO DE MEMORIA KAPBOM 16GB', 55.00),
('74b3c9b8-bd69-4356-8c92-ec21b1a3fd76', '28e56a69-90df-4852-b663-9b02f4358c6f', 'CARTÃO DE MEMORIA MULTILASER 8GB', 40.00)
ON CONFLICT (id) DO NOTHING;

-- Restaurar modo normal
SET session_replication_role = DEFAULT;

-- Verificar resultado
SELECT 'TESTE COM REPLICA MODE' as status;
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';
SELECT nome, preco FROM public.produtos WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f' ORDER BY nome;

-- MÉTODO 2 (ALTERNATIVO): Usar uma função se o método 1 falhar
/*
CREATE OR REPLACE FUNCTION inserir_produto_direto(
    p_id uuid,
    p_user_id uuid,
    p_nome text,
    p_preco numeric
) RETURNS void AS $$
BEGIN
    INSERT INTO produtos (id, user_id, nome, preco) 
    VALUES (p_id, p_user_id, p_nome, p_preco)
    ON CONFLICT (id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Usar a função
SELECT inserir_produto_direto(
    'a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0'::uuid,
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid,
    'WIRELESS MICROPHONE',
    160.00
);
*/
