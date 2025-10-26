-- ============================================
-- TESTAR SE RLS PERMITE JOIN AGORA
-- ============================================

-- 1. Verificar quantos clientes são visíveis
SELECT COUNT(*) as total_clientes_visiveis FROM clientes;

-- 2. Testar JOIN com ordens de serviço (deve retornar nomes)
SELECT 
  os.numero_os,
  os.cliente_id,
  c.id as cliente_id_encontrado,
  c.nome as nome_cliente,
  c.telefone as telefone_cliente
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os IN ('OS-2025-06-17-001', 'OS-2025-06-17-002')
ORDER BY os.numero_os;

-- 3. Testar SELECT com JOIN (simula query do Supabase)
SELECT 
  os.*,
  row_to_json(c.*) as clientes
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os IN ('OS-2025-06-17-001', 'OS-2025-06-17-002')
ORDER BY os.numero_os;

-- 4. Verificar primeiras 5 ordens com nomes de clientes
SELECT 
  os.numero_os,
  os.modelo,
  c.nome as cliente_nome
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
ORDER BY os.data_entrada DESC
LIMIT 5;

-- ============================================
-- RESULTADO ESPERADO:
-- Query 1: 141 clientes visíveis
-- Query 2: EDVANIA DA SILVA aparece nas 2 ordens
-- Query 3: clientes = {"nome": "EDVANIA DA SILVA", ...}
-- Query 4: 5 ordens com nomes reais (não null)
-- ============================================
