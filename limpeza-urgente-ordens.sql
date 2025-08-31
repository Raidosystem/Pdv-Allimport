-- 🗑️ LIMPEZA URGENTE - Todas as Ordens Incorretas
-- Execute diretamente no Supabase SQL Editor

-- EXCLUSÃO DIRETA das 320 ordens incorretas
DELETE FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid())
  AND (
    -- Marca vazia ou genérica
    (marca IS NULL OR marca = 'Não informado' OR marca = '' OR marca = 'Outros')
    OR
    -- Modelo vazio ou genérico
    (modelo IS NULL OR modelo = 'Não informado' OR modelo = '')
    OR
    -- Problema padrão/vazio
    (descricao_problema = 'Problema não informado' OR descricao_problema = 'Não informado' OR descricao_problema IS NULL OR descricao_problema = '')
    OR
    -- Valor zero ou nulo
    (valor IS NULL OR valor = 0)
    OR
    -- Sem cliente
    (cliente_id IS NULL)
    OR
    -- Equipamento genérico
    (equipamento = 'Não informado Não informado' OR equipamento = 'Outros Não informado')
    OR
    -- Números de OS duplicados com prefixos genéricos
    (numero_os LIKE 'OS0%' AND LENGTH(numero_os) = 5)
  );

-- Verificar quantas ordens restaram após limpeza
SELECT 
    COUNT(*) as ordens_restantes,
    COUNT(CASE WHEN marca IS NOT NULL AND marca != 'Não informado' AND marca != '' AND marca != 'Outros' THEN 1 END) as com_marca_valida,
    COUNT(CASE WHEN modelo IS NOT NULL AND modelo != 'Não informado' AND modelo != '' THEN 1 END) as com_modelo_valido,
    COUNT(CASE WHEN descricao_problema IS NOT NULL AND descricao_problema != 'Não informado' AND descricao_problema != 'Problema não informado' AND descricao_problema != '' THEN 1 END) as com_problema_valido
FROM ordens_servico 
WHERE usuario_id = (SELECT auth.uid());
