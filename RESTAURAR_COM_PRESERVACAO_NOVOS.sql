-- ============================================
-- RESTAURAÇÃO SEGURA COM PRESERVAÇÃO DOS CLIENTES NOVOS
-- ============================================

-- PASSO 1: Salvar tabela atual completa (segurança)
CREATE TABLE IF NOT EXISTS clientes_backup_completo_antes_restauracao AS 
SELECT * FROM clientes;

-- PASSO 2: Salvar especificamente os 52 clientes novos (após 01/08/2025)
CREATE TABLE IF NOT EXISTS clientes_novos_apos_backup AS
SELECT * FROM clientes
WHERE created_at > '2025-08-01T21:17:02.031Z';

-- PASSO 3: Verificar que salvamos os 52 clientes
SELECT COUNT(*) as confirmacao_52_clientes_salvos
FROM clientes_novos_apos_backup;

-- ============================================
-- AGORA EXECUTE O ARQUIVO: RESTAURAR_CLIENTES_SQL_GERADO.sql
-- Ele vai limpar e restaurar os 141 clientes do backup
-- ============================================

-- Após executar o outro arquivo, volte aqui e execute:

-- PASSO 4: Re-inserir os 52 clientes novos (sem duplicar)
INSERT INTO clientes
SELECT *
FROM clientes_novos_apos_backup
WHERE id NOT IN (SELECT id FROM clientes)
ON CONFLICT (id) DO NOTHING;

-- PASSO 5: Verificar resultado final
SELECT 
    'Total de clientes após restauração' as descricao,
    COUNT(*) as quantidade
FROM clientes
UNION ALL
SELECT 
    'Clientes do backup (até 01/08)' as descricao,
    COUNT(*) as quantidade
FROM clientes
WHERE created_at <= '2025-08-01T21:17:02.031Z'
UNION ALL
SELECT 
    'Clientes novos (após 01/08)' as descricao,
    COUNT(*) as quantidade
FROM clientes
WHERE created_at > '2025-08-01T21:17:02.031Z';

-- PASSO 6: Verificar ordens órfãs restantes
SELECT 
    COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 7: Testar EDVANIA
SELECT 
    os.numero_os,
    os.marca,
    os.modelo,
    os.tipo,
    os.data_entrada,
    c.nome as cliente_nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC
LIMIT 10;
