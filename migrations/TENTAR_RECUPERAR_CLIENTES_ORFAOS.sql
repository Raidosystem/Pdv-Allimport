-- ============================================
-- TENTATIVA DE RECUPERAÇÃO: Vincular Ordens Órfãs
-- ============================================

-- 1. Verificar se as ordens órfãs têm informações de contato que possam linkar com clientes atuais
-- (Verificando se há campos como telefone_contato, cpf_cliente, etc na tabela ordens_servico)
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;

-- 2. Ver todos os dados da primeira ordem órfã para analisar campos disponíveis
SELECT *
FROM ordens_servico
WHERE id = 'a01954f8-235d-4a3e-aa14-a1b7ce0e697f';

-- 3. Buscar se existe algum cliente com nome/telefone similar nas ordens órfãs
-- (Primeiro vamos ver se há campo 'nome_cliente' ou similar em ordens_servico)
SELECT 
    os.numero_os,
    os.cliente_id as id_orfao,
    os.marca,
    os.modelo,
    os.created_at,
    os.data_entrada
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
ORDER BY os.data_entrada DESC
LIMIT 20;

-- 4. Contar ordens órfãs por data para identificar quando o problema começou
SELECT 
    DATE(data_entrada) as data,
    COUNT(*) as quantidade_orfas
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
GROUP BY DATE(data_entrada)
ORDER BY data DESC;

-- 5. Ver se existe algum padrão nos cliente_id órfãos (prefixos UUID similares que indiquem migração)
SELECT 
    SUBSTRING(cliente_id::text, 1, 8) as prefixo_uuid,
    COUNT(*) as quantidade
FROM ordens_servico
WHERE cliente_id NOT IN (SELECT id FROM clientes)
GROUP BY SUBSTRING(cliente_id::text, 1, 8)
ORDER BY quantidade DESC
LIMIT 10;

-- 6. Buscar nas ordens SE há algum campo adicional que possa ter nome/CPF do cliente
-- (Vamos procurar por campos JSON ou texto que possam conter essas informações)
-- Ajustado para usar apenas colunas que existem (vamos ver na query 1)
SELECT 
    os.id,
    os.numero_os,
    os.cliente_id
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
LIMIT 5;
