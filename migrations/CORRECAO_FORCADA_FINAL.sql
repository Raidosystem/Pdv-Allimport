-- 🔥 CORREÇÃO FORÇADA FINAL - Execute no SQL Editor
-- Esta é a correção mais direta possível

-- 1. Ver exatamente qual é o problema atual
SELECT 
  'DIAGNÓSTICO ATUAL' as titulo;

SELECT 
  os.numero_os,
  os.usuario_id as ordem_user_id,
  c.usuario_id as cliente_user_id,
  auth.uid() as auth_uid_atual,
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid as user_id_correto
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';

-- 2. FORÇAR a correção direta com o UUID correto
UPDATE ordens_servico 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE numero_os = 'OS-20250915-003'
RETURNING 
  numero_os, 
  usuario_id, 
  'Ordem FORÇADA para user correto' as status;

-- 3. FORÇAR a correção do cliente também
UPDATE clientes 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE telefone = '17999784438'
RETURNING 
  nome, 
  telefone, 
  usuario_id, 
  'Cliente FORÇADO para user correto' as status;

-- 4. Testar a consulta EXATAMENTE como o sistema faz
SELECT 
  'TESTE COMO O SISTEMA FAZ' as titulo;

-- Simular a consulta do sistema com o user_id correto
SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  os.usuario_id,
  '✅ DEVE APARECER AGORA' as resultado
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
  AND os.numero_os = 'OS-20250915-003';

-- 5. Ver TODAS as ordens deste usuário
SELECT 
  'TODAS AS ORDENS DO USUÁRIO CORRETO' as titulo;

SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  created_at
FROM ordens_servico 
WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
ORDER BY created_at DESC;

-- 6. Verificar se auth.uid() está funcionando
SELECT 
  'VERIFICAÇÃO DE AUTENTICAÇÃO' as titulo;

SELECT 
  auth.uid() as meu_auth_uid,
  auth.email() as meu_email,
  CASE 
    WHEN auth.uid() IS NULL THEN '❌ NÃO AUTENTICADO NO SQL EDITOR'
    WHEN auth.uid() = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid THEN '✅ AUTH CORRETO'
    ELSE '⚠️ AUTH COM UID DIFERENTE'
  END as status_auth;