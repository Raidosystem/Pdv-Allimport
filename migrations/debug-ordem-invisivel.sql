-- 🔍 Debug: Por que a ordem OS-20250915-003 não aparece na interface?
-- Execute no SQL Editor do Supabase

-- 1. Verificar dados completos da ordem problemática
SELECT 
  id,
  numero_os,
  usuario_id,
  cliente_id,
  status,
  tipo,
  marca,
  modelo,
  data_entrada,
  created_at,
  updated_at
FROM ordens_servico 
WHERE numero_os = 'OS-20250915-003';

-- 2. Verificar se tem usuario_id definido
SELECT 
  numero_os,
  usuario_id,
  CASE 
    WHEN usuario_id IS NULL THEN '❌ SEM USUARIO_ID'
    ELSE '✅ COM USUARIO_ID'
  END as status_usuario
FROM ordens_servico 
WHERE numero_os = 'OS-20250915-003';

-- 3. Verificar todas as ordens sem usuario_id
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  usuario_id,
  created_at
FROM ordens_servico 
WHERE usuario_id IS NULL
ORDER BY created_at DESC;

-- 4. Comparar com ordens que têm usuario_id
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  usuario_id,
  created_at
FROM ordens_servico 
WHERE usuario_id IS NOT NULL
ORDER BY created_at DESC
LIMIT 5;

-- 5. Verificar se existe o campo data_entrada
SELECT 
  numero_os,
  data_entrada,
  created_at,
  CASE 
    WHEN data_entrada IS NULL THEN '❌ SEM DATA_ENTRADA'
    ELSE '✅ COM DATA_ENTRADA'
  END as status_data
FROM ordens_servico 
WHERE numero_os = 'OS-20250915-003';

-- 6. Simular a consulta que o sistema faz (substitua USER_ID_ATUAL pelo seu ID)
-- Para descobrir seu user ID, execute: SELECT auth.uid();
SELECT auth.uid() as meu_user_id;

-- 7. Testar consulta completa como o sistema faz
SELECT 
  os.*,
  c.nome as cliente_nome
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.usuario_id = auth.uid()
ORDER BY os.data_entrada DESC NULLS LAST;