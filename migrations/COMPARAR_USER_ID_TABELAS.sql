-- ============================================
-- DIAGNÓSTICO: CLIENTES E ORDENS INVISÍVEIS
-- ============================================
-- ✅ Produtos aparecem (RLS OK para produtos)
-- ❌ Clientes NÃO aparecem
-- ❌ Ordens NÃO aparecem
-- Hipótese: user_id diferente ou coluna errada
-- ============================================

-- 1. Verificar user_id dos CLIENTES
SELECT 
  id,
  nome,
  user_id,
  empresa_id,
  CASE 
    WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MEU USER_ID'
    WHEN user_id IS NULL THEN '⚠️ USER_ID NULL'
    ELSE '❌ OUTRO USER_ID: ' || user_id
  END as status
FROM clientes
ORDER BY id
LIMIT 10;

-- 2. Contar clientes por user_id
SELECT 
  user_id,
  COUNT(*) as total,
  CASE 
    WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MEUS'
    WHEN user_id IS NULL THEN '⚠️ NULL'
    ELSE '❌ OUTRO: ' || SUBSTRING(user_id::text, 1, 8) || '...'
  END as status
FROM clientes
GROUP BY user_id;

-- 3. Verificar usuario_id das ORDENS
SELECT 
  numero_os,
  cliente_id,
  usuario_id,
  user_id,
  CASE 
    WHEN usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ USUARIO_ID OK'
    WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ USER_ID OK'
    WHEN usuario_id IS NULL AND user_id IS NULL THEN '⚠️ AMBOS NULL'
    ELSE '❌ DIFERENTE'
  END as status
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 10;

-- 4. Contar ordens por usuario_id
SELECT 
  usuario_id,
  COUNT(*) as total,
  CASE 
    WHEN usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MINHAS'
    WHEN usuario_id IS NULL THEN '⚠️ NULL'
    ELSE '❌ OUTRO: ' || SUBSTRING(usuario_id::text, 1, 8) || '...'
  END as status
FROM ordens_servico
GROUP BY usuario_id;

-- 5. Comparar produtos (que funcionam) com clientes/ordens
SELECT 
  'PRODUTOS' as tabela,
  user_id,
  COUNT(*) as total
FROM produtos
GROUP BY user_id
UNION ALL
SELECT 
  'CLIENTES' as tabela,
  user_id,
  COUNT(*) as total
FROM clientes
GROUP BY user_id
UNION ALL
SELECT 
  'ORDENS' as tabela,
  usuario_id as user_id,
  COUNT(*) as total
FROM ordens_servico
GROUP BY usuario_id
ORDER BY tabela, user_id;

-- 6. Verificar políticas RLS
SELECT 
  tablename,
  policyname,
  cmd,
  SUBSTRING(qual, 1, 100) as condicao
FROM pg_policies
WHERE tablename IN ('clientes', 'ordens_servico', 'produtos')
ORDER BY tablename, policyname;

-- 7. SOLUÇÃO IMEDIATA: Atualizar user_id para corresponder aos produtos
-- ✅ CONFIRMADO: Clientes têm user_id 28e56a69... (antigo)
-- ✅ EXECUTAR AGORA para corrigir:

-- Atualizar clientes para o mesmo user_id dos produtos
UPDATE clientes 
SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Atualizar ordens para o mesmo usuario_id
UPDATE ordens_servico 
SET usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Verificar resultado
SELECT 'CLIENTES' as tabela, COUNT(*) as total FROM clientes WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
UNION ALL
SELECT 'ORDENS' as tabela, COUNT(*) as total FROM ordens_servico WHERE usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- ============================================
-- INSTRUÇÕES:
-- 1. Execute Query 1-6 para diagnóstico completo
-- 2. Query 5 vai comparar os user_id de todas as tabelas
-- 3. Se clientes/ordens tiverem user_id diferente dos produtos, execute Query 7
-- ============================================
