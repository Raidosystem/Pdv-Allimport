-- ============================================
-- RESTAURAR CLIENTES DO BACKUP JSON
-- ============================================

-- PASSO 1: Analisar quantos clientes existem no backup
-- Execute este SELECT para ver quantos clientes há no backup atual

SELECT COUNT(*) as total_clientes_atual
FROM clientes;

-- PASSO 2: Fazer backup da tabela atual (por segurança)
CREATE TABLE IF NOT EXISTS clientes_backup_antes_restauracao AS
SELECT * FROM clientes;

-- PASSO 3: Após importar o JSON, verificar quantos clientes foram restaurados
-- (Você precisará usar a função de importação do Supabase ou um script)

-- PASSO 4: Verificar se as ordens órfãs foram resolvidas
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

-- PASSO 5: Verificar se EDVANIA foi restaurada com o ID correto do backup
SELECT 
    id,
    nome,
    cpf_cnpj,
    telefone,
    created_at
FROM clientes
WHERE cpf_cnpj = '37511773885';

-- PASSO 6: Testar se as ordens da EDVANIA agora aparecem
SELECT 
    os.numero_os,
    os.marca,
    os.modelo,
    os.data_entrada,
    c.nome as cliente_nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC;
