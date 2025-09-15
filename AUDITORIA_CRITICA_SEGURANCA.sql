-- 🚨 AUDITORIA CRÍTICA DE SEGURANÇA
-- Execute no SQL Editor do Supabase URGENTE

-- 1. Verificar se há múltiplas contas com o mesmo email
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  email_confirmed_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
ORDER BY created_at;

-- 2. Verificar quantos user_ids diferentes existem para este email
SELECT 
  COUNT(DISTINCT id) as total_usuarios,
  email
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
GROUP BY email;

-- 3. Verificar todos os dados criados por este email
SELECT 
  'CLIENTES' as tabela,
  COUNT(*) as total,
  COUNT(DISTINCT usuario_id) as user_ids_diferentes
FROM clientes 
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
UNION ALL
SELECT 
  'ORDENS' as tabela,
  COUNT(*) as total,
  COUNT(DISTINCT usuario_id) as user_ids_diferentes
FROM ordens_servico 
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
);

-- 4. Identificar o user_id correto (mais recente)
SELECT 
  id as user_id_correto,
  email,
  created_at,
  last_sign_in_at,
  'USAR ESTE ID' as acao
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
ORDER BY last_sign_in_at DESC NULLS LAST, created_at DESC
LIMIT 1;

-- 5. Verificar exatamente quais dados estão "órfãos"
SELECT 
  'Cliente Juliano' as item,
  c.usuario_id,
  au.email,
  CASE 
    WHEN au.email IS NULL THEN '❌ USER_ID INVÁLIDO'
    WHEN au.email = 'assistenciaallimport10@gmail.com' THEN '✅ EMAIL CORRETO'
    ELSE '⚠️ EMAIL DIFERENTE'
  END as status
FROM clientes c
LEFT JOIN auth.users au ON c.usuario_id = au.id
WHERE c.telefone = '17999784438'

UNION ALL

SELECT 
  'Ordem OS-003' as item,
  os.usuario_id,
  au.email,
  CASE 
    WHEN au.email IS NULL THEN '❌ USER_ID INVÁLIDO'
    WHEN au.email = 'assistenciaallimport10@gmail.com' THEN '✅ EMAIL CORRETO'
    ELSE '⚠️ EMAIL DIFERENTE'
  END as status
FROM ordens_servico os
LEFT JOIN auth.users au ON os.usuario_id = au.id
WHERE os.numero_os = 'OS-20250915-003';

-- 6. Verificar seu user_id atual vs o cadastrado
SELECT 
  auth.uid() as user_id_atual,
  auth.email() as email_atual,
  (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com' ORDER BY last_sign_in_at DESC LIMIT 1) as user_id_esperado,
  CASE 
    WHEN auth.uid() = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com' ORDER BY last_sign_in_at DESC LIMIT 1) 
    THEN '✅ USER_IDS COINCIDEM'
    ELSE '❌ PROBLEMA: USER_IDS DIFERENTES'
  END as diagnostico;