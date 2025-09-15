-- 🔐 CORREÇÃO DIRETA - Execute como ADMIN no SQL Editor
-- Use esta versão que não depende de auth.uid()

-- 1. Definir o user_id correto manualmente
WITH user_correto AS (
  SELECT 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid as user_id_correto
)

-- 2. Corrigir TODOS os clientes órfãos para o user_id correto
UPDATE clientes 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IS NULL 
   OR usuario_id NOT IN (SELECT id FROM auth.users)
RETURNING nome, telefone, usuario_id, 'Cliente corrigido' as status;

-- 3. Corrigir TODAS as ordens órfãs para o user_id correto  
WITH user_correto AS (
  SELECT 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid as user_id_correto
)
UPDATE ordens_servico 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IS NULL 
   OR usuario_id NOT IN (SELECT id FROM auth.users)
RETURNING numero_os, tipo, marca, modelo, 'Ordem corrigida' as status;

-- 4. Especificamente corrigir a ordem OS-20250915-003
UPDATE ordens_servico 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE numero_os = 'OS-20250915-003'
RETURNING numero_os, usuario_id, 'Ordem específica corrigida' as status;

-- 5. Corrigir o cliente Juliano especificamente
UPDATE clientes 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE telefone = '17999784438'
RETURNING nome, telefone, usuario_id, 'Cliente Juliano corrigido' as status;

-- 6. Verificar se funcionou
SELECT 
  'VERIFICAÇÃO FINAL' as titulo;

SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  c.telefone,
  os.usuario_id,
  CASE 
    WHEN os.usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid THEN '✅ CORRIGIDO'
    ELSE '❌ AINDA COM PROBLEMA'
  END as resultado
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';