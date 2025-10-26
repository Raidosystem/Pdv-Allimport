-- ============================================
-- RESTAURAÇÃO LIMPA - APENAS DADOS DO BACKUP
-- ============================================
-- Este script vai:
-- 1. Fazer backup de segurança
-- 2. Limpar TUDO
-- 3. Restaurar APENAS os 141 clientes do backup de 01/08/2025
-- 4. Resultado: Sistema limpo com dados consistentes

-- PASSO 1: Backup de segurança (por precaução)
CREATE TABLE IF NOT EXISTS clientes_backup_seguranca_completo AS 
SELECT * FROM clientes;

CREATE TABLE IF NOT EXISTS ordens_backup_seguranca_completo AS 
SELECT * FROM ordens_servico;

-- PASSO 2: Limpar tabela clientes completamente
TRUNCATE TABLE clientes CASCADE;

-- PASSO 3: Verificar que limpou
SELECT COUNT(*) as clientes_apos_limpar FROM clientes;
-- Deve retornar: 0

-- ============================================
-- AGORA EXECUTE O ARQUIVO: RESTAURAR_CLIENTES_SQL_GERADO.sql
-- Ele vai inserir os 141 clientes do backup
-- ============================================

-- PASSO 4: Após executar o arquivo acima, volte aqui e execute:

-- Verificar total de clientes restaurados
SELECT COUNT(*) as total_clientes FROM clientes;
-- Deve retornar: 141

-- PASSO 5: Verificar ordens órfãs restantes
SELECT 
    COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 6: Ver distribuição de ordens
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

-- PASSO 7: Testar EDVANIA (deve mostrar equipamentos)
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

-- PASSO 8: Ver primeiros 10 clientes restaurados
SELECT 
    nome,
    cpf_cnpj,
    telefone,
    created_at
FROM clientes
ORDER BY created_at
LIMIT 10;
