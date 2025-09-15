-- 🔧 CORREÇÃO DEFINITIVA - Ordens de Serviço Invisíveis
-- Execute no SQL Editor do Supabase Dashboard
-- Problema: OSs só aparecem para assistenciaallimport10@gmail.com

-- ================================================================================
-- PARTE 1: DIAGNÓSTICO COMPLETO
-- ================================================================================

-- 1.1 Verificar quantos user_ids diferentes existem para o mesmo email
SELECT 
  '🔍 DIAGNÓSTICO: User IDs para assistenciaallimport10@gmail.com' as info;

SELECT 
  id as user_id,
  email,
  created_at,
  last_sign_in_at,
  CASE 
    WHEN last_sign_in_at IS NOT NULL THEN '✅ JÁ FEZ LOGIN'
    ELSE '❌ NUNCA FEZ LOGIN'
  END as status_login
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
ORDER BY last_sign_in_at DESC NULLS LAST, created_at ASC;

-- 1.2 Ver distribuição de dados por user_id
SELECT 
  '📊 DISTRIBUIÇÃO DE CLIENTES POR USER_ID' as info;

SELECT 
  usuario_id,
  COUNT(*) as total_clientes,
  CASE 
    WHEN usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
    THEN '✅ PERTENCE AO ASSISTÊNCIA'
    ELSE '❌ ÓRFÃO'
  END as status
FROM clientes 
GROUP BY usuario_id
HAVING COUNT(*) > 0
ORDER BY total_clientes DESC;

SELECT 
  '📋 DISTRIBUIÇÃO DE ORDENS POR USER_ID' as info;

SELECT 
  usuario_id,
  COUNT(*) as total_ordens,
  CASE 
    WHEN usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
    THEN '✅ PERTENCE AO ASSISTÊNCIA'
    ELSE '❌ ÓRFÃO'
  END as status
FROM ordens_servico 
GROUP BY usuario_id
HAVING COUNT(*) > 0
ORDER BY total_ordens DESC;

-- 1.3 Verificar os casos específicos (Juliano e Cristiano)
SELECT 
  '🎯 CASOS ESPECÍFICOS' as info;

-- Juliano Ramos
SELECT 
  'JULIANO RAMOS' as cliente,
  c.nome,
  c.telefone,
  c.usuario_id,
  (SELECT COUNT(*) FROM ordens_servico WHERE cliente_id = c.id) as total_ordens,
  CASE 
    WHEN c.usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
    THEN '✅ VISÍVEL'
    ELSE '❌ INVISÍVEL'
  END as status_visibilidade
FROM clientes c
WHERE c.telefone = '17999784438';

-- Cristiano Ramos Mendes  
SELECT 
  'CRISTIANO RAMOS MENDES' as cliente,
  c.nome,
  c.telefone,
  c.cpf_cnpj,
  c.usuario_id,
  (SELECT COUNT(*) FROM ordens_servico WHERE cliente_id = c.id) as total_ordens,
  CASE 
    WHEN c.usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com') 
    THEN '✅ VISÍVEL'
    ELSE '❌ INVISÍVEL'
  END as status_visibilidade
FROM clientes c
WHERE c.telefone = '17999783012' OR c.cpf_cnpj = '28219618809';

-- ================================================================================
-- PARTE 2: IDENTIFICAR O USER_ID CORRETO
-- ================================================================================

-- 2.1 Encontrar o user_id mais adequado (que fez login mais recentemente)
SELECT 
  '🎯 USER_ID CORRETO IDENTIFICADO' as info;

WITH user_correto AS (
  SELECT 
    id as user_id_correto,
    email,
    created_at,
    last_sign_in_at
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY 
    last_sign_in_at DESC NULLS LAST,
    created_at ASC  -- Se nunca fizeram login, pegar o mais antigo
  LIMIT 1
)
SELECT 
  user_id_correto,
  '👑 ESTE SERÁ O USER_ID UNIFICADO' as status,
  CASE 
    WHEN last_sign_in_at IS NOT NULL 
    THEN 'Último login: ' || last_sign_in_at::text
    ELSE 'Nunca fez login (será o padrão)'
  END as info_login
FROM user_correto;

-- ================================================================================
-- PARTE 3: CORREÇÃO EM LOTE (DESCOMENTE PARA EXECUTAR)
-- ================================================================================

