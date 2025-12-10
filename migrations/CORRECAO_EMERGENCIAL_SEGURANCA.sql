-- 🔧 CORREÇÃO EMERGENCIAL DE SEGURANÇA
-- Execute APENAS APÓS executar a auditoria acima

-- PASSO 1: Identificar o user_id correto (mais recente/ativo)
WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at DESC
  LIMIT 1
)

-- PASSO 2: Unificar todos os clientes para o user_id correto
UPDATE clientes 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
RETURNING nome, telefone, usuario_id, 'Cliente unificado' as status;

-- PASSO 3: Unificar todas as ordens para o user_id correto
WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at DESC
  LIMIT 1
)
UPDATE ordens_servico 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
RETURNING numero_os, tipo, marca, modelo, usuario_id, 'Ordem unificada' as status;

-- PASSO 4: Verificar se a correção funcionou
SELECT 
  'VERIFICAÇÃO PÓS-CORREÇÃO' as titulo;

SELECT 
  COUNT(*) as total_clientes_unificados
FROM clientes 
WHERE usuario_id = auth.uid();

SELECT 
  COUNT(*) as total_ordens_unificadas
FROM ordens_servico 
WHERE usuario_id = auth.uid();

-- PASSO 5: Testar acesso à ordem problemática
SELECT 
  os.numero_os,
  os.status,
  os.tipo,
  os.marca,
  os.modelo,
  c.nome as cliente_nome,
  CASE 
    WHEN os.usuario_id = auth.uid() THEN '✅ ACESSO LIBERADO'
    ELSE '❌ AINDA BLOQUEADO'
  END as resultado_final
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os = 'OS-20250915-003';