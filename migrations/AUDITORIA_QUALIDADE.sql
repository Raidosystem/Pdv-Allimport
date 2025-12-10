-- 🔍 AUDITORIA DE QUALIDADE - Verificar problemas potenciais
-- Execute no Supabase Dashboard para identificar duplicatas e inconsistências

-- 1. VERIFICAR CLIENTES DUPLICADOS (mesmo telefone)
SELECT 
  'CLIENTES DUPLICADOS POR TELEFONE' as problema,
  telefone,
  count(*) as quantidade,
  string_agg(nome, ' | ') as nomes
FROM clientes 
WHERE telefone IS NOT NULL 
  AND telefone != ''
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
GROUP BY telefone 
HAVING count(*) > 1
ORDER BY quantidade DESC;

-- 2. VERIFICAR CLIENTES DUPLICADOS (mesmo nome)
SELECT 
  'CLIENTES DUPLICADOS POR NOME' as problema,
  nome,
  count(*) as quantidade,
  string_agg(telefone, ' | ') as telefones
FROM clientes 
WHERE nome IS NOT NULL 
  AND nome != ''
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
GROUP BY nome 
HAVING count(*) > 1
ORDER BY quantidade DESC;

-- 3. VERIFICAR ORDENS COM CLIENTES INEXISTENTES (FK órfã)
SELECT 
  'ORDENS COM CLIENTE INEXISTENTE' as problema,
  os.numero_os,
  os.cliente_id,
  os.marca,
  os.modelo
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.id IS NULL
  AND os.usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;

-- 4. VERIFICAR NÚMEROS DE OS DUPLICADOS
SELECT 
  'OS DUPLICADAS' as problema,
  numero_os,
  count(*) as quantidade,
  string_agg(marca || ' ' || modelo, ' | ') as equipamentos
FROM ordens_servico 
WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
GROUP BY numero_os 
HAVING count(*) > 1
ORDER BY quantidade DESC;

-- 5. VERIFICAR CLIENTES SEM TELEFONE (problemático)
SELECT 
  'CLIENTES SEM TELEFONE' as problema,
  id,
  nome,
  telefone
FROM clientes 
WHERE (telefone IS NULL OR telefone = '')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY nome;

-- 6. VERIFICAR ORDENS SEM STATUS VÁLIDO
SELECT 
  'ORDENS COM STATUS INVÁLIDO' as problema,
  numero_os,
  status,
  marca,
  modelo
FROM ordens_servico 
WHERE status NOT IN ('Em análise', 'Em conserto', 'Aguardando peça', 'Pronto', 'Entregue', 'Cancelado')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;

-- 7. VERIFICAR ORDENS TEST/EXEMPLO QUE PODEM SER REMOVIDAS
SELECT 
  'ORDENS DE TESTE' as problema,
  numero_os,
  marca,
  modelo,
  status,
  created_at
FROM ordens_servico 
WHERE (numero_os LIKE 'TEST-%' 
       OR numero_os LIKE '%test%' 
       OR numero_os LIKE '%exemplo%'
       OR marca ILIKE '%test%'
       OR modelo ILIKE '%test%')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC;

-- 8. VERIFICAR CLIENTES COM NOMES SUSPEITOS (test, exemplo, etc)
SELECT 
  'CLIENTES DE TESTE' as problema,
  id,
  nome,
  telefone,
  created_at
FROM clientes 
WHERE (nome ILIKE '%test%' 
       OR nome ILIKE '%exemplo%' 
       OR nome ILIKE '%demo%'
       OR nome = 'Cliente Teste'
       OR nome = 'Teste')
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC;

-- 9. VERIFICAR DATAS INCONSISTENTES
SELECT 
  'ORDENS COM DATAS FUTURAS' as problema,
  numero_os,
  marca,
  modelo,
  created_at
FROM ordens_servico 
WHERE created_at > NOW()
  AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;

-- 10. RESUMO GERAL DO SISTEMA
SELECT 
  'RESUMO FINAL' as tipo,
  (SELECT count(*) FROM clientes WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid) as total_clientes,
  (SELECT count(*) FROM ordens_servico WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid) as total_ordens,
  (SELECT count(DISTINCT telefone) FROM clientes WHERE telefone IS NOT NULL AND telefone != '' AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid) as telefones_unicos,
  (SELECT count(*) FROM ordens_servico WHERE status = 'Em análise' AND usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid) as ordens_em_analise;