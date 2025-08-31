-- ============================================
-- SCRIPT PARA LIMPAR ORDENS DE SERVIÇO NO SUPABASE
-- ============================================
-- ATENÇÃO: Execute com cuidado! Isso vai deletar dados permanentemente.

-- 1. Verificar quantas ordens existem (EXECUTE PRIMEIRO PARA CONFIRMAR)
SELECT 
    usuario_id,
    COUNT(*) as total_ordens,
    MIN(criado_em) as primeira_ordem,
    MAX(criado_em) as ultima_ordem
FROM ordens_servico 
WHERE usuario_id = '28e56a69-90df-4852-b663-9b02f4358c6f'
GROUP BY usuario_id;

-- 2. Ver algumas ordens para confirmar
SELECT 
    id,
    numero_os,
    equipamento,
    marca,
    modelo,
    status,
    criado_em
FROM ordens_servico 
WHERE usuario_id = '28e56a69-90df-4852-b663-9b02f4358c6f'
ORDER BY criado_em DESC
LIMIT 10;

-- 3. DELETAR TODAS AS ORDENS (CUIDADO!)
-- Descomente a linha abaixo apenas quando tiver certeza:
-- DELETE FROM ordens_servico WHERE usuario_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

-- 4. Verificar se foi limpo (deve retornar 0)
-- SELECT COUNT(*) FROM ordens_servico WHERE usuario_id = '28e56a69-90df-4852-b663-9b02f4358c6f';
