-- 🗑️ Script de Limpeza - Ordens de Serviço com Dados Incorretos
-- Execute este script no SQL Editor do Supabase para limpar dados importados incorretamente

-- ⚠️  ATENÇÃO: Este script irá EXCLUIR permanentemente as ordens de serviço
-- Certifique-se de fazer backup antes de executar se necessário

-- 📊 Primeiro, vamos ver quantas ordens serão afetadas (EXECUTE ESTE PRIMEIRO):
SELECT 
    COUNT(*) as total_ordens_para_excluir,
    COUNT(CASE WHEN marca IS NULL OR marca = 'Não informado' THEN 1 END) as sem_marca,
    COUNT(CASE WHEN modelo IS NULL OR modelo = 'Não informado' THEN 1 END) as sem_modelo, 
    COUNT(CASE WHEN valor IS NULL OR valor = 0 THEN 1 END) as sem_valor,
    COUNT(CASE WHEN descricao_problema = 'Problema não informado' THEN 1 END) as sem_problema,
    COUNT(CASE WHEN cliente_id IS NULL THEN 1 END) as sem_cliente
FROM ordens_servico
WHERE 
    -- Critérios para identificar ordens com dados incorretos
    (marca IS NULL OR marca = 'Não informado' OR marca = '') 
    AND (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    AND (valor IS NULL OR valor = 0)
    AND cliente_id IS NULL
    AND descricao_problema IN ('Problema não informado', 'Não informado', '');

-- 📋 Ver algumas ordens que serão excluídas (para confirmar):
SELECT 
    id,
    numero_os,
    equipamento,
    marca,
    modelo,
    descricao_problema,
    valor,
    status,
    data_entrada,
    cliente_id,
    criado_em
FROM ordens_servico
WHERE 
    (marca IS NULL OR marca = 'Não informado' OR marca = '') 
    AND (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    AND (valor IS NULL OR valor = 0)
    AND cliente_id IS NULL
    AND descricao_problema IN ('Problema não informado', 'Não informado', '')
ORDER BY criado_em DESC
LIMIT 10;

-- ❌ EXCLUSÃO DEFINITIVA (Execute apenas se tiver certeza):
-- Descomente as linhas abaixo para executar a exclusão
/*
DELETE FROM ordens_servico
WHERE 
    (marca IS NULL OR marca = 'Não informado' OR marca = '') 
    AND (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    AND (valor IS NULL OR valor = 0)
    AND cliente_id IS NULL
    AND descricao_problema IN ('Problema não informado', 'Não informado', '');
*/

-- 📊 Após a exclusão, verificar quantas ordens restaram:
/*
SELECT 
    COUNT(*) as ordens_restantes,
    COUNT(CASE WHEN cliente_id IS NOT NULL THEN 1 END) as com_cliente,
    COUNT(CASE WHEN valor > 0 THEN 1 END) as com_valor,
    AVG(valor) as valor_medio
FROM ordens_servico;
*/
