-- Verificar qual ID a EDVANIA tem agora
SELECT 
    id,
    nome,
    cpf_cnpj,
    telefone,
    created_at
FROM clientes
WHERE cpf_cnpj = '37511773885' OR telefone = '17999790061';

-- Verificar se há ordens com o ID antigo da EDVANIA (do backup)
SELECT 
    COUNT(*) as ordens_com_id_backup
FROM ordens_servico
WHERE cliente_id = 'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62';

-- Verificar se há ordens com o ID atual da EDVANIA
SELECT 
    id,
    COUNT(*) as total_ordens
FROM clientes
WHERE cpf_cnpj = '37511773885'
GROUP BY id;

-- Listar TODAS as ordens órfãs que deveriam ser da EDVANIA
-- (baseado no número da OS ou data)
SELECT 
    os.id,
    os.numero_os,
    os.cliente_id,
    os.marca,
    os.modelo,
    os.data_entrada
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
ORDER BY os.data_entrada DESC
LIMIT 20;
