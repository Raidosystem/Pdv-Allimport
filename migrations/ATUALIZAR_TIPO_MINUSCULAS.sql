-- =============================================
-- ATUALIZAR VALORES DE TIPO PARA MINÚSCULAS
-- =============================================

-- Atualizar 'Física' para 'fisica'
UPDATE clientes 
SET tipo = 'fisica' 
WHERE tipo = 'Física' OR tipo ILIKE 'fisica' OR tipo ILIKE 'física';

-- Atualizar 'Jurídica' para 'juridica'
UPDATE clientes 
SET tipo = 'juridica' 
WHERE tipo = 'Jurídica' OR tipo ILIKE 'juridica' OR tipo ILIKE 'jurídica';

-- Verificar resultado
SELECT 
    tipo,
    COUNT(*) as total
FROM clientes
GROUP BY tipo
ORDER BY tipo;

SELECT '✅ Tipos atualizados para minúsculas!' as resultado;
