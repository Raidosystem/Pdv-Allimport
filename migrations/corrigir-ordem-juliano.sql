-- 🔧 Correção: Atribuir ownership da ordem do Juliano para você
-- Execute no SQL Editor do Supabase linha por linha

-- 1. Primeiro verificar a situação atual
SELECT 
  'Informações da Ordem OS-20250915-003' as titulo;

SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  os.usuario_id as ordem_usuario_id,
  c.nome as cliente_nome,
  c.telefone as cliente_telefone,
  c.usuario_id as cliente_usuario_id,
  auth.uid() as meu_user_id,
  CASE 
    WHEN os.usuario_id = auth.uid() THEN '✅ Ordem é sua'
    WHEN os.usuario_id IS NULL THEN '❌ Ordem órfã (sem dono)'
    ELSE '⚠️ Ordem de outro usuário'
  END as status_ownership
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';

-- 2. Corrigir a ordem (transferir para você)
UPDATE ordens_servico 
SET usuario_id = auth.uid() 
WHERE numero_os = 'OS-20250915-003'
RETURNING numero_os, usuario_id, 'Ordem corrigida' as status;

-- 3. Corrigir o cliente também (se necessário)
UPDATE clientes 
SET usuario_id = auth.uid() 
WHERE telefone = '17999784438'
RETURNING nome, telefone, usuario_id, 'Cliente corrigido' as status;

-- 4. Verificar se agora está correto
SELECT 
  'Verificação Pós-Correção' as titulo;

SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  c.telefone as cliente_telefone,
  CASE 
    WHEN os.usuario_id = auth.uid() THEN '✅ CORRIGIDO - Agora é sua'
    ELSE '❌ Ainda com problema'
  END as status_final
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';

-- 5. Listar todas as suas ordens para confirmar
SELECT 
  'Suas Ordens de Serviço' as titulo;

SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  created_at
FROM ordens_servico 
WHERE usuario_id = auth.uid()
ORDER BY created_at DESC;