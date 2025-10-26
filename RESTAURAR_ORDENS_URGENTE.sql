-- ============================================
-- RESTAURAR ORDENS DE SERVIÇO URGENTE
-- ============================================

-- PASSO 1: Restaurar ordens do backup de segurança
INSERT INTO ordens_servico
SELECT * FROM ordens_backup_seguranca_completo
ON CONFLICT (id) DO NOTHING;

-- PASSO 2: Verificar quantas ordens foram restauradas
SELECT COUNT(*) as total_ordens_restauradas FROM ordens_servico;

-- PASSO 3: Verificar distribuição
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
    'Ordens órfãs' as descricao,
    COUNT(*) as quantidade
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 4: Testar EDVANIA
SELECT 
    os.numero_os,
    os.marca,
    os.modelo,
    os.tipo,
    os.data_entrada,
    os.status,
    c.nome as cliente_nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;
