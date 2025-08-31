-- 🗑️ LIMPEZA DEFINITIVA - Ordens de Serviço Incorretas
-- Execute no Supabase SQL Editor

-- PASSO 1: Verificar quantas ordens serão excluídas (EXECUTAR PRIMEIRO)
SELECT 
    COUNT(*) as total_ordens_para_excluir,
    COUNT(CASE WHEN marca IS NULL OR marca = 'Não informado' OR marca = '' THEN 1 END) as sem_marca,
    COUNT(CASE WHEN modelo IS NULL OR modelo = 'Não informado' OR modelo = '' THEN 1 END) as sem_modelo,
    COUNT(CASE WHEN descricao_problema = 'Problema não informado' OR descricao_problema = 'Não informado' OR descricao_problema IS NULL THEN 1 END) as sem_problema,
    COUNT(CASE WHEN valor IS NULL OR valor = 0 THEN 1 END) as sem_valor,
    COUNT(CASE WHEN cliente_id IS NULL THEN 1 END) as sem_cliente
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid())
  AND (
    -- Marca vazia
    (marca IS NULL OR marca = 'Não informado' OR marca = '')
    OR
    -- Modelo vazio  
    (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    OR
    -- Problema padrão
    (descricao_problema = 'Problema não informado' OR descricao_problema = 'Não informado' OR descricao_problema IS NULL)
    OR
    -- Valor zero
    (valor IS NULL OR valor = 0)
    OR
    -- Sem cliente
    (cliente_id IS NULL)
  );

-- PASSO 2: Ver exemplos das ordens que serão excluídas (EXECUTAR SEGUNDO)
SELECT 
    id, numero_os, equipamento, marca, modelo, descricao_problema, 
    valor, cliente_id, data_entrada, status
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid())
  AND (
    (marca IS NULL OR marca = 'Não informado' OR marca = '')
    OR (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    OR (descricao_problema = 'Problema não informado' OR descricao_problema = 'Não informado' OR descricao_problema IS NULL)
    OR (valor IS NULL OR valor = 0)
    OR (cliente_id IS NULL)
  )
ORDER BY data_entrada DESC
LIMIT 10;

-- PASSO 3: EXCLUSÃO DEFINITIVA (DESCOMENTE PARA EXECUTAR)
-- ⚠️ ATENÇÃO: Isso vai excluir TODAS as ordens com problemas!
-- ⚠️ Só execute se tiver certeza!

/*
DELETE FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid())
  AND (
    -- Marca vazia
    (marca IS NULL OR marca = 'Não informado' OR marca = '')
    OR
    -- Modelo vazio  
    (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    OR
    -- Problema padrão
    (descricao_problema = 'Problema não informado' OR descricao_problema = 'Não informado' OR descricao_problema IS NULL)
    OR
    -- Valor zero
    (valor IS NULL OR valor = 0)
    OR
    -- Sem cliente
    (cliente_id IS NULL)
  );
*/

-- PASSO 4: Verificar resultado após exclusão (EXECUTAR DEPOIS)
SELECT 
    COUNT(*) as ordens_restantes,
    COUNT(CASE WHEN marca IS NOT NULL AND marca != 'Não informado' AND marca != '' THEN 1 END) as com_marca_valida,
    COUNT(CASE WHEN modelo IS NOT NULL AND modelo != 'Não informado' AND modelo != '' THEN 1 END) as com_modelo_valido
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
