-- ============================================
-- INVESTIGAÇÃO: Clientes Órfãos nas Ordens
-- ============================================

-- 1. Buscar se EDVANIA tem outros registros (mesmo CPF/telefone)
SELECT 
    id,
    nome,
    cpf_cnpj,
    telefone,
    created_at,
    updated_at
FROM clientes
WHERE 
    cpf_cnpj = '37511773885' 
    OR telefone = '17999790061'
    OR nome ILIKE '%EDVANIA%'
ORDER BY created_at DESC;

-- 2. Verificar quantos cliente_id nas ordens NÃO existem na tabela clientes
SELECT 
    COUNT(DISTINCT os.cliente_id) as total_ids_unicos_nas_ordens,
    COUNT(DISTINCT c.id) as total_ids_que_existem_em_clientes,
    COUNT(DISTINCT os.cliente_id) - COUNT(DISTINCT c.id) as ids_orfaos
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id;

-- 3. Listar os 20 primeiros cliente_id órfãos (que não existem em clientes)
SELECT DISTINCT os.cliente_id as id_orfao
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
LIMIT 20;

-- 4. Contar quantas ordens estão órfãs
SELECT 
    'Total de ordens' as descricao,
    COUNT(*) as quantidade
FROM ordens_servico
UNION ALL
SELECT 
    'Ordens com cliente válido' as descricao,
    COUNT(*) as quantidade
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
UNION ALL
SELECT 
    'Ordens órfãs (sem cliente)' as descricao,
    COUNT(*) as quantidade
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- 5. Ver exemplos de ordens órfãs com seus dados
SELECT 
    os.id,
    os.numero_os,
    os.cliente_id as cliente_id_orfao,
    os.marca,
    os.modelo,
    os.tipo,
    os.data_entrada,
    os.status
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
LIMIT 10;