-- ⚠️ ATENÇÃO: Descomente as linhas abaixo APENAS após verificar o diagnóstico acima

/*
-- 3.1 Unificar TODOS os clientes para o user_id correto
WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at ASC
  LIMIT 1
)
UPDATE clientes 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
OR usuario_id IS NULL;

-- 3.2 Unificar TODAS as ordens para o user_id correto  
WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at ASC
  LIMIT 1
)
UPDATE ordens_servico 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
OR usuario_id IS NULL;

-- 3.3 Unificar outros dados relacionados (se existirem)
WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at ASC
  LIMIT 1
)
UPDATE vendas 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
OR usuario_id IS NULL;

WITH user_correto AS (
  SELECT id as user_id_correto
  FROM auth.users 
  WHERE email = 'assistenciaallimport10@gmail.com'
  ORDER BY last_sign_in_at DESC NULLS LAST, created_at ASC
  LIMIT 1
)
UPDATE produtos 
SET usuario_id = (SELECT user_id_correto FROM user_correto)
WHERE usuario_id IN (
  SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
)
OR usuario_id IS NULL;
*/

-- ================================================================================
-- PARTE 4: VERIFICAÇÃO PÓS-CORREÇÃO
-- ================================================================================

-- Execute esta parte APÓS descomentar e executar a Parte 3

SELECT 
  '✅ VERIFICAÇÃO PÓS-CORREÇÃO' as info;

-- 4.1 Verificar se todos os dados estão unificados
SELECT 
  'CLIENTES UNIFICADOS' as tipo,
  COUNT(*) as total,
  usuario_id
FROM clientes 
WHERE usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')
GROUP BY usuario_id;

SELECT 
  'ORDENS UNIFICADAS' as tipo,
  COUNT(*) as total,
  usuario_id
FROM ordens_servico 
WHERE usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')
GROUP BY usuario_id;

-- 4.2 Verificar casos específicos novamente
SELECT 
  '🎯 CASOS ESPECÍFICOS PÓS-CORREÇÃO' as info;

-- Juliano Ramos
SELECT 
  'JULIANO RAMOS' as cliente,
  c.nome,
  c.telefone,
  c.usuario_id,
  (SELECT COUNT(*) FROM ordens_servico WHERE cliente_id = c.id) as total_ordens,
  '✅ DEVE ESTAR VISÍVEL AGORA' as status
FROM clientes c
WHERE c.telefone = '17999784438';

-- Cristiano Ramos Mendes
SELECT 
  'CRISTIANO RAMOS MENDES' as cliente,
  c.nome,
  c.telefone,
  c.cpf_cnpj,
  c.usuario_id,
  (SELECT COUNT(*) FROM ordens_servico WHERE cliente_id = c.id) as total_ordens,
  '✅ DEVE ESTAR VISÍVEL AGORA' as status
FROM clientes c
WHERE c.telefone = '17999783012' OR c.cpf_cnpj = '28219618809';

-- 4.3 Listar algumas ordens para confirmar
SELECT 
  '📋 ORDENS VISÍVEIS APÓS CORREÇÃO' as info;

SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  data_entrada,
  usuario_id,
  created_at
FROM ordens_servico 
WHERE usuario_id IN (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com')
ORDER BY created_at DESC
LIMIT 10;

-- ================================================================================
-- INSTRUÇÕES DE USO:
-- ================================================================================

/*

🔥 INSTRUÇÕES PARA EXECUTAR:

1. Execute APENAS a PARTE 1 (Diagnóstico) primeiro
2. Analise os resultados para entender o problema
3. Se confirmar que há dados dispersos, descomente a PARTE 3
4. Execute a PARTE 3 (Correção) 
5. Execute a PARTE 4 (Verificação) para confirmar

⚠️ IMPORTANTE: 
- Faça backup antes de executar a correção
- Execute em horário de menor uso
- Teste em ambiente de desenvolvimento primeiro se possível

📱 TESTE NO SISTEMA:
Após a correção, faça login com assistenciaallimport10@gmail.com e verifique se:
- Todos os clientes aparecem
- Todas as OSs aparecem (incluindo Juliano e Cristiano)
- Sistema funciona normalmente

*/