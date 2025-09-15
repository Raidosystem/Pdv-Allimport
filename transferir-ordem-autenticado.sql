-- ✅ Solução: Transferir ordem órfã para o usuário atual
-- Execute no SQL Editor do Supabase LOGADO

-- 1. Verificar se você está autenticado
SELECT 
  auth.uid() as meu_user_id,
  auth.email() as meu_email,
  CASE 
    WHEN auth.uid() IS NULL THEN '❌ NÃO AUTENTICADO - Faça login no Supabase Dashboard primeiro'
    ELSE '✅ AUTENTICADO'
  END as status_auth;

-- 2. Se estiver autenticado, transferir a ordem
UPDATE ordens_servico 
SET usuario_id = auth.uid() 
WHERE numero_os = 'OS-20250915-003'
AND auth.uid() IS NOT NULL
RETURNING numero_os, usuario_id, 'Ordem transferida' as status;

-- 3. Transferir o cliente também  
UPDATE clientes 
SET usuario_id = auth.uid() 
WHERE telefone = '17999784438'
AND auth.uid() IS NOT NULL
RETURNING nome, telefone, usuario_id, 'Cliente transferido' as status;

-- 4. Verificar se a correção funcionou
SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  c.telefone as cliente_telefone,
  CASE 
    WHEN os.usuario_id = auth.uid() THEN '✅ AGORA É SEU'
    ELSE '❌ AINDA COM PROBLEMA'
  END as resultado
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';