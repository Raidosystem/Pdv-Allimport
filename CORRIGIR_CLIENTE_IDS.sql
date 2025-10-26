-- ============================================
-- CORRIGIR CLIENTE_ID DAS ORDENS
-- Atualizar IDs antigos para os IDs do backup JSON
-- ============================================

-- PASSO 1: Atualizar EDVANIA
UPDATE ordens_servico
SET cliente_id = 'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62'
WHERE cliente_id = 'e7491ef4-2e57-4ae4-9e7c-3912c0ad190b';

-- PASSO 2: Verificar quantas ordens da EDVANIA foram atualizadas
SELECT COUNT(*) as ordens_edvania_atualizadas
FROM ordens_servico
WHERE cliente_id = 'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62';

-- PASSO 3: Testar se agora aparecem os equipamentos da EDVANIA
SELECT
  os.numero_os,
  os.marca,
  os.modelo,
  os.data_entrada,
  c.nome
FROM ordens_servico os
INNER JOIN clientes c ON os.cliente_id = c.id
WHERE c.cpf_cnpj = '37511773885'
ORDER BY os.data_entrada DESC
LIMIT 10;

-- PASSO 4: Verificar se ainda há órfãos
SELECT COUNT(*) as orfaos_restantes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;

-- PASSO 5: Criar script para corrigir TODOS os outros clientes
-- Primeiro, identificar quantos clientes têm IDs diferentes entre backups
SELECT COUNT(DISTINCT os.cliente_id) as cliente_ids_unicos_em_ordens
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL;
