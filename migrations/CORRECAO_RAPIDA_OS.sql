-- 🚀 CORREÇÃO RÁPIDA - Execute AGORA
-- Para resolver OSs invisíveis de Juliano e Cristiano

-- PASSO 1: Ver o problema
SELECT 'ANTES DA CORREÇÃO' as status;

SELECT 
  c.nome as cliente,
  c.telefone,
  COUNT(os.id) as total_os,
  c.usuario_id
FROM clientes c
LEFT JOIN ordens_servico os ON c.id = os.cliente_id
WHERE c.telefone IN ('17999784438', '17999783012')
   OR c.cpf_cnpj = '28219618809'
GROUP BY c.id, c.nome, c.telefone, c.usuario_id;

-- PASSO 2: Identificar user_id correto para assistenciaallimport10@gmail.com
WITH user_ativo AS (
  SELECT id 
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST
  LIMIT 1
)
SELECT 
  'USER_ID CORRETO:' as info,
  id as user_id_para_usar
FROM user_ativo;

-- PASSO 3: CORREÇÃO DIRETA
WITH user_ativo AS (
  SELECT id 
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST
  LIMIT 1
)
UPDATE clientes 
SET usuario_id = (SELECT id FROM user_ativo)
WHERE telefone IN ('17999784438', '17999783012')
   OR cpf_cnpj = '28219618809';

WITH user_ativo AS (
  SELECT id 
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST
  LIMIT 1
)
UPDATE ordens_servico 
SET usuario_id = (SELECT id FROM user_ativo)
WHERE cliente_id IN (
  SELECT id FROM clientes 
  WHERE telefone IN ('17999784438', '17999783012')
     OR cpf_cnpj = '28219618809'
);

-- PASSO 4: Verificar se funcionou
SELECT 'APÓS A CORREÇÃO' as status;

SELECT 
  c.nome as cliente,
  c.telefone,
  COUNT(os.id) as total_os,
  c.usuario_id,
  '✅ CORRIGIDO' as status
FROM clientes c
LEFT JOIN ordens_servico os ON c.id = os.cliente_id
WHERE c.telefone IN ('17999784438', '17999783012')
   OR c.cpf_cnpj = '28219618809'
GROUP BY c.id, c.nome, c.telefone, c.usuario_id;

-- PASSO 5: Listar as OSs que devem aparecer agora
SELECT 
  'ORDENS QUE DEVEM APARECER AGORA' as info;

SELECT 
  os.numero_os,
  c.nome as cliente,
  os.tipo,
  os.marca,
  os.modelo,
  os.status,
  os.data_entrada
FROM ordens_servico os
JOIN clientes c ON os.cliente_id = c.id
WHERE c.telefone IN ('17999784438', '17999783012')
   OR c.cpf_cnpj = '28219618809'
ORDER BY os.created_at DESC;