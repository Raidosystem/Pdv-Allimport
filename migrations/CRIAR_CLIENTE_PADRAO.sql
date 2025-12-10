-- ============================================
-- CRIAR CLIENTE PADRÃO "CLIENTE DA VENDA"
-- ============================================
-- Este script verifica se cada empresa tem um "Cliente da Venda".
-- Se não tiver, cria automaticamente.
-- ============================================

DO $$
DECLARE
    emp RECORD;
BEGIN
    -- Percorrer todas as empresas cadastradas
    FOR emp IN SELECT id, user_id FROM empresas
    LOOP
        -- Verificar se já existe um cliente padrão (Cliente da Venda ou Consumidor Final)
        IF NOT EXISTS (
            SELECT 1 FROM clientes 
            WHERE empresa_id = emp.id 
            AND (nome ILIKE 'Cliente da Venda' OR nome ILIKE 'Consumidor Final')
        ) THEN
            -- Criar o Cliente da Venda
            INSERT INTO clientes (
                id,
                empresa_id,
                user_id,
                nome,
                email,
                telefone,
                cpf_cnpj,
                tipo,
                cep,
                endereco,
                numero,
                bairro,
                cidade,
                estado
            ) VALUES (
                gen_random_uuid(),
                emp.id,
                emp.user_id,
                'Cliente da Venda',
                'padrao@venda.com',
                '00000000000',
                '00000000000',
                'fisica',
                '00000000',
                'Venda Balcão',
                'S/N',
                'Centro',
                'Geral',
                'BR'
            );
            RAISE NOTICE '✅ "Cliente da Venda" criado para a empresa %', emp.id;
        ELSE
            RAISE NOTICE 'ℹ️ A empresa % já possui um cliente padrão.', emp.id;
        END IF;
    END LOOP;
END $$;

-- Verificar o resultado
SELECT 
    c.nome, 
    e.nome as empresa,
    c.empresa_id
FROM clientes c
JOIN empresas e ON e.id = c.empresa_id
WHERE c.nome ILIKE 'Cliente da Venda' OR c.nome ILIKE 'Consumidor Final';
