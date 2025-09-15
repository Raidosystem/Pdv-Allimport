-- 🔍 Debug: Encontrar ordem específica do cliente Juliano Ramos
-- Execute no SQL Editor do Supabase

-- 1. Buscar o cliente Juliano Ramos pelo telefone
SELECT 
  id as cliente_id,
  nome,
  telefone,
  usuario_id,
  created_at
FROM clientes 
WHERE telefone = '17999784438' OR nome ILIKE '%Juliano%';

-- 2. Buscar ordens do cliente Juliano Ramos
SELECT 
  os.id,
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  os.defeito_relatado,
  os.usuario_id as ordem_usuario_id,
  os.cliente_id,
  os.created_at as ordem_created_at,
  c.nome as cliente_nome,
  c.telefone as cliente_telefone,
  c.usuario_id as cliente_usuario_id
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE c.telefone = '17999784438' OR c.nome ILIKE '%Juliano%';

-- 3. Verificar especificamente a ordem OS-20250915-003
SELECT 
  os.*,
  c.nome as cliente_nome,
  c.telefone as cliente_telefone,
  c.usuario_id as cliente_usuario_id
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';

-- 4. Verificar seu user ID atual
SELECT auth.uid() as meu_user_id;

-- 5. Comparar user IDs (cliente, ordem e usuário atual)
SELECT 
  'Usuário Logado' as tipo,
  auth.uid() as user_id
UNION ALL
SELECT 
  'Cliente Juliano' as tipo,
  c.usuario_id as user_id
FROM clientes c 
WHERE c.telefone = '17999784438'
UNION ALL
SELECT 
  'Ordem OS-003' as tipo,
  os.usuario_id as user_id
FROM ordens_servico os
WHERE os.numero_os = 'OS-20250915-003';

-- 6. Corrigir usuario_id se necessário (execute apenas se os user_ids forem diferentes)
-- UPDATE ordens_servico 
-- SET usuario_id = auth.uid() 
-- WHERE numero_os = 'OS-20250915-003';

-- UPDATE clientes 
-- SET usuario_id = auth.uid() 
-- WHERE telefone = '17999784438';

-- 7. Testar consulta como o sistema faz
SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  os.created_at
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.usuario_id = auth.uid()
ORDER BY os.created_at DESC;